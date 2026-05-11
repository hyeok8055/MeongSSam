import 'dart:convert';

import 'package:meongssam/core/platform/storage/local_store.dart';

abstract interface class QuizSessionStore {
  bool hasSession();
  QuizSessionSnapshot? read();
  Future<void> save(QuizSessionSnapshot snapshot);
  Future<void> clear();
}

class QuizSessionSnapshot {
  const QuizSessionSnapshot({
    required this.questionIds,
    required this.currentIndex,
    required this.selectedChoiceIndexes,
  });

  final List<String> questionIds;
  final int currentIndex;
  final Map<String, int> selectedChoiceIndexes;

  Map<String, Object> toJson() {
    return {
      'questionIds': questionIds,
      'currentIndex': currentIndex,
      'selectedChoiceIndexes': selectedChoiceIndexes,
    };
  }

  static QuizSessionSnapshot? fromJson(Object? value) {
    if (value is! Map<String, Object?>) return null;
    final questionIds = value['questionIds'];
    final currentIndex = value['currentIndex'];
    final selectedChoiceIndexes = value['selectedChoiceIndexes'];
    if (questionIds is! List || currentIndex is! int) return null;

    return QuizSessionSnapshot(
      questionIds: questionIds.whereType<String>().toList(growable: false),
      currentIndex: currentIndex,
      selectedChoiceIndexes: selectedChoiceIndexes is Map
          ? selectedChoiceIndexes.map(
              (key, value) => MapEntry('$key', value is int ? value : 0),
            )
          : const {},
    );
  }
}

class LocalQuizSessionStore implements QuizSessionStore {
  const LocalQuizSessionStore(this._localStore);

  static const _key = 'quiz.session.v1';

  final LocalStore _localStore;

  @override
  bool hasSession() => read() != null;

  @override
  QuizSessionSnapshot? read() {
    final value = _localStore.getString(_key);
    if (value == null || value.isEmpty) return null;
    try {
      return QuizSessionSnapshot.fromJson(jsonDecode(value));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(QuizSessionSnapshot snapshot) async {
    await _localStore.setString(_key, jsonEncode(snapshot.toJson()));
  }

  @override
  Future<void> clear() async {
    await _localStore.remove(_key);
  }
}
