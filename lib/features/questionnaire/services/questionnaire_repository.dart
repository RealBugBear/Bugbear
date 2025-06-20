import 'package:hive/hive.dart';
import '../models/questionnaire_state.dart';

class QuestionnaireRepository {
  static const String _boxName = 'questionnaire_state';
  static const String _key = 'state';

  Future<Box<Map>> _openBox() async => Hive.box<Map>(_boxName);

  Future<QuestionnaireState?> load() async {
    final box = await _openBox();
    final json = box.get(_key);
    if (json == null) return null;
    return QuestionnaireState.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> save(QuestionnaireState state) async {
    final box = await _openBox();
    await box.put(_key, state.toJson());
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_key);
  }
}
