// lib/core/utils/app_router.dart

import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import 'package:doancuoiki/views/splash_screen.dart';
import 'package:doancuoiki/views/login_screen.dart';
import 'package:doancuoiki/views/register_screen.dart';
import 'package:doancuoiki/views/home_screen.dart';
import 'package:doancuoiki/views/search_screen.dart';
import 'package:doancuoiki/views/food_detail_screen.dart';
import 'package:doancuoiki/views/cart_screen.dart';
import 'package:doancuoiki/views/checkout_screen.dart';
import 'package:doancuoiki/views/tracking_screen.dart';
import 'package:doancuoiki/views/orders_screen.dart';
import 'package:doancuoiki/views/profile_screen.dart';
import 'package:doancuoiki/views/notifications_screen.dart';
import 'package:doancuoiki/views/order_detail_screen.dart';
import 'package:doancuoiki/views/review_screen.dart';     

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
      default:
        return _slide(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,         // ← dùng _ __ ___ vẫn OK nếu Dart version cũ
      transitionsBuilder: (_, animation, _, child) { // ← sửa __ thành _
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }
}