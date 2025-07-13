import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MockSharedPreferencesWithCache implements SharedPreferencesWithCache {
  var _hidden = false;
  var _tagScores = '{"a": 1.0, "b": 0.5}';

  @override
  bool? getBool(String key) {
    return _hidden;
  }

  @override
  String? getString(String key) {
    return _tagScores;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _hidden = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _tagScores = value;
  }

  @override
  noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
