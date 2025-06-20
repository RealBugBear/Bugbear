import 'package:hive_flutter/hive_flutter.dart';

import '../models/questionnaire_state.dart';

class QuestionnaireRepository {
  static const String _boxName = 'questionnaire_state';
  static const String _key = 'current';

  Future<Box<QuestionnaireState>> _openBox() async =>
      Hive.box<QuestionnaireState>(_boxName);

  Future<QuestionnaireState?> load() async {
    final box = await _openBox();
    return box.get(_key);
  }

  Future<void> save(QuestionnaireState state) async {
    final box = await _openBox();
    await box.put(_key, state);
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_key);
  }
}
