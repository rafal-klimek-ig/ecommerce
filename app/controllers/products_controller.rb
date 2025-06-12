class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = search_products
    @categories = Product.categories
    @current_category = params[:category]
    @search_term = params[:search]
    @total_count = @products.count

    # Pagination
    @products = @products.page(params[:page]).per(params[:per_page] || 12)

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        turbo_stream.replace("products_list",
        partial: "products/products_list",
        locals: { products: @products, total_count: @total_count })
      end
      format.json { render json: products_json }
    end
  end

  def show
    @related_products = Product.active
                              .where(category: @product.category)
                              .where.not(id: @product.id)
                              .limit(4)

    respond_to do |format|
      format.html
      format.json { render json: product_json(@product) }
    end
  end

  def search
    redirect_to products_path(search: params[:search], category: params[:category])
  end

  def categories
    render json: Product.categories.map { |category|
      {
        name: category,
        count: Product.active.by_category(category).count
      }
    }
  end

  def autocomplete
    return render json: [] if params[:term].blank?

    # Quick autocomplete search - limit to name matches only for speed
    suggestions = Product.active
                         .search_by_name(params[:term])
                         .limit(8)
                         .pluck(:name)
                         .uniq

    render json: suggestions
  end

  private

  def set_product
    @product = Product.active.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found or no longer available.'
  end

  def search_products
    products = Product.active.in_stock

    # Apply search term
    if params[:search].present?
      search_term = params[:search].strip
      search_type = determine_search_type(search_term)

      products = case search_type
                when :smart
                  Product.smart_search(search_term, params[:category])
                when :exact
                  products.where('name ILIKE ?', "%#{search_term}%")
                else
                  products.search_by_name(search_term)
                end
    end

    # Apply category filter
    products = products.by_category(params[:category]) if params[:category].present?

    # Apply sorting
    products = apply_sorting(products)

    # Apply price filters
    products = apply_price_filters(products)

    products
  end

  def determine_search_type(term)
    # Use smart search for complex queries, exact for simple ones
    if term.split.size > 1 || term.length > 15
      :smart
    elsif term.match?(/^[a-zA-Z\s]+$/) && term.length < 6
      :exact
    else
      :ilike
    end
  end

  def apply_sorting(products)
    case params[:sort]
    when 'price_low'
      products.order(:price)
    when 'price_high'
      products.order(price: :desc)
    when 'name'
      products.order(:name)
    when 'newest'
      products.order(created_at: :desc)
    when 'popularity'
      # Sort by number of times ordered
      products.left_joins(:order_items)
              .group('products.id')
              .order('COUNT(order_items.id) DESC, products.created_at DESC')
    else
      # Default: relevance for search, newest for browse
      if params[:search].present?
        products # Keep search relevance order
      else
        products.order(created_at: :desc)
      end
    end
  end

  def apply_price_filters(products)
    if params[:min_price].present?
      products = products.where('price >= ?', params[:min_price].to_f)
    end

    if params[:max_price].present?
      products = products.where('price <= ?', params[:max_price].to_f)
    end

    products
  end

  def products_json
    {
      products: @products.map { |p| product_json(p) },
      pagination: {
        current_page: @products.current_page,
        total_pages: @products.total_pages,
        total_count: @products.total_count,
        per_page: @products.limit_value
      },
      filters: {
        categories: @categories,
        current_category: @current_category,
        search_term: @search_term
      }
    }
  end

  def product_json(product)
    {
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      formatted_price: product.formatted_price,
      category: product.category,
      image_url: product.image_url,
      stock_quantity: product.stock_quantity,
      in_stock: product.in_stock?,
      created_at: product.created_at,
      updated_at: product.updated_at
    }
  end

  def product_search_json(product)
    {
      id: product.id,
      name: product.name,
      formatted_price: product.formatted_price,
      category: product.category,
      image_url: product.image_url,
      in_stock: product.in_stock?
    }
  end
end
