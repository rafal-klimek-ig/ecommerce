class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :price, presence: true,
                   numericality: { greater_than: 0, less_than: 10000 }
  validates :category, presence: true, length: { minimum: 2, maximum: 50 }
  validates :stock_quantity, presence: true,
                            numericality: { greater_than_or_equal_to: 0 }
  validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                 message: "must be a valid URL" }, allow_blank: true

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :by_category, ->(category) { where(category: category) }
  # PostgreSQL full-text search scopes
  scope :search_by_name, ->(term) { where('name ILIKE ?', "%#{term}%") }
  scope :full_text_search, ->(term) {
    where("to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, '')) @@ plainto_tsquery('english', ?)", term)
  }
  scope :fuzzy_search, ->(term) {
    where("name % ?", term).order(Arel.sql("similarity(name, #{connection.quote(term)}) DESC"))
  }

  def in_stock?
    stock_quantity > 0
  end

  def available_stock?(quantity)
    stock_quantity >= quantity
  end

  def formatted_price
    "$#{'%.2f' % price}"
  end

  def self.categories
    distinct.pluck(:category).compact.sort
  end

  def self.search(term, category = nil, search_type: :ilike)
    products = active

    if term.present?
      products = case search_type
                when :full_text
                  products.full_text_search(term)
                when :fuzzy
                  products.fuzzy_search(term)
                else
                  products.search_by_name(term)
                end
    end

    products = products.by_category(category) if category.present?
    products
  end

  def self.smart_search(term, category = nil)
    return search(term, category) if term.blank?

    # Try full-text search first
    results = search(term, category, search_type: :full_text)

    # Fall back to fuzzy search if no results
    if results.empty?
      results = search(term, category, search_type: :fuzzy)
    end

    # Final fallback to ILIKE search
    if results.empty?
      results = search(term, category, search_type: :ilike)
    end

    results
  end
end