/*
 * Copyright (c) 2022, 2025 Yasuaki Gohko
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

import "dart:convert";

import 'memo_store.dart';

class MemoStoreSaver {
  final MemoStore _memoStore;

  /// Creates a memo store saver base.
  MemoStoreSaver(this._memoStore);

  /// Serializes a memo store.
  String serialize() {
    final memoStore = _memoStore;
    final memos = memoStore.memos;
    final serializableMemos = [];
    for (var i = 0; i < memos.length; i++) {
      serializableMemos.add(memos[i].toSerializable());
    }
    const version = 3;
    final serializable = {
      'version': version,
      'memos': serializableMemos,
      'lastMerged': memoStore.lastMerged,
      'removedMemoIds': memoStore.removedMemoIds,
    };

    return jsonEncode(serializable);
  }
}
