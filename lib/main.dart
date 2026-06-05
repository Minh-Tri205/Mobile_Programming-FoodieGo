// import 'package:doancuoiki/views/admin/admin_dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'core/constants/app_routes.dart';
// import 'core/theme/app_theme.dart';
// import 'core/utils/app_router.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ),
//   );
//   runApp(const FoodieGoApp());
// }

// class FoodieGoApp extends StatelessWidget {
//   const FoodieGoApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FoodieGo',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       initialRoute: AppRoutes.login,
//       onGenerateRoute: AppRouter.generateRoute,
//     );
//   }

// }

import 'package:doancuoiki/data/providers/user_provider.dart';
import 'package:doancuoiki/data/repositories/user_repository.dart';
import 'package:doancuoiki/data/services/user_service.dart';
import 'package:doancuoiki/views/admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';

import 'data/providers/category_provider.dart';
import 'data/repositories/category_repository.dart';
import 'data/services/category_service.dart';

import 'data/providers/order_provider.dart';
import 'data/repositories/order_repository.dart';
import 'data/services/order_service.dart';

import 'data/providers/food_provider.dart';
import 'data/repositories/food_repository.dart';
import 'data/services/food_service.dart';

import 'data/providers/favorite_provider.dart';
import 'data/repositories/favorite_repository.dart';
import 'data/services/favorite_service.dart';

import 'data/providers/review_provider.dart';
import 'data/repositories/review_repository.dart';
import 'data/services/review_service.dart';

import 'data/providers/cart_provider.dart';
import 'data/repositories/cart_repository.dart';
import 'data/services/cart_service.dart';

import 'data/providers/address_provider.dart';
import 'data/repositories/address_repository.dart';
import 'data/services/address_service.dart';

import 'data/providers/voucher_provider.dart';
import 'data/repositories/voucher_repository.dart';
import 'data/services/voucher_service.dart';

import 'data/providers/voucher_usage_provider.dart';
import 'data/repositories/voucher_usage_repository.dart';
import 'data/services/voucher_usage_service.dart';

import 'data/providers/admin_settings_provider.dart';

import 'data/providers/notification_provider.dart';
import 'data/repositories/notification_repository.dart';
import 'data/services/notification_service.dart';
import 'data/services/notification_signalr_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              CategoryProvider(CategoryRepository(CategoryService())),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(UserRepository(UserService())),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(OrderRepository(OrderService())),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodProvider(FoodRepository(FoodService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              FavoriteProvider(FavoriteRepository(FavoriteService())),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(ReviewRepository(ReviewService())),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(CartRepository(CartService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AddressProvider(AddressRepository(AddressService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              VoucherProvider(VoucherRepository(VoucherService())),
        ),
        ChangeNotifierProvider(
          create: (_) => VoucherUsageProvider(
            VoucherUsageRepository(VoucherUsageService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminSettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            NotificationRepository(NotificationService()),
            NotificationSignalRService(),
          ),
        ),
      ],

      child: const FoodieGoApp(),
    ),
  );
}

class FoodieGoApp extends StatelessWidget {
  const FoodieGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodieGo',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.login,

      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
