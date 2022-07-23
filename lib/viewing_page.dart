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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'common_uis.dart';
import 'editing_page.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_local_saver.dart';

class ViewingPage extends StatefulWidget {
  final Memo memo;

  /// Creates a viewing page.
  const ViewingPage({Key? key, required this.memo}) : super(key: key);

  @override
  State<ViewingPage> createState() => _ViewingPageState();
}

class _ViewingPageState extends State<ViewingPage> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(widget.memo.lastModified);
    var tagsString = '';
    for (final tag in widget.memo.tags) {
      tagsString += tag + ', ';
    }
    if (tagsString != '') {
      tagsString = tagsString.substring(0, tagsString.length - 2);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.memoAtDateTime(dateTime.toString())),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
            tooltip: localizations.delete,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _edit,
            tooltip: localizations.edit,
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(widget.memo.text),
              ),
            ),
          ),
          ListTile(
            title: Text(localizations.updated + dateTime.toString()),
          ),
          const Divider(),
          ListTile(
            title: Text(localizations.boundTags(tagsString)),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _edit() async {
    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditingPage(memo: widget.memo);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return OpenUpwardsPageTransitionsBuilder().buildTransitions(
            null, context, animation, secondaryAnimation, child);
      },
    ));
    setState(() {});
  }

  void _delete() async {
    final localizations = AppLocalizations.of(context)!;
    var accepted = false;
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(localizations.confirm),
              content: Text(localizations.doYouReallyWantToDeleteThisMemo),
              actions: [
                FlatButton(
                    child: Text(localizations.cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                FlatButton(
                    child: Text(localizations.ok),
                    onPressed: () {
                      accepted = true;
                      Navigator.of(context).pop();
                    }),
              ]);
        });
    if (!accepted) {
      return;
    }

    final memoStore = MemoStore.instance();
    memoStore.removeMemo(widget.memo);
    final memoStoreSaver = await MemoStoreLocalSaver.fromFileName(
        memoStore, 'TsukimisouMemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException catch (exception) {
      // Save error
      await showErrorDialog(
          context, localizations.savingMemoStoreToLocalStorageFailed);
    }
    Navigator.of(context).pop();
  }
}
