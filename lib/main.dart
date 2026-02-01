import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:perf_evaluation/features/home/home_screen.dart';

import 'package:syn_multitenancy/syn_multitenacy.dart';
import 'package:syn_theme/syn_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromPath("./assets/cfg/app_settings.json");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    Widget activePage = LoginScreen(
        navigatorKey: navigatorKey,
        loginScreenImagePath: 'assets/icons/login.svg',
        redirectWidget: HomeScreen(navigatorKey: navigatorKey));

    return MaterialApp(
        title: 'Performance Evaluation',
        theme: synThemeLight,
        darkTheme: synThemeDark,
        home: activePage);
  }
}
