import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/themes.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/motel_app.dart';
import 'package:myapp/services/app_init_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Khởi tạo app và khôi phục session
  final appInit = AppInitService();
  await appInit.initializeApp();
  bool hasSession = await appInit.restoreUserSession();

  runApp(_setAllProviders(hasSession: hasSession));
}

// 🎯 MULTIPROVIDER - Thiết lập nhiều provider cho ứng dụng
Widget _setAllProviders({bool hasSession = false}) {
  return MultiProvider(
    providers: [
      // 🎯 CHANGENOTIFIERPROVIDER - Provider cho state management
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(
          state: AppTheme.getThemeData,
        ),
      ),
    ],
    child: MotelApp(hasSession: hasSession),
  );
}
