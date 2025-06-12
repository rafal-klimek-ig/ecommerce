OrderItem.destroy_all
Order.destroy_all
User.destroy_all
Product.destroy_all

puts "Creating users..."

user1 = User.create!(
  email: 'john@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Doe',
  phone: '+1-555-0123'
)

user2 = User.create!(
  email: 'jane@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jane',
  last_name: 'Smith',
  phone: '+1-555-0456'
)

puts "✅ Created #{User.count} users!"

puts "Creating products..."

electronics = [
  {
    name: "MacBook Pro 16-inch M3",
    description: "Powerful laptop with M3 chip, 16GB RAM, 512GB SSD. Perfect for developers, designers, and creative professionals. Features stunning Retina display and all-day battery life.",
    price: 2499.00,
    category: "Electronics",
    stock_quantity: 15,
    image_url: "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500"
  },
  {
    name: "iPhone 15 Pro Max",
    description: "Latest iPhone with A17 Pro chip, titanium design, and advanced camera system. 256GB storage, exceptional battery life, and premium build quality.",
    price: 1199.00,
    category: "Electronics",
    stock_quantity: 25,
    image_url: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500"
  },
  {
    name: "Samsung 65-inch QLED 4K TV",
    description: "Ultra-high definition QLED smart TV with vibrant colors, HDR support, and built-in streaming apps. Perfect for home entertainment and gaming.",
    price: 1299.99,
    category: "Electronics",
    stock_quantity: 8,
    image_url: "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=500"
  },
  {
    name: "Sony WH-1000XM5 Headphones",
    description: "Industry-leading noise canceling wireless headphones with exceptional sound quality, 30-hour battery life, and premium comfort for long listening sessions.",
    price: 399.99,
    category: "Electronics",
    stock_quantity: 30,
    image_url: "https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=500"
  },
  {
    name: "iPad Air 11-inch",
    description: "Versatile tablet with M2 chip, perfect for work and creativity. Compatible with Apple Pencil and Magic Keyboard. 128GB Wi-Fi model.",
    price: 599.00,
    category: "Electronics",
    stock_quantity: 20,
    image_url: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500"
  },
  {
    name: "Nintendo Switch OLED",
    description: "Gaming console with vivid OLED screen, enhanced audio, and 64GB internal storage. Play at home or on the go with this versatile gaming system.",
    price: 349.99,
    category: "Electronics",
    stock_quantity: 12,
    image_url: "https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?w=500"
  }
]

clothing = [
  {
    name: "Levi's 501 Original Jeans",
    description: "Classic straight-leg jeans made from premium denim. Timeless style that works for any occasion. Available in multiple washes and sizes.",
    price: 89.99,
    category: "Clothing",
    stock_quantity: 45,
    image_url: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=500"
  },
  {
    name: "Nike Air Max 270 Sneakers",
    description: "Comfortable lifestyle sneakers with Max Air cushioning and breathable mesh upper. Perfect for everyday wear and light workouts.",
    price: 149.99,
    category: "Clothing",
    stock_quantity: 35,
    image_url: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500"
  },
  {
    name: "Patagonia Better Sweater Fleece",
    description: "Sustainable fleece jacket made from recycled polyester. Warm, comfortable, and environmentally conscious. Perfect for outdoor activities.",
    price: 119.00,
    category: "Clothing",
    stock_quantity: 22,
    image_url: "https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=500"
  },
  {
    name: "Uniqlo Merino Wool Sweater",
    description: "Premium merino wool crew neck sweater. Soft, lightweight, and naturally odor-resistant. Available in multiple colors.",
    price: 59.90,
    category: "Clothing",
    stock_quantity: 40,
    image_url: "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=500"
  },
  {
    name: "Adidas Ultraboost 22 Running Shoes",
    description: "High-performance running shoes with responsive Boost midsole and Primeknit upper. Designed for comfort and energy return.",
    price: 189.99,
    category: "Clothing",
    stock_quantity: 28,
    image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500"
  },
  {
    name: "Champion Reverse Weave Hoodie",
    description: "Classic heavyweight hoodie with reverse weave construction to minimize shrinkage. Comfortable cotton blend in vintage styling.",
    price: 65.00,
    category: "Clothing",
    stock_quantity: 33,
    image_url: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500"
  }
]

home_garden = [
  {
    name: "KitchenAid Stand Mixer",
    description: "Professional-grade stand mixer with 5-quart bowl and multiple attachments. Essential for baking enthusiasts and home chefs.",
    price: 379.99,
    category: "Home & Garden",
    stock_quantity: 18,
    image_url: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500"
  },
  {
    name: "Dyson V15 Detect Cordless Vacuum",
    description: "Advanced cordless vacuum with laser dust detection and powerful suction. Perfect for deep cleaning carpets and hard floors.",
    price: 749.99,
    category: "Home & Garden",
    stock_quantity: 14,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500"
  },
  {
    name: "Instant Pot Duo 7-in-1",
    description: "Multi-functional pressure cooker that replaces 7 kitchen appliances. Perfect for quick, healthy meals with preset cooking programs.",
    price: 99.99,
    category: "Home & Garden",
    stock_quantity: 25,
    image_url: "https://images.unsplash.com/photo-1585515656971-9d9c8e5e2a7b?w=500"
  },
  {
    name: "Philips Hue Smart Light Starter Kit",
    description: "Smart lighting system with color-changing LED bulbs controlled via smartphone app. Create perfect ambiance for any occasion.",
    price: 199.99,
    category: "Home & Garden",
    stock_quantity: 30,
    image_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500"
  },
  {
    name: "Weber Genesis II Gas Grill",
    description: "Premium gas grill with porcelain-enameled cast iron grates and infinity ignition. Perfect for outdoor cooking and entertaining.",
    price: 899.00,
    category: "Home & Garden",
    stock_quantity: 6,
    image_url: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500"
  },
  {
    name: "Roomba i7+ Robot Vacuum",
    description: "Smart robot vacuum with automatic dirt disposal and room mapping. Cleans your home on schedule and empties itself.",
    price: 649.99,
    category: "Home & Garden",
    stock_quantity: 11,
    image_url: "https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=500"
  }
]

books = [
  {
    name: "The Seven Husbands of Evelyn Hugo",
    description: "Captivating novel about a reclusive Hollywood icon who finally decides to tell her story. A tale of ambition, love, and the price of fame.",
    price: 16.99,
    category: "Books",
    stock_quantity: 50,
    image_url: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500"
  },
  {
    name: "Atomic Habits by James Clear",
    description: "Practical guide to building good habits and breaking bad ones. Based on scientific research with actionable strategies for personal improvement.",
    price: 18.99,
    category: "Books",
    stock_quantity: 42,
    image_url: "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500"
  },
  {
    name: "Dune by Frank Herbert",
    description: "Epic science fiction masterpiece set on the desert planet Arrakis. A tale of politics, religion, and ecology in a distant future.",
    price: 15.99,
    category: "Books",
    stock_quantity: 35,
    image_url: "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500"
  },
  {
    name: "The Psychology of Money",
    description: "Insights into the strange ways people think about money and teaches you how to do better with your financial decisions.",
    price: 19.99,
    category: "Books",
    stock_quantity: 38,
    image_url: "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=500"
  },
  {
    name: "Educated by Tara Westover",
    description: "Powerful memoir about education, family, and the struggle between loyalty and independence. A story of transformation through learning.",
    price: 17.99,
    category: "Books",
    stock_quantity: 29,
    image_url: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500"
  }
]

sports_outdoors = [
  {
    name: "Yeti Rambler 20oz Tumbler",
    description: "Double-wall vacuum insulated tumbler that keeps drinks cold or hot for hours. Durable stainless steel construction with no-sweat design.",
    price: 34.99,
    category: "Sports & Outdoors",
    stock_quantity: 55,
    image_url: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500"
  },
  {
    name: "REI Co-op Dome 2 Tent",
    description: "Reliable 2-person camping tent with easy setup and weather protection. Perfect for backpacking and car camping adventures.",
    price: 149.00,
    category: "Sports & Outdoors",
    stock_quantity: 16,
    image_url: "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=500"
  },
  {
    name: "Hydro Flask 32oz Water Bottle",
    description: "Insulated water bottle that keeps beverages cold for 24 hours or hot for 12 hours. Made from durable stainless steel.",
    price: 44.95,
    category: "Sports & Outdoors",
    stock_quantity: 48,
    image_url: "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500"
  },
  {
    name: "Patagonia Black Hole Duffel 60L",
    description: "Weather-resistant duffel bag made from recycled materials. Perfect for travel, gym, and outdoor adventures.",
    price: 149.00,
    category: "Sports & Outdoors",
    stock_quantity: 23,
    image_url: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500"
  },
  {
    name: "Coleman Portable Camping Chair",
    description: "Comfortable folding chair with cup holder and cooler pouch. Lightweight and easy to transport for camping and outdoor events.",
    price: 39.99,
    category: "Sports & Outdoors",
    stock_quantity: 32,
    image_url: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500"
  }
]

all_products = electronics + clothing + home_garden + books + sports_outdoors

all_products.each do |product_attrs|
  Product.create!(product_attrs)
  print "."
end

out_of_stock_products = [
  {
    name: "PlayStation 5 Console",
    description: "Next-generation gaming console with 4K gaming, ray tracing, and ultra-fast SSD. Currently sold out due to high demand.",
    price: 499.99,
    category: "Electronics",
    stock_quantity: 0,
    image_url: "https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=500"
  },
  {
    name: "Limited Edition Vintage Denim Jacket",
    description: "Rare vintage-style denim jacket with unique distressing and patches. Limited production run, currently out of stock.",
    price: 129.99,
    category: "Clothing",
    stock_quantity: 0,
    image_url: "https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=500"
  }
]

out_of_stock_products.each do |product_attrs|
  Product.create!(product_attrs)
  print "."
end

inactive_products = [
  {
    name: "Discontinued Laptop Model",
    description: "Previous generation laptop that is no longer available for purchase.",
    price: 899.99,
    category: "Electronics",
    stock_quantity: 5,
    active: false,
    image_url: "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500"
  }
]

inactive_products.each do |product_attrs|
  Product.create!(product_attrs)
  print "."
end

puts "\n✅ Created #{Product.count} products!"

puts "Creating completed orders..."

def create_order(user, products_data, status, days_ago = 0)
  order = user.orders.create!(
    email: user.email,
    first_name: user.first_name,
    last_name: user.last_name,
    address_line_1: "#{rand(100..9999)} #{['Main St', 'Oak Ave', 'Pine Rd', 'Elm Dr'].sample}",
    address_line_2: rand(1..10) > 7 ? "Apt #{rand(1..20)}" : nil,
    city: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'].sample,
    state: ['NY', 'CA', 'IL', 'TX', 'AZ'].sample,
    postal_code: sprintf("%05d", rand(10000..99999)),
    country: 'US',
    status: status,
    total_amount: 0, # Will be calculated
    created_at: days_ago.days.ago,
    updated_at: days_ago.days.ago
  )

  products_data.each do |product_data|
    product = Product.find_by(name: product_data[:name])
    next unless product

    order.order_items.create!(
      product: product,
      quantity: product_data[:quantity],
      unit_price: product.price,
      total_price: product.price * product_data[:quantity]
    )
  end

  order.update!(total_amount: order.order_items.sum(:total_price))
  order
end

create_order(user1, [
  { name: 'MacBook Pro 16-inch M3', quantity: 1 },
  { name: 'Sony WH-1000XM5 Headphones', quantity: 1 }
], 'delivered', 30)

create_order(user1, [
  { name: 'Levi\'s 501 Original Jeans', quantity: 2 },
  { name: 'Nike Air Max 270 Sneakers', quantity: 1 },
  { name: 'Champion Reverse Weave Hoodie', quantity: 1 }
], 'delivered', 15)

create_order(user1, [
  { name: 'iPhone 15 Pro Max', quantity: 1 },
  { name: 'Hydro Flask 32oz Water Bottle', quantity: 2 }
], 'shipped', 3)

create_order(user2, [
  { name: 'KitchenAid Stand Mixer', quantity: 1 },
  { name: 'Instant Pot Duo 7-in-1', quantity: 1 },
  { name: 'The Seven Husbands of Evelyn Hugo', quantity: 1 }
], 'delivered', 45)

create_order(user2, [
  { name: 'Samsung 65-inch QLED 4K TV', quantity: 1 },
  { name: 'Nintendo Switch OLED', quantity: 1 },
  { name: 'Patagonia Better Sweater Fleece', quantity: 1 }
], 'processing', 7)

puts "Creating current shopping carts..."

current_cart_john = user1.orders.create!(
  email: user1.email,
  first_name: user1.first_name,
  last_name: user1.last_name,
  address_line_1: '',
  city: '',
  state: '',
  postal_code: '',
  country: 'US',
  status: 'pending',
  total_amount: 0
)

current_cart_john.order_items.create!([
  {
    product: Product.find_by(name: 'iPad Air 11-inch'),
    quantity: 1,
    unit_price: Product.find_by(name: 'iPad Air 11-inch').price
  },
  {
    product: Product.find_by(name: 'Atomic Habits by James Clear'),
    quantity: 2,
    unit_price: Product.find_by(name: 'Atomic Habits by James Clear').price
  }
])

current_cart_john.update!(total_amount: current_cart_john.order_items.sum { |item| item.unit_price * item.quantity })

current_cart_jane = user2.orders.create!(
  email: user2.email,
  first_name: user2.first_name,
  last_name: user2.last_name,
  address_line_1: '',
  city: '',
  state: '',
  postal_code: '',
  country: 'US',
  status: 'pending',
  total_amount: 0
)

current_cart_jane.order_items.create!([
  {
    product: Product.find_by(name: 'Dyson V15 Detect Cordless Vacuum'),
    quantity: 1,
    unit_price: Product.find_by(name: 'Dyson V15 Detect Cordless Vacuum').price
  }
])

current_cart_jane.update!(total_amount: current_cart_jane.order_items.sum { |item| item.unit_price * item.quantity })

puts "✅ Created orders and shopping carts!"
puts "📊 Order summary:"
puts "   - Total orders: #{Order.count}"
puts "   - Completed orders: #{Order.where.not(status: 'pending').count}"
puts "   - Pending orders (carts): #{Order.where(status: 'pending').count}"
puts "   - Total order items: #{OrderItem.count}"

puts "\n👥 Test users created:"
puts "   📧 john@example.com (password: password123)"
puts "   📧 jane@example.com (password: password123)"

puts "\n🛍️ Order status breakdown:"
Order.group(:status).count.each do |status, count|
  puts "   - #{status.capitalize}: #{count}"
end

puts "\n🎉 Seed data creation complete!"