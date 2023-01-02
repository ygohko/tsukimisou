/*
 * Copyright (c) 2023 Yasuaki Gohko
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
import 'memo_store.dart';

class MemoStoreSearcher {
  final MemoStore _memoStore;
  final String _query;
  var _results = <Memo>[];

  /// Creates a memo store searcher.
  MemoStoreSearcher(this._memoStore, this._query);

  /// Executes search
  void execute() {
    final split = _query.split(RegExp(r'( |　+)'));
    final keywords = <String>[];
    for (var string in split) {
      string = string.toLowerCase();
      if (string != '' && keywords.indexOf(string) < 0) {
        keywords.add(string.toLowerCase());
      }
    }
    _results.clear();
    print(keywords.length);
    print(keywords);
    if (keywords.length < 1) {
      print('kyanseruuuu');
      return;
    }
    for (final memo in _memoStore.memos) {
      var text = memo.text.toLowerCase();
      for (final tag in memo.tags) {
        text += " ${tag.toLowerCase()}";
      }
      var found = true;
      for (final keyword in keywords) {
        if (text.indexOf(keyword) < 0) {
          found = false;
          break;
        }
      }

      if (found) {
        _results.add(memo);
      }
    }
    _results.sort((a, b) => b.lastModified.compareTo(a.lastModified));
  }

  /// Search results.
  List<Memo> get results => _results;
}
