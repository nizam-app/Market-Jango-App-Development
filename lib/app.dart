import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/theme/light_dark_theme.dart'; // exports themeModeProvider, appLightThemeProvider, appDarkThemeProvider
import 'package:market_jango/routes/app_routes.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: themeMood(ref), // same call name as before
        );
      },
    );
  }
}
