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
