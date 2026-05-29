-- ============================================================
-- DATABASE: FOOD_APP v2
-- Cập nhật theo giao diện ứng dụng đặt đồ ăn
-- ============================================================
DROP DATABASE IF EXISTS FOOD_APP;
CREATE DATABASE FOOD_APP;
USE FOOD_APP;

-- ============================================================
-- 1. USERS (Khách hàng & Admin)
-- ============================================================
-- [THÊM] password_reset_token, reset_token_expiry  → Tính năng "Quên mật khẩu"
-- [GIỮ]  loyalty_points                            → Điểm tích lũy thành viên (Hồ sơ)
-- [GIỮ]  avatar_url, device_token                  → Ảnh đại diện & push notification
CREATE TABLE users (
    user_id           INT           IDENTITY(1,1) PRIMARY KEY,
    full_name         NVARCHAR(100) NOT NULL,
    email             VARCHAR(100)  UNIQUE,
    phone             VARCHAR(15)   UNIQUE,
    password_hash     VARCHAR(255)  NOT NULL,
    avatar_url        VARCHAR(255)  NULL,
    device_token      VARCHAR(255)  NULL,
    role              VARCHAR(10)   DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
    is_active         BIT           DEFAULT 1,
    loyalty_points    INT           DEFAULT 0,

    -- [MỚI] Quên mật khẩu
    password_reset_token       VARCHAR(255) NULL,
    reset_token_expiry         DATETIME     NULL,

    created_at        DATETIME DEFAULT GETDATE(),
    updated_at        DATETIME DEFAULT GETDATE()
);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================
-- 2. ADDRESSES (Địa chỉ của tôi - Hồ sơ)
-- ============================================================
-- [MỚI] Bảng riêng để quản lý nhiều địa chỉ giao hàng (Hồ sơ → "Địa chỉ của tôi")
--       Khi đặt hàng, cho phép chọn từ danh sách địa chỉ đã lưu
CREATE TABLE addresses (
    address_id    INT           IDENTITY(1,1) PRIMARY KEY,
    user_id       INT           NOT NULL,
    label         NVARCHAR(50)  NULL,           -- VD: "Nhà", "Cơ quan"
    full_address  NVARCHAR(255) NOT NULL,
    recipient_name  NVARCHAR(100) NULL,
    recipient_phone VARCHAR(15)   NULL,
    is_default    BIT           DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================
-- 3. PAYMENT METHODS (Phương thức thanh toán - Hồ sơ)
-- ============================================================
-- [MỚI] Hồ sơ → "Phương thức thanh toán"
CREATE TABLE payment_methods (
    payment_method_id INT           IDENTITY(1,1) PRIMARY KEY,
    user_id           INT           NOT NULL,
    method_type       VARCHAR(20)   NOT NULL CHECK (method_type IN ('cash', 'momo', 'vnpay', 'zalopay', 'credit_card', 'bank_transfer')),
    display_name      NVARCHAR(100) NULL,        -- VD: "MoMo - 09xxxxxxxx"
    is_default        BIT           DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================
-- 4. CATEGORIES (Danh mục món ăn)
-- ============================================================
CREATE TABLE categories (
    category_id INT           IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100) NOT NULL,
    image_url   VARCHAR(255)  NULL,
    is_active   BIT           DEFAULT 1
);

-- ============================================================
-- 5. FOOD ITEMS (Thực đơn)
-- ============================================================
-- [THÊM] stock_quantity  → Số món còn hàng (Chi tiết thực đơn)
-- [THÊM] avg_rating      → Số sao trung bình (Chi tiết thực đơn, Trang chủ)
-- [GIỮ]  total_sold      → Số món đã bán (Chi tiết thực đơn, Xu hướng/Phổ biến)
-- [GIỮ]  description     → Mô tả (Chi tiết thực đơn)
CREATE TABLE food_items (
    food_id        INT            IDENTITY(1,1) PRIMARY KEY,
    category_id    INT            NULL,
    name           NVARCHAR(150)  NOT NULL,
    price          DECIMAL(10,2)  NOT NULL CHECK (price >= 0),
    image_url      VARCHAR(255)   NULL,
    description    NVARCHAR(MAX)  NULL,
    total_sold     INT            DEFAULT 0,

    -- [MỚI] Trang chi tiết món ăn
    stock_quantity INT            DEFAULT 0,     -- Số lượng còn hàng
    avg_rating     DECIMAL(3,2)   DEFAULT 0,     -- Số sao TB (cập nhật qua trigger)

    is_active      BIT            DEFAULT 1,
    deleted_at     DATETIME       NULL,           -- Soft delete (admin xóa)
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
-- Index hỗ trợ Tìm kiếm & Xu hướng/Phổ biến (Trang chủ)
CREATE INDEX idx_food_name       ON food_items(name);
CREATE INDEX idx_food_total_sold ON food_items(total_sold DESC);
CREATE INDEX idx_food_avg_rating ON food_items(avg_rating DESC);

-- ============================================================
-- 6. FAVORITES (Món ăn yêu thích - Hồ sơ)
-- ============================================================
-- [MỚI] Hồ sơ → "Món ăn yêu thích"
CREATE TABLE favorites (
    favorite_id INT      IDENTITY(1,1) PRIMARY KEY,
    user_id     INT      NOT NULL,
    food_id     INT      NOT NULL,
    created_at  DATETIME DEFAULT GETDATE(),
    UNIQUE (user_id, food_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES food_items(food_id)
);

-- ============================================================
-- 7. CARTS (Giỏ hàng)
-- ============================================================
-- [GIỮ] Cấu trúc gốc, đủ hỗ trợ: chọn nhiều sản phẩm, tăng/giảm số lượng
CREATE TABLE carts (
    cart_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE cart_items (
    cart_item_id INT           IDENTITY(1,1) PRIMARY KEY,
    cart_id      INT           NOT NULL,
    food_id      INT           NOT NULL,
    quantity     INT           DEFAULT 1 CHECK (quantity > 0),
    unit_price   DECIMAL(10,2) NOT NULL,
    is_selected  BIT           DEFAULT 1,   -- [MỚI] Giỏ hàng: tick chọn sản phẩm để thanh toán
    UNIQUE (cart_id, food_id),
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES food_items(food_id)
);

-- ============================================================
-- 8. VOUCHERS (Mã giảm giá)
-- ============================================================
-- [GIỮ] Cấu trúc gốc - dùng ở Trang chủ & Giỏ hàng & Xác nhận đơn
CREATE TABLE vouchers (
    voucher_id      INT           IDENTITY(1,1) PRIMARY KEY,
    code            VARCHAR(50)   UNIQUE NOT NULL,
    description     NVARCHAR(255) NULL,           -- [MỚI] Mô tả voucher hiển thị trên UI
    discount_amount DECIMAL(10,2) NOT NULL,
    min_order_value DECIMAL(10,2) DEFAULT 0,
    start_date      DATETIME      NULL,
    end_date        DATETIME      NULL,
    usage_limit     INT           DEFAULT 1,       -- Tổng lượt dùng tối đa
    is_active       BIT           DEFAULT 1
);

-- ============================================================
-- 9. VOUCHER USAGE (Lịch sử dùng mã giảm giá)
-- ============================================================
-- [MỚI] Theo dõi mỗi user đã dùng voucher nào, tránh dùng lại
CREATE TABLE voucher_usage (
    usage_id   INT      IDENTITY(1,1) PRIMARY KEY,
    voucher_id INT      NOT NULL,
    user_id    INT      NOT NULL,
    order_id   INT      NULL,                      -- NULL trước khi đơn hoàn thành
    used_at    DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)
);

-- ============================================================
-- 10. ORDERS (Đơn hàng)
-- ============================================================
-- [SỬA] Thêm trạng thái 'shipping' (đang giao) để map với tab "Đang giao" (Lịch sử đơn hàng)
-- [THÊM] payment_method  → Phương thức thanh toán khi đặt hàng
-- [THÊM] address_id      → Liên kết địa chỉ đã lưu (tùy chọn)
CREATE TABLE orders (
    order_id          INT            IDENTITY(1,1) PRIMARY KEY,
    user_id           INT            NOT NULL,
    order_code        VARCHAR(50)    UNIQUE NOT NULL,

    -- Thông tin giao hàng (Màn hình Xác nhận đơn hàng)
    recipient_name    NVARCHAR(100)  NOT NULL,     -- [MỚI] Tên người nhận
    delivery_address  NVARCHAR(255)  NOT NULL,
    delivery_phone    VARCHAR(15)    NOT NULL,
    delivery_fee      DECIMAL(10,2)  DEFAULT 0,
    note              NVARCHAR(MAX)  NULL,
    address_id        INT            NULL,          -- [MỚI] FK địa chỉ đã lưu (tuỳ chọn)

    -- Thanh toán
    payment_method    VARCHAR(20)    DEFAULT 'cash' CHECK (payment_method IN ('cash', 'momo', 'vnpay', 'zalopay', 'credit_card', 'bank_transfer')),

    -- Khuyến mãi
    voucher_id        INT            NULL,
    discount_amount   DECIMAL(10,2)  DEFAULT 0,

    -- Trạng thái đơn hàng
    -- pending   → Chờ xác nhận
    -- confirmed → Đã xác nhận
    -- preparing → Đang chuẩn bị
    -- shipping  → Đang giao (Tab "Đang giao" - Lịch sử đơn hàng)
    -- completed → Hoàn thành (Tab "Hoàn thành" - mới được đánh giá)
    -- cancelled → Đã hủy    (Tab "Đã hủy")
    status            VARCHAR(20)    DEFAULT 'pending'
                        CHECK (status IN ('pending', 'confirmed', 'preparing', 'shipping', 'completed', 'cancelled')),

    total_amount      DECIMAL(10,2)  DEFAULT 0,
    created_at        DATETIME       DEFAULT GETDATE(),
    updated_at        DATETIME       DEFAULT GETDATE(),

    FOREIGN KEY (user_id)    REFERENCES users(user_id),
    FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id),
    FOREIGN KEY (address_id) REFERENCES addresses(address_id)
);

CREATE INDEX idx_orders_user_status ON orders(user_id, status);

CREATE TABLE order_items (
    order_item_id INT           IDENTITY(1,1) PRIMARY KEY,
    order_id      INT           NOT NULL,
    food_id       INT           NOT NULL,
    quantity      INT           CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (food_id)  REFERENCES food_items(food_id)
);

-- ============================================================
-- 11. ORDER TRACKING (Theo dõi đơn hàng)
-- ============================================================
-- [MỚI] Lịch sử trạng thái đơn hàng → Nút "Theo dõi đơn hàng" (Lịch sử đơn hàng)
CREATE TABLE order_tracking (
    tracking_id  INT           IDENTITY(1,1) PRIMARY KEY,
    order_id     INT           NOT NULL,
    status       VARCHAR(20)   NOT NULL,
    description  NVARCHAR(255) NULL,              -- VD: "Quán đang chuẩn bị đơn của bạn"
    created_at   DATETIME      DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- ============================================================
-- 12. REVIEWS (Đánh giá đơn hàng)
-- ============================================================
-- [GIỮ] Ràng buộc: chỉ đánh giá khi đơn 'completed' → xử lý ở tầng ứng dụng / trigger
-- [THÊM] food_id → Đánh giá gắn với từng món, hiển thị ở Chi tiết thực đơn
CREATE TABLE reviews (
    review_id  INT          IDENTITY(1,1) PRIMARY KEY,
    order_id   INT          UNIQUE NOT NULL,      -- 1 đơn → 1 đánh giá
    user_id    INT          NOT NULL,
    food_id    INT          NULL,                  -- [MỚI] Món ăn được đánh giá
    rating     INT          NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    NVARCHAR(MAX) NULL,
    created_at DATETIME     DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id)  REFERENCES users(user_id),
    FOREIGN KEY (food_id)  REFERENCES food_items(food_id)
);

-- ============================================================
-- 13. NOTIFICATIONS (Thông báo)
-- ============================================================
-- [SỬA] Thêm notification_type để phân loại thông báo
--       Màn hình thông báo gồm: tình trạng đơn hàng | ưu đãi | đánh giá | tích điểm
CREATE TABLE notifications (
    notification_id   INT           IDENTITY(1,1) PRIMARY KEY,
    user_id           INT           NOT NULL,
    title             NVARCHAR(255) NOT NULL,
    body              NVARCHAR(MAX) NULL,
    notification_type VARCHAR(20)   DEFAULT 'order'
                        CHECK (notification_type IN ('order', 'promotion', 'review', 'loyalty')),
    related_id        INT           NULL,          -- [MỚI] order_id / voucher_id tương ứng
    is_read           BIT           DEFAULT 0,
    created_at        DATETIME      DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

-- ============================================================
-- 14. DỮ LIỆU MẪU (SAMPLE DATA)
-- ============================================================
INSERT INTO categories (name, is_active) VALUES
(N'Món Nước', 1),
(N'Cơm Văn Phòng', 1),
(N'Đồ Uống', 1),
(N'Bánh Mì', 1),
(N'Đồ Ăn Vặt', 1),
(N'Lẩu', 1),
(N'Món Chay', 1),
(N'Hải Sản', 1),
(N'Gà Rán', 1),
(N'Tráng Miệng', 1),
(N'Bún - Miến', 1),
(N'Cà Phê', 1),
(N'Sinh Tố', 1),
(N'Trà Sữa', 1),
(N'Pizza', 1),
(N'Mì Cay', 1),
(N'Bánh Ngọt', 1),
(N'Đồ Nướng', 1),
(N'Salad', 1),
(N'Sushi', 1),
(N'Kem', 1),
(N'Nước Ép', 1),
(N'Đồ Hàn', 1),
(N'Đồ Nhật', 1),
(N'Combo Tiết Kiệm', 1);

INSERT INTO food_items (name, price, category_id, description, stock_quantity, avg_rating) VALUES
(N'Phở Bò Đặc Biệt',   50000, 1, N'Phở bò tái nạm gầu gân, nước dùng ninh xương 8 tiếng', 50, 4.8),
(N'Cơm Sườn Nướng',    45000, 2, N'Cơm trắng + sườn nướng mật ong + canh rau', 40, 4.6),
(N'Trà Đào Cam Sả',    25000, 3, N'Trà đào tươi kết hợp cam và sả', 100, 4.7),
(N'Bánh Mì Thịt Nướng',30000, 4, N'Bánh mì giòn nhân thịt nướng + rau sống', 60, 4.5),
(N'Bò Lúc Lắc',        75000, 2, N'Bò Mỹ xào lúc lắc, ăn kèm cơm chiên dương châu', 30, 4.9),
(N'Bún Bò Huế',            55000, 1, N'Bún bò cay nhẹ, topping đầy đủ', 45, 4.7),
(N'Miến Gà Ta',            50000, 11, N'Miến dai ăn cùng gà ta xé', 35, 4.6),
(N'Cơm Gà Xối Mỡ',         48000, 2, N'Gà chiên giòn ăn kèm cơm và dưa chua', 50, 4.5),
(N'Cơm Cá Kho Tộ',         52000, 2, N'Cá basa kho tiêu ăn kèm canh rau', 40, 4.4),
(N'Trà Sữa Trân Châu',     32000, 14, N'Trà sữa truyền thống cùng trân châu đen', 120, 4.8),
(N'Cà Phê Sữa Đá',         22000, 12, N'Cà phê rang xay nguyên chất', 150, 4.7),
(N'Sinh Tố Bơ',            35000, 13, N'Sinh tố bơ béo mịn', 70, 4.6),
(N'Pizza Hải Sản',         120000, 15, N'Pizza phủ tôm mực và phô mai', 25, 4.9),
(N'Mì Cay Hải Sản',        65000, 16, N'Mì cay cấp độ 3 với tôm và mực', 30, 4.5),
(N'Salad Ức Gà',           45000, 19, N'Salad rau xanh cùng ức gà áp chảo', 55, 4.4),
(N'Sushi Cá Hồi',          90000, 20, N'Sushi cá hồi tươi nhập khẩu', 20, 4.9),
(N'Kem Vanilla',           20000, 21, N'Kem vanilla mát lạnh', 90, 4.3),
(N'Nước Ép Cam',           28000, 22, N'Nước cam nguyên chất không đường', 100, 4.7),
(N'Gà Rán Giòn Cay',       55000, 9, N'Gà rán phủ sốt cay Hàn Quốc', 60, 4.8),
(N'Bánh Flan Caramel',     18000, 10, N'Bánh flan mềm mịn thơm caramel', 80, 4.5),
(N'Bánh Tiramisu',         45000, 17, N'Bánh tiramisu vị cà phê Ý', 25, 4.8),
(N'Combo Burger + Coke',   79000, 25, N'Combo burger bò và coca lạnh', 40, 4.6),
(N'Lẩu Thái Hải Sản',      180000, 6, N'Lẩu thái chua cay với tôm mực', 15, 4.9),
(N'Đậu Hũ Chiên Sả Ớt',    35000, 7, N'Món chay đậm vị ăn kèm cơm trắng', 45, 4.4),
(N'Bạch Tuộc Nướng Sa Tế', 99000, 18, N'Bạch tuộc nướng cay thơm', 20, 4.7);

INSERT INTO vouchers (code, description, discount_amount, min_order_value, usage_limit) VALUES
('GIAM10K', N'Giảm 10.000đ cho đơn từ 50.000đ', 10000, 50000, 100),
('GIAM20K', N'Giảm 20.000đ cho đơn từ 100.000đ', 20000, 100000, 50),
('FREESHIP', N'Miễn phí vận chuyển cho đơn từ 30.000đ', 15000, 30000, 200),
('GIAM5K',     N'Giảm 5.000đ cho đơn từ 20.000đ', 5000, 20000, 150),
('GIAM15K',    N'Giảm 15.000đ cho đơn từ 80.000đ', 15000, 80000, 100),
('GIAM30K',    N'Giảm 30.000đ cho đơn từ 150.000đ', 30000, 150000, 70),
('GIAM50K',    N'Giảm 50.000đ cho đơn từ 300.000đ', 50000, 300000, 30),
('WELCOME10',  N'Ưu đãi khách hàng mới giảm 10.000đ', 10000, 40000, 500),
('LUNCH20',    N'Giảm 20.000đ cho đơn buổi trưa', 20000, 120000, 80),
('DINNER25',   N'Giảm 25.000đ cho đơn buổi tối', 25000, 150000, 60),
('TEA15',      N'Giảm 15.000đ cho đồ uống', 15000, 50000, 120),
('SNACK10',    N'Giảm 10.000đ cho đồ ăn vặt', 10000, 40000, 100),
('WEEKEND50',  N'Giảm 50.000đ cuối tuần', 50000, 250000, 40),
('VIP100',     N'Ưu đãi VIP giảm 100.000đ', 100000, 500000, 10),
('SHIPFREE50', N'Miễn phí ship đơn từ 50.000đ', 20000, 50000, 150),
('COMBO30',    N'Giảm 30.000đ cho combo gia đình', 30000, 200000, 50),
('SAVE25',     N'Tiết kiệm 25.000đ cho đơn lớn', 25000, 180000, 70),
('HOTDEAL10',  N'Hot deal giảm ngay 10.000đ', 10000, 60000, 200),
('APPONLY20',  N'Giảm 20.000đ khi đặt qua app', 20000, 90000, 90),
('MAYSALE15',  N'Khuyến mãi tháng 5 giảm 15.000đ', 15000, 70000, 110),
('FOODIE30',   N'Voucher foodie giảm 30.000đ', 30000, 160000, 75),
('SUPER50',    N'Siêu ưu đãi giảm 50.000đ', 50000, 350000, 20),
('NEWYEAR99',  N'Khuyến mãi năm mới giảm 99.000đ', 99000, 600000, 15);

-- ============================================================
-- 15. FUNCTIONS
-- ============================================================

-- 15.1 Tính tổng tiền đồ ăn của đơn hàng
CREATE FUNCTION dbo.fn_order_total(@p_order_id INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);
    SELECT @total = SUM(quantity * unit_price)
    FROM order_items
    WHERE order_id = @p_order_id;
    RETURN ISNULL(@total, 0);
END;

-- 15.2 Kiểm tra voucher hợp lệ (dùng trong app trước khi apply)
CREATE FUNCTION dbo.fn_validate_voucher(@p_code VARCHAR(50), @p_user_id INT, @p_order_total DECIMAL(10,2))
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @result NVARCHAR(100);
    DECLARE @v_id INT, @v_min DECIMAL(10,2), @v_limit INT, @v_used INT;
    DECLARE @v_start DATETIME, @v_end DATETIME;

    SELECT @v_id = voucher_id, @v_min = min_order_value,
           @v_limit = usage_limit, @v_start = start_date, @v_end = end_date
    FROM vouchers
    WHERE code = @p_code AND is_active = 1;

    IF @v_id IS NULL                             SET @result = N'Mã không tồn tại hoặc đã hết hiệu lực'
    ELSE IF @p_order_total < @v_min              SET @result = N'Đơn hàng chưa đạt giá trị tối thiểu'
    ELSE IF @v_start IS NOT NULL AND GETDATE() < @v_start SET @result = N'Mã chưa đến thời gian sử dụng'
    ELSE IF @v_end   IS NOT NULL AND GETDATE() > @v_end   SET @result = N'Mã đã hết hạn'
    ELSE
    BEGIN
        SELECT @v_used = COUNT(*) FROM voucher_usage WHERE voucher_id = @v_id;
        IF @v_used >= @v_limit                   SET @result = N'Mã đã được dùng hết'
        ELSE                                     SET @result = N'OK'
    END
    RETURN @result;
END;

-- ============================================================
-- 16. STORED PROCEDURES
-- ============================================================

-- 16.1 Đặt hàng (từ giỏ hàng, dựa vào is_selected)
CREATE PROCEDURE sp_place_order
    @p_user_id        INT,
    @p_recipient_name NVARCHAR(100),
    @p_delivery_address NVARCHAR(255),
    @p_delivery_phone VARCHAR(15),
    @p_delivery_fee   DECIMAL(10,2),
    @p_voucher_code   VARCHAR(50),
    @p_note           NVARCHAR(MAX),
    @p_payment_method VARCHAR(20),
    @p_address_id     INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @new_order_id INT;
        DECLARE @v_voucher_id INT = NULL;
        DECLARE @v_discount   DECIMAL(10,2) = 0;
        DECLARE @v_total_food DECIMAL(10,2);
        DECLARE @v_final      DECIMAL(10,2);
        DECLARE @v_order_code VARCHAR(50) = CAST(NEWID() AS VARCHAR(50));

        -- Xử lý voucher
        IF @p_voucher_code IS NOT NULL AND @p_voucher_code <> ''
        BEGIN
            SELECT @v_voucher_id = voucher_id, @v_discount = discount_amount
            FROM vouchers
            WHERE code = @p_voucher_code AND is_active = 1;
        END

        -- Tạo đơn hàng
        INSERT INTO orders (user_id, order_code, recipient_name, delivery_address, delivery_phone,
                            delivery_fee, note, voucher_id, discount_amount, payment_method,
                            address_id, total_amount)
        VALUES (@p_user_id, @v_order_code, @p_recipient_name, @p_delivery_address, @p_delivery_phone,
                @p_delivery_fee, @p_note, @v_voucher_id, @v_discount, @p_payment_method,
                @p_address_id, 0);

        SET @new_order_id = SCOPE_IDENTITY();

        -- Chuyển các sản phẩm ĐƯỢC CHỌN từ giỏ hàng sang order_items
        INSERT INTO order_items (order_id, food_id, quantity, unit_price)
        SELECT @new_order_id, ci.food_id, ci.quantity, ci.unit_price
        FROM cart_items ci
        JOIN carts c ON ci.cart_id = c.cart_id
        WHERE c.user_id = @p_user_id AND ci.is_selected = 1;

        -- Tính & cập nhật tổng tiền
        SET @v_total_food = dbo.fn_order_total(@new_order_id);
        SET @v_final = @v_total_food + @p_delivery_fee - @v_discount;
        IF @v_final < 0 SET @v_final = 0;

        UPDATE orders SET total_amount = @v_final WHERE order_id = @new_order_id;

        -- Ghi nhận sử dụng voucher
        IF @v_voucher_id IS NOT NULL
            INSERT INTO voucher_usage (voucher_id, user_id, order_id)
            VALUES (@v_voucher_id, @p_user_id, @new_order_id);

        -- Ghi tracking trạng thái đầu tiên
        INSERT INTO order_tracking (order_id, status, description)
        VALUES (@new_order_id, 'pending', N'Đơn hàng đã được đặt, đang chờ quán xác nhận');

        -- Xóa các sản phẩm đã chọn khỏi giỏ hàng
        DELETE ci
        FROM cart_items ci
        JOIN carts c ON ci.cart_id = c.cart_id
        WHERE c.user_id = @p_user_id AND ci.is_selected = 1;

        COMMIT TRANSACTION;
        SELECT @new_order_id AS new_order_id, @v_order_code AS order_code;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

-- 16.2 Cập nhật trạng thái đơn hàng (dùng phía Admin)
CREATE PROCEDURE sp_update_order_status
    @p_order_id INT,
    @p_new_status VARCHAR(20),
    @p_description NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE orders
    SET status = @p_new_status, updated_at = GETDATE()
    WHERE order_id = @p_order_id;

    -- Ghi log tracking
    INSERT INTO order_tracking (order_id, status, description)
    VALUES (@p_order_id, @p_new_status, @p_description);
END;

-- 16.3 Khách hàng gửi đánh giá (chỉ khi đơn completed, chưa đánh giá)
CREATE PROCEDURE sp_submit_review
    @p_order_id INT,
    @p_user_id  INT,
    @p_food_id  INT,
    @p_rating   INT,
    @p_comment  NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra đơn đã hoàn thành chưa
    IF NOT EXISTS (
        SELECT 1 FROM orders
        WHERE order_id = @p_order_id AND user_id = @p_user_id AND status = 'completed'
    )
    BEGIN
        RAISERROR(N'Chỉ đánh giá được khi đơn hàng đã hoàn thành.', 16, 1);
        RETURN;
    END

    -- Kiểm tra chưa đánh giá
    IF EXISTS (SELECT 1 FROM reviews WHERE order_id = @p_order_id)
    BEGIN
        RAISERROR(N'Đơn hàng này đã được đánh giá rồi.', 16, 1);
        RETURN;
    END

    INSERT INTO reviews (order_id, user_id, food_id, rating, comment)
    VALUES (@p_order_id, @p_user_id, @p_food_id, @p_rating, @p_comment);
END;

-- ============================================================
-- 17. TRIGGERS
-- ============================================================

-- 17.1 Thông báo cho Admin khi có đơn mới
CREATE TRIGGER trg_after_order_created
ON orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO notifications (user_id, title, body, notification_type, related_id)
    SELECT u.user_id,
           N'Có đơn hàng mới!',
           N'Khách hàng vừa đặt đơn. Mã: ' + i.order_code,
           'order',
           i.order_id
    FROM users u
    CROSS JOIN inserted i
    WHERE u.role = 'admin';
END;

-- 17.2 Xử lý khi đơn hoàn thành: tăng total_sold, cộng điểm, thông báo, nhắc đánh giá
CREATE TRIGGER trg_after_order_completed
ON orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(status)
    BEGIN
        -- Tăng total_sold
        UPDATE f
        SET f.total_sold = f.total_sold + oi.quantity
        FROM food_items f
        JOIN order_items oi ON f.food_id = oi.food_id
        JOIN inserted i     ON oi.order_id = i.order_id
        JOIN deleted d      ON i.order_id = d.order_id
        WHERE i.status = 'completed' AND d.status <> 'completed';

        -- Cộng điểm tích lũy cho khách (+10 điểm/đơn)
        UPDATE u
        SET u.loyalty_points = u.loyalty_points + 10
        FROM users u
        JOIN inserted i ON u.user_id = i.user_id
        JOIN deleted d  ON i.order_id = d.order_id
        WHERE i.status = 'completed' AND d.status <> 'completed';

        -- Thông báo tích điểm cho khách
        INSERT INTO notifications (user_id, title, body, notification_type, related_id)
        SELECT i.user_id,
               N'Tích điểm thành công!',
               N'Bạn vừa nhận được 10 điểm thành viên từ đơn hàng ' + i.order_code,
               'loyalty',
               i.order_id
        FROM inserted i
        JOIN deleted d ON i.order_id = d.order_id
        WHERE i.status = 'completed' AND d.status <> 'completed';

        -- Thông báo nhắc đánh giá đơn hàng
        INSERT INTO notifications (user_id, title, body, notification_type, related_id)
        SELECT i.user_id,
               N'Đánh giá đơn hàng của bạn!',
               N'Đơn hàng ' + i.order_code + N' đã hoàn thành. Hãy chia sẻ cảm nhận nhé!',
               'review',
               i.order_id
        FROM inserted i
        JOIN deleted d ON i.order_id = d.order_id
        WHERE i.status = 'completed' AND d.status <> 'completed';
    END
END;

-- 17.3 Cập nhật avg_rating cho món ăn sau khi có đánh giá mới
CREATE TRIGGER trg_update_food_avg_rating
ON reviews
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE f
    SET f.avg_rating = (
        SELECT AVG(CAST(r.rating AS DECIMAL(3,2)))
        FROM reviews r
        WHERE r.food_id = f.food_id
    )
    FROM food_items f
    JOIN inserted i ON f.food_id = i.food_id
    WHERE i.food_id IS NOT NULL;
END;

-- 17.4 Thông báo cho khách khi trạng thái đơn thay đổi (đang giao, hủy...)
CREATE TRIGGER trg_order_status_changed
ON orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(status)
    BEGIN
        INSERT INTO notifications (user_id, title, body, notification_type, related_id)
        SELECT
            i.user_id,
            CASE i.status
                WHEN 'confirmed'  THEN N'Đơn hàng đã được xác nhận'
                WHEN 'preparing'  THEN N'Quán đang chuẩn bị đơn hàng'
                WHEN 'shipping'   THEN N'Đơn hàng đang trên đường giao'
                WHEN 'cancelled'  THEN N'Đơn hàng đã bị hủy'
                ELSE N'Cập nhật đơn hàng'
            END,
            N'Đơn ' + i.order_code + N' - ' +
            CASE i.status
                WHEN 'confirmed'  THEN N'Quán đã xác nhận đơn của bạn.'
                WHEN 'preparing'  THEN N'Quán đang chuẩn bị món cho bạn.'
                WHEN 'shipping'   THEN N'Shipper đang giao hàng đến bạn.'
                WHEN 'cancelled'  THEN N'Đơn hàng của bạn đã bị hủy.'
                ELSE N'Trạng thái đơn hàng đã thay đổi.'
            END,
            'order',
            i.order_id
        FROM inserted i
        JOIN deleted d ON i.order_id = d.order_id
        WHERE i.status <> d.status
          AND i.status IN ('confirmed', 'preparing', 'shipping', 'cancelled');
    END
END;