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

import 'memo.dart';

class MemoStore {
  final _memos = <Memo>[];
  var _removedMemoIds = <String>[];
  var _lastMerged = 0;

  static MemoStore? _instance = null;

  /// Adds a memo to this memo store.
  void addMemo(Memo memo) {
    _memos.add(memo);
  }

  /// Removes a memo from this memo store.
  void removeMemo(Memo memo) {
    if (_memos.indexOf(memo) < 0) {
      return;
    }
    _removedMemoIds.add(memo.id);
    _memos.remove(memo);
  }

  /// Clears memos from this memo store.
  void clearMemos() {
    _memos.clear();
  }

  /// Memos that are stored in this memo store.
  List<Memo> get memos => _memos;

  /// Memo IDs that are removed.
  List<String> get removedMemoIds => _removedMemoIds;

  /// Memo IDs that are removed.
  void set removedMemoIds(List<String> removedMemoIds) {
    _removedMemoIds = removedMemoIds;
  }

  /// Epoch milliseconds from last merged.
  int get lastMerged => _lastMerged;

  /// Epoch milliseconds from last merged.
  void set lastMerged(int lastMerged) {
    _lastMerged = lastMerged;
  }

  /// Gets a singleton instance.
  static MemoStore instance() {
    if (_instance == null) {
      _instance = MemoStore();
    }

    return _instance!;
  }
}
