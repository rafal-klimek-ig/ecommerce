class AddSearchIndexes < ActiveRecord::Migration[7.0]
  def up
    # Enable pg_trgm extension for trigram similarity searches
    enable_extension 'pg_trgm'

    # GIN index for full-text search on product name and description
    add_index :products, "to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, ''))",
              using: :gin, name: 'products_search_idx'

    # GIN index for trigram similarity search on product name (fuzzy matching)
    add_index :products, :name, using: :gin, opclass: :gin_trgm_ops, name: 'products_name_trgm_idx'

    # Composite index for category + name searches
    add_index :products, [:category, :name], name: 'products_category_name_idx'

    # Index for active products with stock (common filter combination)
    add_index :products, [:active, :stock_quantity],
              where: "active = true AND stock_quantity > 0",
              name: 'products_available_idx'
  end

  def down
    remove_index :products, name: 'products_search_idx'
    remove_index :products, name: 'products_name_trgm_idx'
    remove_index :products, name: 'products_category_name_idx'
    remove_index :products, name: 'products_available_idx'

    disable_extension 'pg_trgm'
  end
end
