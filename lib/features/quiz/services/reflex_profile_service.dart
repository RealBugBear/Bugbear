import 'package:hive/hive.dart';
import '../models/reflex_profile.dart';

class ReflexProfileService {
  static const String _boxName = 'reflex_profile';
  static const String _key = 'profile';

  Box<ReflexProfile> get _box => Hive.box<ReflexProfile>(_boxName);

  Future<ReflexProfile?> load() async {
    return _box.get(_key);
  }

  Future<void> save(ReflexProfile profile) async {
    await _box.put(_key, profile);
  }

  Future<void> clear() async {
    await _box.delete(_key);
  }
}
