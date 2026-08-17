import 'package:flutter/material.dart';
import '../shared/config/app_config.dart';
import '../shared/theme/app_theme.dart';
import 'router.dart';

class CentrowSalesApp extends StatelessWidget {
  const CentrowSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
