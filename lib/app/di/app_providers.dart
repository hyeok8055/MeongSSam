import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/env/app_config.dart';
import 'package:meongssam/core/logging/app_logger.dart';
import 'package:meongssam/core/platform/storage/local_store.dart';
import 'package:meongssam/features/quiz/data/question_bank_database_service.dart';
import 'package:meongssam/features/quiz/data/sqlite_question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/quiz_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig.fromEnvironment();
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  return const AppLogger();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden.');
});

final localStoreProvider = Provider<LocalStore>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesLocalStore(sharedPreferences);
});

final questionBankDatabaseServiceProvider =
    Provider<QuestionBankDatabaseService>((ref) {
      final service = QuestionBankDatabaseService();
      ref.onDispose(() {
        service.close();
      });
      return service;
    });

final questionBankRepositoryProvider = Provider<QuestionBankRepository>((ref) {
  final databaseService = ref.watch(questionBankDatabaseServiceProvider);
  return SqliteQuestionBankRepository(databaseService);
});

final quizSessionStoreProvider = Provider<QuizSessionStore>((ref) {
  final localStore = ref.watch(localStoreProvider);
  return LocalQuizSessionStore(localStore);
});
