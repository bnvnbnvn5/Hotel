import 'dart:io';
import 'package:myapp/routes/route_names.dart';
import 'package:myapp/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/common/common.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/utils/enum.dart';
import 'package:provider/provider.dart';

import 'modules/splash/introductionScreen.dart';
import 'modules/splash/splashScreen.dart';
import 'modules/home/home_screen.dart';

BuildContext? applicationcontext;

class MotelApp extends StatefulWidget {
  @override
  _MotelAppState createState() => _MotelAppState();
}

class _MotelAppState extends State<MotelApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (_, provider, child) {
      applicationcontext = context;
      final ThemeData _theme = provider.themeData;
      return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('vi'), // Vietnamese
        ],
        navigatorKey: navigatorKey,
        title: 'Motel',
        debugShowCheckedModeBanner: false,
        theme: _theme,
        routes: _buildRoutes(),
        builder: (BuildContext context, Widget? child) {
          _setFirstTimeSomeData(context, _theme);
          return Directionality(
            textDirection: TextDirection.ltr, // Mặc định ltr cho en và vi
            child: Builder(
              builder: (BuildContext context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context).size.width > 360
                          ? 1.0
                          : (MediaQuery.of(context).size.width >= 360 ? 0.9 : 0.8),
                    ),
                  ),
                  child: child ?? SizedBox(),
                );
              },
            ),
          );
        },
      );
    });
  }

  void _setFirstTimeSomeData(BuildContext context, ThemeData theme) {
    applicationcontext = context;
    _setStatusBarNavigationBarTheme(theme);
    context.read<ThemeProvider>().checkAndSetThemeMode(MediaQuery.of(context).platformBrightness);
    context.read<ThemeProvider>().checkAndSetLanguage();
    context.read<ThemeProvider>().checkAndSetFonType();
    context.read<ThemeProvider>().checkAndSetColorType();
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      RoutesName.Splash: (BuildContext context) => SplashScreen(),
      RoutesName.IntroductionScreen: (BuildContext context) => IntroductionScreen(),
      RoutesName.Home: (BuildContext context) => HomeScreen(),
    };
  }

  void _setStatusBarNavigationBarTheme(ThemeData themeData) {
    final brightness = !kIsWeb && Platform.isAndroid
        ? (themeData.brightness == Brightness.light ? Brightness.dark : Brightness.light)
        : themeData.brightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarColor: themeData.scaffoldBackgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: brightness,
    ));
  }
}