class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Màn hình chính (Bottom Nav)
  static const String home = '/home'; // Trang chủ: xem menu, danh mục
  static const String cart = '/cart'; // Giỏ hàng
  static const String orders = '/orders'; // Lịch sử đơn hàng
  static const String profile = '/profile'; // Hồ sơ cá nhân

  // Màn hình con
  static const String foodDetail = '/food-detail'; // Chi tiết món ăn
  static const String search = '/search'; // Tìm kiếm món
  static const String checkout = '/checkout'; // Xác nhận đặt hàng
  static const String tracking = '/tracking'; // Theo dõi đơn hàng
  static const String notifications = '/notifications'; // Thông báo
  static const String orderDetail = '/order-detail'; // ← thêm mới
  static const String review = '/review';

  // Admin Main
  static const String adminDashboard = '/admin/dashboard';

  // Orders
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/detail';

  // Products
  static const String adminProducts = '/admin/products';
  static const String adminAddProduct = '/admin/products/add';
  static const String adminEditProduct = '/admin/products/edit';

  // Categories
  static const String adminCategories = '/admin/categories';

  // Users
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/users/detail';
  static const String adminUserHistory = '/admin/users/history';

  // Statistics
  static const String adminStatistics = '/admin/statistics';

  // Notifications
  static const String adminNotifications = '/admin/notifications';

  // Settings
  static const String adminSettings = '/admin/settings';
}
