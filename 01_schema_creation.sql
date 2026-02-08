-- ============================================================================
-- DATABASE SCHEMA CREATION SCRIPT
-- Project: E-Commerce Sales Analytics System
-- Course: INSY 8311 - Database Development with PL/SQL
-- Author: [Your Name]
-- Date: February 8, 2026
-- ============================================================================

-- Drop existing tables if they exist (for clean rebuild)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ============================================================================
-- TABLE 1: CUSTOMERS
-- Purpose: Store customer master data including contact and regional info
-- ============================================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    region VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL,
    customer_segment VARCHAR(20),
    CONSTRAINT chk_region CHECK (region IN ('Africa', 'Europe', 'Asia')),
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%')
);

-- Create index for faster region-based queries
CREATE INDEX idx_customers_region ON customers(region);
CREATE INDEX idx_customers_reg_date ON customers(registration_date);

-- ============================================================================
-- TABLE 2: PRODUCTS
-- Purpose: Maintain product catalog with pricing and inventory
-- ============================================================================

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    CONSTRAINT chk_price_positive CHECK (unit_price > 0),
    CONSTRAINT chk_stock_nonnegative CHECK (stock_quantity >= 0),
    CONSTRAINT chk_category CHECK (category IN ('Electronics', 'Fashion', 'Home Goods', 'Sports', 'Books'))
);

-- Create index for category-based queries
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(unit_price);

-- ============================================================================
-- TABLE 3: ORDERS
-- Purpose: Record customer order transactions
-- ============================================================================

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT chk_amount_positive CHECK (total_amount > 0),
    CONSTRAINT chk_status CHECK (order_status IN ('Pending', 'Completed', 'Cancelled', 'Refunded'))
);

-- Create indexes for faster queries
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);

-- ============================================================================
-- TABLE 4: ORDER_ITEMS
-- Purpose: Store line-item details for each order (many-to-many between orders and products)
-- ============================================================================

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    item_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) 
        REFERENCES products(product_id) ON DELETE CASCADE,
    CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_item_price_positive CHECK (item_price > 0)
);

-- Create indexes for join operations
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check table structures
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order_Items', COUNT(*) FROM order_items;

-- Display table relationships
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- ============================================================================
-- END OF SCHEMA CREATION SCRIPT
-- ============================================================================
