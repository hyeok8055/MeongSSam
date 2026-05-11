import 'package:flutter/material.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_choice_card.dart';

class QuizChoiceList extends StatelessWidget {
  const QuizChoiceList({
    super.key,
    required this.choices,
    required this.selectedIndex,
    required this.correctChoiceIndex,
    required this.scale,
    required this.onSelect,
  });

  final List<QuizChoice> choices;
  final int? selectedIndex;
  final int correctChoiceIndex;
  final double scale;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.only(bottom: 24 * scale),
      child: Column(
        children: [
          for (var index = 0; index < choices.length; index++) ...[
            QuizChoiceCard(
              label: choices[index].label,
              text: choices[index].text,
              scale: scale,
              state: _stateFor(index),
              onTap: selectedIndex == null ? () => onSelect?.call(index) : null,
            ),
            if (index != choices.length - 1) SizedBox(height: 16 * scale),
          ],
        ],
      ),
    );
  }

  QuizChoiceCardState _stateFor(int index) {
    final selected = selectedIndex;
    if (selected == null) return QuizChoiceCardState.idle;
    if (index == correctChoiceIndex) return QuizChoiceCardState.correct;
    if (index == selected) return QuizChoiceCardState.incorrect;
    return QuizChoiceCardState.idle;
  }
}
