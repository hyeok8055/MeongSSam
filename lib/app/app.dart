import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/app/router/app_router.dart';
import 'package:meongssam/core/design/app_theme.dart';

class MeongSSamApp extends ConsumerWidget {
  const MeongSSamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final router = AppRouter();

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: router.home,
    );
  }
}
