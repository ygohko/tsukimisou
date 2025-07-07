/*
 * Copyright (c) 2025 Yasuaki Gohko
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef SettingsSharedPreferencesCreatorHook = Future<SharedPreferencesWithCache> Function();

// TODO: Add mechanism to mock shared preferences.
class Settings extends ChangeNotifier {
  SharedPreferencesWithCache? _preferences;

  static SettingsSharedPreferencesCreatorHook? _sharedPreferencesCreatorHook;

  /// Initialize this settings.
  Future<void> init() async {
    _preferences ??= await _createPreferences();
  }

  /// Gets whether synchronizing is hidden.
  bool getSynchronizingHidden() {
    final preferences = _preferences;
    if (preferences == null) {
      return false;
    }

    final hidden = preferences.getBool('synchronizingHidden');
    if (hidden == null) {
      return false;
    }

    return hidden;
  }

  /// Sets whether synchronizing is hidden.
  Future<void> setSynchronizingHidden(bool hidden) async {
    _preferences ??= await _createPreferences();
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    await preferences.setBool('synchronizingHidden', hidden);
    notifyListeners();
  }

  /// Gets tag scores.
  Map<String, double> getTagScores() {
    final preferences = _preferences;
    if (preferences == null) {
      return <String, double>{};
    }

    final serialized = preferences.getString('tagScores');
    if (serialized == null) {
      return <String, double>{};
    }
    final decoded = jsonDecode(serialized);
    final scores = <String, double>{};
    for (final key in decoded.keys) {
      scores[key] = decoded[key]!;
    }

    return scores;
  }

  /// Sets tag scores.
  Future<void> setTagScores(Map<String, double> scores) async {
    _preferences ??= await _createPreferences();
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    final serialized = jsonEncode(scores);
    await preferences.setString('tagScores', serialized);
    notifyListeners();
  }

  /// Hook when creating shared preferences.
  static set sharedPreferencesCreatorHook(SettingsSharedPreferencesCreatorHook? hook) {
    _sharedPreferencesCreatorHook = hook;
  }

  Future<SharedPreferencesWithCache> _createPreferences() async {
    final hook = _sharedPreferencesCreatorHook;
    if (hook != null) {
      return await hook();
    }

    return await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }
}
