import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/themes.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/motel_app.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:myapp/seed_data.dart'; // Đảm bảo đã import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // XÓA DB CŨ (chỉ dùng khi cần reset)
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'hotel_app.db'));

  // GỌI SEED DATA SAU KHI XÓA DB
  await seedData();

  // Chỉ khởi tạo sqflite_ffi cho desktop, KHÔNG cho web
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(_setAllProviders()));
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
