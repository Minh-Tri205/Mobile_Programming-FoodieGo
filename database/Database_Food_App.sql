DROP DATABASE IF EXISTS FOOD_APP;
CREATE DATABASE FOOD_APP;
USE FOOD_APP;

-- 1. USERS (Người dùng: Khách hàng & Chủ quán) - PHIÊN BẢN SQL SERVER
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY, -- Thay AUTO_INCREMENT bằng IDENTITY(1,1)
    full_name NVARCHAR(100) NOT NULL,      -- Dùng NVARCHAR để gõ tiếng Việt có dấu
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    
    avatar_url VARCHAR(255) NULL,
    device_token VARCHAR(255) NULL, 

    -- SQL Server không có ENUM, dùng CHECK constraint thay thế
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'admin')), 

    -- SQL Server dùng BIT (0 hoặc 1) thay cho TINYINT(1)
    is_active BIT DEFAULT 1, 
    loyalty_points INT DEFAULT 0,

    -- SQL Server dùng GETDATE() thay cho CURRENT_TIMESTAMP
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- SQL Server tạo Index tách rời ở bên ngoài thay vì viết thẳng trong CREATE TABLE
CREATE INDEX idx_users_role ON users(role);

-- ============================================================
-- 2. CATEGORIES (Danh mục món ăn của quán)
-- ============================================================
CREATE TABLE categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL, -- Dùng NVARCHAR để lưu tiếng Việt
    image_url VARCHAR(255) NULL,
    is_active BIT DEFAULT 1      -- Dùng BIT thay cho TINYINT(1)
);

-- ============================================================
-- 3. FOOD ITEMS (Thực đơn của quán)
-- ============================================================
CREATE TABLE food_items (
    food_id INT IDENTITY(1,1) PRIMARY KEY,
    category_id INT NULL,
    name NVARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    
    image_url VARCHAR(255) NULL,
    description NVARCHAR(MAX) NULL, -- Dùng NVARCHAR(MAX) thay cho TEXT
    
    total_sold INT DEFAULT 0,
    is_active BIT DEFAULT 1,
    deleted_at DATETIME NULL,
    
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ============================================================
-- 4. CARTS (Giỏ hàng)
-- ============================================================
CREATE TABLE carts (
    cart_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE cart_items (
    cart_item_id INT IDENTITY(1,1) PRIMARY KEY,
    cart_id INT,
    food_id INT,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    unit_price DECIMAL(10,2),
    UNIQUE(cart_id, food_id),
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES food_items(food_id)
);

-- ============================================================
-- 5. VOUCHERS (Mã giảm giá của quán)
-- ============================================================
CREATE TABLE vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    min_order_value DECIMAL(10,2) DEFAULT 0,
    start_date DATETIME,
    end_date DATETIME,
    usage_limit INT DEFAULT 1,
    is_active BIT DEFAULT 1
);

-- ============================================================
-- 6. ORDERS (Đơn hàng)
-- ============================================================
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    order_code VARCHAR(50) UNIQUE, -- Tăng độ dài để chứa mã NEWID()
    
    -- Thông tin giao hàng
    delivery_address NVARCHAR(255) NOT NULL,
    delivery_phone VARCHAR(15) NOT NULL,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    note NVARCHAR(MAX) NULL,
    
    -- Khuyến mãi
    voucher_id INT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    
    -- SQL Server không dùng ENUM, dùng CHECK CONSTRAINT
    status VARCHAR(20) DEFAULT 'pending' 
        CHECK (status IN ('pending', 'confirmed', 'preparing', 'delivering', 'completed', 'cancelled')),
    
    total_amount DECIMAL(10,2),
    created_at DATETIME DEFAULT GETDATE(), -- Dùng GETDATE() thay CURRENT_TIMESTAMP
    updated_at DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id)
);

CREATE TABLE order_items (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    food_id INT,
    quantity INT CHECK (quantity > 0),
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES food_items(food_id)
);

-- ============================================================
-- 7. REVIEWS & NOTIFICATIONS
-- ============================================================
CREATE TABLE reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT UNIQUE,
    user_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE notifications (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    title NVARCHAR(255),
    body NVARCHAR(MAX),
    is_read BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 8. DỮ LIỆU MẪU (SAMPLE DATA) - Thêm 'N' phía trước để lưu Tiếng Việt
-- ============================================================
INSERT INTO categories (name) VALUES (N'Món Nước'), (N'Cơm Văn Phòng'), (N'Đồ Uống');

INSERT INTO food_items(name, price, category_id) VALUES
(N'Phở Bò Đặc Biệt', 50000, 1),
(N'Cơm Sườn Nướng', 45000, 2),
(N'Trà Đào Cam Sả', 25000, 3);

INSERT INTO vouchers(code, discount_amount, min_order_value) VALUES
('GIAM10K', 10000, 50000);

-- ============================================================
-- 9. FUNCTIONS, PROCEDURES & TRIGGERS (Cú pháp T-SQL)
-- ============================================================

-- 9.1 FUNCTION: Tính tổng tiền đồ ăn
CREATE FUNCTION dbo.fn_order_total(@p_order_id INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);
    SELECT @total = SUM(quantity * unit_price) 
    FROM order_items
    WHERE order_id = @p_order_id;
    
    RETURN ISNULL(@total, 0);
END

-- 9.2 PROCEDURE: Khách hàng đặt hàng
CREATE PROCEDURE sp_place_order
    @p_user_id INT,
    @p_delivery_address NVARCHAR(255),
    @p_delivery_phone VARCHAR(15),
    @p_delivery_fee DECIMAL(10,2),
    @p_voucher_id INT,
    @p_note NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @new_order_id INT;
    DECLARE @v_total_food_amount DECIMAL(10,2);
    DECLARE @v_discount DECIMAL(10,2) = 0;
    DECLARE @v_final_amount DECIMAL(10,2);

    -- Xử lý Voucher
    IF @p_voucher_id IS NOT NULL
    BEGIN
        SELECT @v_discount = discount_amount 
        FROM vouchers 
        WHERE voucher_id = @p_voucher_id AND is_active = 1;
    END

    -- Tạo đơn hàng mới (Dùng NEWID() thay cho UUID())
    INSERT INTO orders(user_id, order_code, delivery_address, delivery_phone, delivery_fee, voucher_id, discount_amount, note, total_amount)
    VALUES(@p_user_id, CAST(NEWID() AS VARCHAR(50)), @p_delivery_address, @p_delivery_phone, @p_delivery_fee, @p_voucher_id, @v_discount, @p_note, 0);

    -- Lấy ID của order vừa tạo (Dùng SCOPE_IDENTITY thay cho LAST_INSERT_ID)
    SET @new_order_id = SCOPE_IDENTITY();

    -- Chuyển từ giỏ hàng sang chi tiết đơn hàng
    INSERT INTO order_items(order_id, food_id, quantity, unit_price)
    SELECT @new_order_id, ci.food_id, ci.quantity, ci.unit_price
    FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    WHERE c.user_id = @p_user_id;

    -- Tính tổng tiền thực tế
    SET @v_total_food_amount = dbo.fn_order_total(@new_order_id);
    SET @v_final_amount = @v_total_food_amount + @p_delivery_fee - @v_discount;
    
    -- Đảm bảo tiền không bị âm
    IF @v_final_amount < 0 SET @v_final_amount = 0;

    UPDATE orders 
    SET total_amount = @v_final_amount
    WHERE order_id = @new_order_id;

    -- Xoá giỏ hàng
    DELETE ci 
    FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    WHERE c.user_id = @p_user_id;
END

-- 9.3 TRIGGER 1: Thông báo cho CHỦ QUÁN khi có đơn mới
CREATE TRIGGER trg_after_order_created
ON orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO notifications (user_id, title, body)
    SELECT u.user_id, N'CÓ ĐƠN HÀNG MỚI!', N'Khách hàng vừa đặt đơn. Mã đơn: ' + i.order_code
    FROM users u
    CROSS JOIN inserted i
    WHERE u.role = 'admin';
END

-- 9.4 TRIGGER 2: Tăng số lượt bán (total_sold) khi đơn hoàn thành (completed)
CREATE TRIGGER trg_after_order_completed
ON orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra nếu trạng thái chuyển thành 'completed'
    IF UPDATE(status)
    BEGIN
        -- Cập nhật lượt bán
        UPDATE f
        SET f.total_sold = f.total_sold + oi.quantity
        FROM food_items f
        JOIN order_items oi ON f.food_id = oi.food_id
        JOIN inserted i ON oi.order_id = i.order_id
        JOIN deleted d ON i.order_id = d.order_id
        WHERE i.status = 'completed' AND d.status <> 'completed';
        
        -- Cộng điểm cho khách
        UPDATE u
        SET u.loyalty_points = u.loyalty_points + 10
        FROM users u
        JOIN inserted i ON u.user_id = i.user_id
        JOIN deleted d ON i.order_id = d.order_id
        WHERE i.status = 'completed' AND d.status <> 'completed';
    END
END
