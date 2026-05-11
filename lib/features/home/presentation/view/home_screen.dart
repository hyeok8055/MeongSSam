import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/core/assets/app_assets.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';
import 'package:meongssam/features/home/presentation/widgets/level_card.dart';
import 'package:meongssam/features/home/presentation/widgets/main_warning_dialog.dart';
import 'package:meongssam/features/home/presentation/widgets/quick_action_card.dart';
import 'package:meongssam/features/quiz/application/quiz_view_model.dart';
import 'package:meongssam/features/quiz/presentation/view/quiz_image_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _figmaWidth = 402.0;
  static const _targetDeviceWidth = 480.0;
  static const _contentWidth = 342.0;

  bool _isWarningVisible = false;

  void _showWarning() {
    setState(() => _isWarningVisible = true);
  }

  void _hideWarning() {
    setState(() => _isWarningVisible = false);
  }

  Future<void> _openQuiz() async {
    final launchMode = ref.read(quizSessionStoreProvider).hasSession()
        ? await _showQuizResumeChoice()
        : QuizLaunchMode.fresh;
    if (!mounted || launchMode == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuizImageScreen(launchMode: launchMode),
      ),
    );
  }

  Future<QuizLaunchMode?> _showQuizResumeChoice() {
    return showDialog<QuizLaunchMode>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _QuizResumeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homeViewModelProvider);
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth.clamp(
                0.0,
                _targetDeviceWidth,
              );
              final scale = viewportWidth / _figmaWidth;
              final topGap = (82 * scale - topInset).clamp(0.0, 72.0);
              final contentWidth = _contentWidth * scale;
              final warningWidth = _contentWidth * scale;
              final warningTop = (306 * scale - topInset).clamp(
                0.0,
                constraints.maxHeight,
              );

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: viewportWidth,
                          child: Column(
                            children: [
                              SizedBox(height: topGap),
                              Image.asset(
                                AppAssets.boricon,
                                width: 94 * scale,
                                height: 94 * scale,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 44 * scale),
                              SizedBox(
                                width: contentWidth,
                                child: Column(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < viewModel.levels.length;
                                      index++
                                    ) ...[
                                      LevelCard(
                                        item: viewModel.levels[index],
                                        scale: scale,
                                        onTap: index == 0
                                            ? _openQuiz
                                            : _showWarning,
                                      ),
                                      if (index != viewModel.levels.length - 1)
                                        SizedBox(height: 25 * scale),
                                    ],
                                    SizedBox(height: 25 * scale),
                                    Row(
                                      children: [
                                        for (
                                          var index = 0;
                                          index < viewModel.quickActions.length;
                                          index++
                                        ) ...[
                                          Expanded(
                                            child: QuickActionCard(
                                              item:
                                                  viewModel.quickActions[index],
                                              scale: scale,
                                              onTap: _showWarning,
                                            ),
                                          ),
                                          if (index !=
                                              viewModel.quickActions.length - 1)
                                            SizedBox(width: 23 * scale),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isWarningVisible) ...[
                    const Positioned.fill(
                      child: ModalBarrier(
                        color: Color(0x80000000),
                        dismissible: false,
                      ),
                    ),
                    Positioned(
                      top: warningTop,
                      left: (constraints.maxWidth - warningWidth) / 2,
                      child: MainWarningDialog(
                        width: warningWidth,
                        scale: scale,
                        onConfirm: _hideWarning,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuizResumeDialog extends StatelessWidget {
  const _QuizResumeDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        '풀던 문제가 있어요',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(QuizLaunchMode.resume),
          child: const Text('이어서 풀기'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(QuizLaunchMode.fresh),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF002366),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text('새 문제 풀기'),
        ),
      ],
    );
  }
}
