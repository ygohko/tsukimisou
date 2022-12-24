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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'memo_store.dart';

class SearchingPageContents extends StatefulWidget {
  /// Creates a home page.
  const SearchingPageContents({Key? key}) : super(key: key);

  @override
  State<SearchingPageContents> createState() => _SearchingPageContentsState();
}

class _SearchingPageContentsState extends State<SearchingPageContents> {
  var _strings = <String>[];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return  Column(
      children: [
        Padding(
          padding: EdgeInsets.all(4.0),
          child: SizedBox(
            height: 36.0,
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                contentPadding: EdgeInsets.zero,
                hintText: localizations.searchMemos,
              ),
              onSubmitted: (string) {
                _search(string);
              },
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _strings.length,
            itemBuilder: (context, i) {
              // TODO: Create proper cards.
              return Card(
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(_strings[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _search(String query) {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final memos = memoStore.memos;
    setState(() {
      _strings.clear();
      for (final memo in memos) {
        if (memo.text.indexOf(query) >= 0) {
          _strings.add(memo.text);
        }
      }
    });
  }
}
