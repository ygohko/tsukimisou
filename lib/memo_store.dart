/*
 * Copyright (c) 2022 Yasuaki Gohko
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

import 'package:flutter/foundation.dart';

import 'memo.dart';

class MemoStore extends ChangeNotifier {
  var _memos = <Memo>[];
  var _removedMemoIds = <String>[];
  var _lastMerged = 0;

  /// Adds a memo to this memo store.
  void addMemo(Memo memo) {
    _memos.add(memo);
    notifyListeners();
  }

  /// Removes a memo from this memo store.
  void removeMemo(Memo memo) {
    if (!_memos.contains(memo)) {
      return;
    }
    _removedMemoIds.add(memo.id);
    _memos.remove(memo);
    notifyListeners();
  }

  /// Clears memos from this memo store.
  void clearMemos() {
    _memos.clear();
    notifyListeners();
  }

  /// Memo that has given ID.
  Memo? memoFromId(String id) {
    for (var memo in _memos) {
      if (memo.id == id) {
        return memo;
      }
    }

    return null;
  }

  /// Memos that are stored in this memo store.
  List<Memo> get memos => _memos;

  /// Memos that are stored in this memo store.
  set memos(List<Memo> memos) {
    _memos = memos;
  }

  /// Memo IDs that are removed.
  List<String> get removedMemoIds => _removedMemoIds;

  /// Memo IDs that are removed.
  set removedMemoIds(List<String> removedMemoIds) {
    _removedMemoIds = removedMemoIds;
  }

  /// Epoch milliseconds from last merged.
  int get lastMerged => _lastMerged;

  /// Epoch milliseconds from last merged.
  set lastMerged(int lastMerged) {
    _lastMerged = lastMerged;
  }

  /// Tags bound for memos
  List<String> get tags {
    var tags = <String>[];
    for (final memo in _memos) {
      for (final tag in memo.tags) {
        if (!tags.contains(tag)) {
          tags.add(tag);
        }
      }
    }

    return tags;
  }
}
