// lib/core/utils/app_router.dart

import 'package:doancuoiki/views/admin/admin_add_product_screen.dart';
import 'package:doancuoiki/views/admin/admin_categories_screen.dart';
import 'package:doancuoiki/views/admin/admin_dashboard_screen.dart';
import 'package:doancuoiki/views/admin/admin_edit_product_screen.dart';
import 'package:doancuoiki/views/admin/admin_orders_screen.dart';
import 'package:doancuoiki/views/admin/admin_products_screen.dart';
import 'package:doancuoiki/views/admin/admin_statistics_screen.dart';
import 'package:doancuoiki/views/admin/admin_user_detail_screen.dart';
import 'package:doancuoiki/views/admin/admin_user_history_screen.dart';
import 'package:doancuoiki/views/admin/admin_users_screen.dart';
import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import 'package:doancuoiki/views/user/splash_screen.dart';
import 'package:doancuoiki/views/user/login_screen.dart';
import 'package:doancuoiki/views/user/register_screen.dart';
import 'package:doancuoiki/views/user/home_screen.dart';
import 'package:doancuoiki/views/user/search_screen.dart';
import 'package:doancuoiki/views/user/food_detail_screen.dart';
import 'package:doancuoiki/views/user/cart_screen.dart';
import 'package:doancuoiki/views/user/checkout_screen.dart';
import 'package:doancuoiki/views/user/tracking_screen.dart';
import 'package:doancuoiki/views/user/orders_screen.dart';
import 'package:doancuoiki/views/user/profile_screen.dart';
import 'package:doancuoiki/views/user/notifications_screen.dart';
import 'package:doancuoiki/views/user/order_detail_screen.dart';
import 'package:doancuoiki/views/user/review_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _slide(const SplashScreen(), settings);
      case AppRoutes.login:
        return _slide(const LoginScreen(), settings);
      case AppRoutes.register:
        return _slide(const RegisterScreen(), settings);
      case AppRoutes.home:
        return _slide(const HomeScreen(), settings);
      case AppRoutes.search:
        return _slide(const SearchScreen(), settings);
      case AppRoutes.foodDetail:
        // Truyền arguments qua settings, đọc bên trong FoodDetailScreen
        // bằng: final food = ModalRoute.of(context)!.settings.arguments as FoodModel;
        return _slide(const FoodDetailScreen(), settings);
      case AppRoutes.cart:
        return _slide(const CartScreen(), settings);
      case AppRoutes.checkout:
        return _slide(const CheckoutScreen(), settings);
      case AppRoutes.tracking:
        // Đọc order bên trong TrackingScreen
        // bằng: final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
        return _slide(const TrackingScreen(), settings);
      case AppRoutes.orders:
        return _slide(const OrdersScreen(), settings);
      case AppRoutes.profile:
        return _slide(const ProfileScreen(), settings);
      case AppRoutes.notifications:
        return _slide(const NotificationsScreen(), settings);
      case AppRoutes.orderDetail:
        return _slide(const OrderDetailScreen(), settings);
      case AppRoutes.review:
        return _slide(const ReviewScreen(), settings);

      // Admin Routes
      case AppRoutes.adminDashboard:
        return _slide(const AdminDashboardScreen(), settings);
      case AppRoutes.adminOrders:
        return _slide(const AdminOrdersScreen(), settings);
      // case AppRoutes.adminOrderDetail:
      //   return _slide(const AdminOrderDetailScreen(), settings);
      case AppRoutes.adminProducts:
        return _slide(const AdminProductsScreen(), settings);
      case AppRoutes.adminAddProduct:
        return _slide(const AdminAddProductScreen(), settings);
      case AppRoutes.adminEditProduct:
        return _slide(const AdminEditProductScreen(), settings);
      case AppRoutes.adminCategories:
        return _slide(const AdminCategoriesScreen(), settings);
      case AppRoutes.adminUsers:
        return _slide(const AdminUsersScreen(), settings);
      case AppRoutes.adminUserDetail:
        // Lấy userId từ arguments được truyền qua Navigator
        final userId = settings.arguments as int;
        return _slide(AdminUserDetailScreen(userId: userId), settings);
      case AppRoutes.adminUserHistory:
        final userId = settings.arguments as int;
        return _slide(AdminUserHistoryScreen(userId: userId), settings);
      case AppRoutes.adminStatistics:
        return _slide(const AdminStatisticsScreen(), settings);
      // case AppRoutes.adminNotifications:
      //   return _slide(const AdminNotificationsScreen(), settings);
      // case AppRoutes.adminSettings:
      //   return _slide(const AdminSettingsScreen(), settings);
      default:
        return _slide(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) =>
          page, // ← dùng _ __ ___ vẫn OK nếu Dart version cũ
      transitionsBuilder: (_, animation, _, child) {
        // ← sửa __ thành _
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }
}
