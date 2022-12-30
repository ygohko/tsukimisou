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

import 'app_state.dart';
import 'common_uis.dart' as common_uis;
import 'extensions.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'viewing_page.dart';

class SearchingPageContents extends StatefulWidget {
  /// Creates a searching page contents.
  const SearchingPageContents({Key? key}) : super(key: key);

  @override
  State<SearchingPageContents> createState() => _SearchingPageContentsState();
}

class _SearchingPageContentsState extends State<SearchingPageContents> {
  final _controller = TextEditingController();
  // TODO: Update search result when memo store is updated.
  final _memos = <Memo>[];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    return  Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  _controller.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: localizations.searchMemos,
            ),
            controller: _controller,
            onSubmitted: _search,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _memos.length,
            itemBuilder: (context, i) {
              return Card(
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _memoCardContents(_memos[i], context, false),
                  ),
                  onTap: appState.mergingWithGoogleDrive ? null : () async {
                    await _viewMemo(_memos[i], context);
                  }
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final memos = memoStore.memos;
    setState(() {
      _memos.clear();
      for (final memo in memos) {
        if (memo.text.indexOf(query) >= 0) {
          _memos.add(memo);
        }
      }
    });
  }
}

Widget _memoCardContents(Memo memo, BuildContext context, bool unsynchronized) {
  // TODO: Move to common_uis.
  final localizations = AppLocalizations.of(context)!;
  final attributeStyle =
  common_uis.TsukimisouTextStyles.homePageMemoAttribute(context);
  final lastModified =
  DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
  final updated = lastModified.toSmartString();
  final contents = [
    Text(memo.text),
    Align(
      alignment: Alignment.centerRight,
      child: Text(
        localizations.updated(updated),
        style: attributeStyle,
      ),
    ),
  ];
  if (unsynchronized) {
    contents.add(
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          localizations.unsynchronized,
          style: attributeStyle,
        ),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: contents,
  );
}

Future<void> _viewMemo(Memo memo, BuildContext context) async {
  // TODO: Move to common_uis.
  if (!common_uis.hasLargeScreen()) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ViewingPage(memo: memo);
        },
      ),
    );
  } else {
    await common_uis.showTransitiningDialog(
      context: context,
      builder: (context) {
        return Center(
          child: SizedBox(
            width: 600.0,
            height: 600.0,
            child: Dialog(
              child: ViewingPage(memo: memo),
            ),
          ),
        );
      },
      barrierDismissible: false,
      transitionBuilder: common_uis.DialogTransitionBuilders.primary,
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: 300),
    );
  }
}
