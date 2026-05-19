-- Migration 001: Add Payment Method Support
-- This migration adds payment method support to the orders table
-- Supports: COD (Cash On Delivery) and BANK_TRANSFER

-- Add payment_method column to orders table
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'orders' AND COLUMN_NAME = 'payment_method'
)
BEGIN
    ALTER TABLE orders
    ADD payment_method VARCHAR(20) DEFAULT 'COD' 
        CHECK (payment_method IN ('COD', 'BANK_TRANSFER'));
    
    PRINT 'Column payment_method added to orders table successfully';
END
ELSE
BEGIN
    PRINT 'Column payment_method already exists in orders table';
END

-- Create index for payment method queries
CREATE INDEX idx_orders_payment_method ON orders(payment_method);

-- Create bank transfer details table
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'bank_transfer_details'
)
BEGIN
    CREATE TABLE bank_transfer_details (
        detail_id INT IDENTITY(1,1) PRIMARY KEY,
        bank_name NVARCHAR(100) NOT NULL,
        account_number VARCHAR(50) NOT NULL,
        account_owner NVARCHAR(100) NOT NULL,
        qr_code_url VARCHAR(255) NULL,
        payment_instructions NVARCHAR(MAX) NULL,
        is_active BIT DEFAULT 1,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE()
    );
    
    PRINT 'bank_transfer_details table created successfully';
    
    -- Insert sample bank transfer details
    INSERT INTO bank_transfer_details (bank_name, account_number, account_owner, payment_instructions)
    VALUES 
        (N'Ngân hàng Vietcombank', '1234567890', N'FoodieGo Restaurant', N'Chuyển khoản nhanh (VCB) để xác nhận đơn hàng'),
        (N'Ngân hàng Techcombank', '0987654321', N'FoodieGo Restaurant', N'Sử dụng tính năng chuyển khoản 24/7');
END
ELSE
BEGIN
    PRINT 'bank_transfer_details table already exists';
END
