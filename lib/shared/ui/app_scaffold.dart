import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDFEFF), AppColors.background],
          ),
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}
