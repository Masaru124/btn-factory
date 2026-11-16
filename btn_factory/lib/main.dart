import 'package:btn_factory/core/constants/app_constants.dart';
import 'package:btn_factory/core/router/app_router.dart';
import 'package:btn_factory/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.loadEnv();
  runApp(const ProviderScope(child: ButtonFactoryApp()));
}

class ButtonFactoryApp extends ConsumerWidget {
  const ButtonFactoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Button Factory MES',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
    );    
  }
}
