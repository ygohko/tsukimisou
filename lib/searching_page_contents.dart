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
import 'package:platform/platform.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'common_uis.dart' as common_uis;
import 'extensions.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_searcher.dart';

class SearchingPageContents extends StatefulWidget {
  /// Creates a searching page contents.
  const SearchingPageContents({Key? key}) : super(key: key);

  @override
  State<SearchingPageContents> createState() => _SearchingPageContentsState();
}

class _SearchingPageContentsState extends State<SearchingPageContents> {
  final _controller = TextEditingController();
  late final FocusNode _focusNode;
  var _memos = <Memo>[];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final lastMerged =
        DateTime.fromMillisecondsSinceEpoch(memoStore.lastMerged);
    final appState = Provider.of<AppState>(context, listen: false);
    late Widget contents;
    if (_memos.isNotEmpty) {
      contents = ListView.builder(
        itemCount: _memos.length,
        itemBuilder: (context, i) {
          final memo = _memos[i];
          final lastModified =
          DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
          late final bool unsynchronized;
          if (lastModified.isAfter(lastMerged)) {
            unsynchronized = true;
          } else {
            unsynchronized = false;
          }
          return Card(
            color: common_uis.TsukimisouColors.memoCard,
            elevation: 2.0,
            child: InkWell(
              onTap: appState.mergingWithGoogleDrive
              ? null
              : () async {
                await common_uis.viewMemo(context, memo);
              },
              child: common_uis.memoCardContents(context, memo, unsynchronized),
            ),
          );
        },
      );
    }
    else {
      contents = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.question_mark,
            color: common_uis.TsukimisouColors.scheme.primary,
            size: 150.0,
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            localizations.noMemosFound,
            style: common_uis.TsukimisouTextStyles.searchingPageNotFoundIndicator(context),
          ),
        ],
      );
    }
    const platform = LocalPlatform();
    if (platform.isMobile) {
      contents = Scrollbar(
        child: contents,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: _clear,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: localizations.searchMemos,
            ),
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: _search,
          ),
        ),
        Expanded(
          child: contents,
        ),
      ],
    );
  }

  void _search(String query) {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final searcher = MemoStoreSearcher(memoStore, query);
    searcher.execute();
    setState(() {
      _memos = [...searcher.results];
    });
  }

  void _clear() {
    _controller.clear();
    _focusNode.requestFocus();
  }
}
