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
  /// Memos that are stored in this memo store.
  var memos = <Memo>[];

  /// Memo IDs that are removed.
  var removedMemoIds = <String>[];

  /// Epoch milliseconds from last merged.
  var lastMerged = 0;

  /// Adds a memo to this memo store.
  void addMemo(Memo memo) {
    memos.add(memo);
    notifyListeners();
  }

  /// Removes a memo from this memo store.
  void removeMemo(Memo memo) {
    if (!memos.contains(memo)) {
      return;
    }
    if (!removedMemoIds.contains(memo.id)) {
      removedMemoIds.add(memo.id);
    }
    memos.remove(memo);
    notifyListeners();
  }

  /// Clears memos from this memo store.
  void clearMemos() {
    memos.clear();
    notifyListeners();
  }

  /// Marks as changed.
  void markAsChanged() {
    notifyListeners();
  }

  /// Memo that has given ID.
  Memo? memoFromId(String id) {
    for (var memo in memos) {
      if (memo.id == id) {
        return memo;
      }
    }

    return null;
  }

  /// Tags bound for memos
  List<String> get tags {
    var tags = <String>[];
    for (final memo in memos) {
      for (final tag in memo.tags) {
        if (!tags.contains(tag)) {
          tags.add(tag);
        }
      }
    }

    return tags;
  }
}
