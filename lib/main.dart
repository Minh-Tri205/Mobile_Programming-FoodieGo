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

      initialRoute: AppRoutes.adminCategories,

      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
