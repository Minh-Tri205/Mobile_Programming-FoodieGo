class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Màn hình chính (Bottom Nav)
  static const String home = '/home';           // Trang chủ: xem menu, danh mục
  static const String cart = '/cart';           // Giỏ hàng
  static const String orders = '/orders';       // Lịch sử đơn hàng
  static const String profile = '/profile';     // Hồ sơ cá nhân

  // Màn hình con
  static const String foodDetail = '/food-detail';   // Chi tiết món ăn
  static const String search = '/search';            // Tìm kiếm món
  static const String checkout = '/checkout';        // Xác nhận đặt hàng
  static const String tracking = '/tracking';        // Theo dõi đơn hàng
  static const String notifications = '/notifications'; // Thông báo
    static const String orderDetail = '/order-detail'; // ← thêm mới
  static const String review = '/review';    
}