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
import 'package:platform/platform.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'common_uis.dart' as common_uis;
import 'extensions.dart';
import 'gen_l10n/app_localizations.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_searcher.dart';
import 'settings.dart';
import 'viewing_page.dart';

class SearchingPageContents extends StatefulWidget {
  final List<String> shownArchiveNames;

  /// Creates a searching page contents.
  const SearchingPageContents({super.key, required this.shownArchiveNames}) : super(key: key);

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
    final settings = Provider.of<Settings>(context, listen: false);
    late Widget contents;
    if (_memos.isNotEmpty) {
      contents = ListView.builder(
        itemCount: _memos.length,
        itemBuilder: (context, i) {
          final memo = _memos[i];
          final lastModified =
              DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
          late final bool unsynchronized;
          if (!settings.getSynchronizationHidden() &&
              lastModified.isAfter(lastMerged)) {
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
                  : () {
                    _viewMemo(memo);
                  },
              child: common_uis.memoCardContents(context, memo, unsynchronized),
            ),
          );
        },
      );
    } else {
      contents = common_uis.noMemosIndicator(
          context, Icons.question_mark, localizations.noMemosFound);
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
    final memos = [...searcher.results];
    for (final name in widget.shownArchiveNames) {
      final aMemoStore = memoStore.archiveMemoStoreIfLoaded(name);
      if (aMemoStore != null) {
        final searcher = MemoStoreSearcher(aMemoStore, query);
        searcher.execute();
        memos.addAll(searcher.results);
      }
    }
    memos.sort((a, b) => b.lastModified.compareTo(a.lastModified));

    setState(() {
      _memos = memos;
    });
  }

  void _clear() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _viewMemo(Memo memo) async {
    final result = await common_uis.viewMemo(context, memo);
    if (result == null) {
      return;
    }
    if (result == ViewingPageResult.deleted || result == ViewingPageResult.archived) {
      final query = _controller.text;
      _search(query);
    }
  }
}
