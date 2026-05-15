class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.number,
    required this.prompt,
    required this.bodyText,
    required this.choices,
    required this.correctChoiceIndex,
    required this.imageAssetPaths,
  });

  final String id;
  final int number;
  final String prompt;
  final String bodyText;
  final List<QuizChoice> choices;
  final int correctChoiceIndex;
  final List<String> imageAssetPaths;

  bool get hasImages => imageAssetPaths.isNotEmpty;
  bool get hasImageNavigation => imageAssetPaths.length > 1;
  bool get hasBodyText => bodyText.trim().isNotEmpty;
}

class QuizChoice {
  const QuizChoice({
    required this.label,
    required this.text,
    this.imageAssetPath = '',
  });

  final String label;
  final String text;
  final String imageAssetPath;

  bool get hasImage => imageAssetPath.trim().isNotEmpty;
  String get displayText => text.isEmpty ? label : '$label. $text';
}
