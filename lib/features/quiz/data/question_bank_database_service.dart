import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class QuestionBankDatabaseService {
  QuestionBankDatabaseService({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/question_bank/app_bank.sqlite',
    this.databaseName = 'app_bank.sqlite',
  }) : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final String assetPath;
  final String databaseName;

  Database? _database;

  Future<Database> open() async {
    final existing = _database;
    if (existing != null) {
      if (await _hasRequiredSchema(existing)) return existing;
      await close();
    }

    final databasePath = p.join(await getDatabasesPath(), databaseName);
    await _copyBundledAsset(databasePath);
    _database = await openDatabase(databasePath, readOnly: true);
    if (!await _hasRequiredSchema(_database!)) {
      await close();
      throw StateError('Bundled question bank schema is missing body_text.');
    }
    return _database!;
  }

  Future<List<Map<String, Object?>>> queryQuestionRows({
    required String setId,
  }) async {
    return _queryWithSchemaRefresh(
      '''
      SELECT questions.id, questions.question_number, questions.prompt,
             questions.body_text, questions.answer_label
      FROM question_set_items
      INNER JOIN questions ON questions.id = question_set_items.question_id
      WHERE question_set_items.set_id = ?
      ORDER BY question_set_items.position
      ''',
      [setId],
    );
  }

  Future<List<Map<String, Object?>>> queryRandomQuestionRows({
    required int limit,
  }) async {
    return _queryWithSchemaRefresh(
      '''
      SELECT id, question_number, prompt, body_text, answer_label
      FROM questions
      ORDER BY RANDOM()
      LIMIT ?
      ''',
      [limit],
    );
  }

  Future<List<Map<String, Object?>>> queryAllQuestionRows() async {
    return _queryWithSchemaRefresh('''
      SELECT id, question_number, prompt, body_text, answer_label
      FROM questions
      ORDER BY question_number
      ''', const []);
  }

  Future<List<Map<String, Object?>>> queryQuestionRowsByIds(
    List<String> questionIds,
  ) async {
    if (questionIds.isEmpty) return const [];
    final database = await open();
    final placeholders = List.filled(questionIds.length, '?').join(',');
    return database.rawQuery('''
      SELECT id, question_number, prompt, body_text, answer_label
      FROM questions
      WHERE id IN ($placeholders)
      ''', questionIds);
  }

  Future<List<Map<String, Object?>>> queryChoiceRows(
    List<String> questionIds,
  ) async {
    if (questionIds.isEmpty) return const [];
    final database = await open();
    final placeholders = List.filled(questionIds.length, '?').join(',');
    final imageRefSelect = await _hasColumn(database, 'choices', 'image_ref')
        ? 'image_ref'
        : "'' AS image_ref";
    return database.rawQuery('''
      SELECT question_id, label, text, position, $imageRefSelect
      FROM choices
      WHERE question_id IN ($placeholders)
      ORDER BY question_id, position
      ''', questionIds);
  }

  Future<List<Map<String, Object?>>> queryImageRows(
    List<String> questionIds,
  ) async {
    if (questionIds.isEmpty) return const [];
    final database = await open();
    final placeholders = List.filled(questionIds.length, '?').join(',');
    return database.rawQuery('''
      SELECT question_stimuli.question_id, stimuli.asset_path, question_stimuli.position
      FROM question_stimuli
      INNER JOIN stimuli ON stimuli.id = question_stimuli.stimulus_id
      WHERE question_stimuli.question_id IN ($placeholders)
      ORDER BY question_stimuli.question_id, question_stimuli.position
      ''', questionIds);
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }

  Future<List<Map<String, Object?>>> _queryWithSchemaRefresh(
    String sql,
    List<Object?> arguments,
  ) async {
    try {
      return (await open()).rawQuery(sql, arguments);
    } on DatabaseException catch (error) {
      if (!error.toString().contains('body_text')) rethrow;
      await close();
      return (await open()).rawQuery(sql, arguments);
    }
  }

  Future<bool> _hasRequiredSchema(Database database) async {
    return _hasColumn(database, 'questions', 'body_text');
  }

  Future<bool> _hasColumn(
    Database database,
    String table,
    String columnName,
  ) async {
    final columns = await database.rawQuery('PRAGMA table_info($table)');
    return columns.any((column) => column['name'] == columnName);
  }

  Future<void> _copyBundledAsset(String databasePath) async {
    final file = File(databasePath);
    await file.parent.create(recursive: true);
    final data = await _assetBundle.load(assetPath);
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
  }
}
