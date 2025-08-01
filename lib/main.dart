import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/themes.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/motel_app.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cố định chế độ dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(_setAllProviders());
}

Widget _setAllProviders() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(
          state: AppTheme.getThemeData,
        ),
      ),
    ],
    child: MotelApp(),
  );
}
