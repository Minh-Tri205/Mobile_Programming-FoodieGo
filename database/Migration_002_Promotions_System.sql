-- Migration 002: Create Promotions Management System
-- This migration adds support for promotion/discount management

-- Create promotions table
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'promotions'
)
BEGIN
    CREATE TABLE promotions (
        promotion_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX) NULL,
        
        -- Discount type: FIXED (fixed amount) or PERCENTAGE (percentage discount)
        discount_type VARCHAR(20) NOT NULL 
            CHECK (discount_type IN ('FIXED', 'PERCENTAGE')),
        discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
        
        -- Date range
        start_date DATETIME NOT NULL,
        end_date DATETIME NOT NULL,
        
        -- Validation rules
        min_order_amount DECIMAL(10,2) DEFAULT 0,
        max_discount DECIMAL(10,2) NULL, -- Maximum discount for percentage type
        usage_limit INT NULL, -- NULL = unlimited
        usage_count INT DEFAULT 0,
        
        -- Status
        status VARCHAR(20) DEFAULT 'ACTIVE' 
            CHECK (status IN ('ACTIVE', 'INACTIVE')),
        is_deleted BIT DEFAULT 0,
        
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE()
    );
    
    PRINT 'promotions table created successfully';
    
    -- Create indexes
    CREATE INDEX idx_promotions_status ON promotions(status);
    CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date);
    CREATE INDEX idx_promotions_deleted ON promotions(is_deleted);
END
ELSE
BEGIN
    PRINT 'promotions table already exists';
END

-- Create promotions_products junction table
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'promotions_products'
)
BEGIN
    CREATE TABLE promotions_products (
        promotion_product_id INT IDENTITY(1,1) PRIMARY KEY,
        promotion_id INT NOT NULL,
        food_id INT NOT NULL,
        UNIQUE(promotion_id, food_id),
        FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
        FOREIGN KEY (food_id) REFERENCES food_items(food_id) ON DELETE CASCADE
    );
    
    PRINT 'promotions_products table created successfully';
    
    CREATE INDEX idx_promotions_products_promo ON promotions_products(promotion_id);
    CREATE INDEX idx_promotions_products_food ON promotions_products(food_id);
END
ELSE
BEGIN
    PRINT 'promotions_products table already exists';
END

-- Create promotions_categories junction table
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'promotions_categories'
)
BEGIN
    CREATE TABLE promotions_categories (
        promotion_category_id INT IDENTITY(1,1) PRIMARY KEY,
        promotion_id INT NOT NULL,
        category_id INT NOT NULL,
        UNIQUE(promotion_id, category_id),
        FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
    );
    
    PRINT 'promotions_categories table created successfully';
    
    CREATE INDEX idx_promotions_categories_promo ON promotions_categories(promotion_id);
    CREATE INDEX idx_promotions_categories_cat ON promotions_categories(category_id);
END
ELSE
BEGIN
    PRINT 'promotions_categories table already exists';
END

-- Update vouchers table to link with promotions
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'vouchers' AND COLUMN_NAME = 'promotion_id'
)
BEGIN
    ALTER TABLE vouchers
    ADD promotion_id INT NULL,
    CONSTRAINT fk_vouchers_promotions FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id);
    
    PRINT 'Column promotion_id added to vouchers table';
END
ELSE
BEGIN
    PRINT 'Column promotion_id already exists in vouchers table';
END
