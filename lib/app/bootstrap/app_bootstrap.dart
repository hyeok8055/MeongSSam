import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/app.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/app/env/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  const config = AppConfig.fromEnvironment();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MeongSSamApp(),
    ),
  );
}
