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
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_local_saver.dart';

class EditingPage extends StatefulWidget {
  final Memo? memo;

  /// Creates a editing page.
  const EditingPage({Key? key, this.memo}) : super(key: key);

  @override
  State<EditingPage> createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final memo = widget.memo;
    if (memo != null) {
      _controller.text = memo.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    var title = localizations.addANewMemo;
    if (widget.memo != null) {
      title = localizations.editAMemo;
    }
    return WillPopScope(
      onWillPop: _confirm,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: _save,
              tooltip: localizations.save,
            ),
          ],
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
          ),
        ),
      ),
    );
  }

  void _save() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = MemoStore.instance();
    final memo = widget.memo;
    if (memo == null) {
      // Add a new memo
      final newMemo = Memo();
      newMemo.text = _controller.text;
      memoStore.addMemo(newMemo);
    } else {
      // Update a memo
      memo.text = _controller.text;
    }
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

  Future<bool> _confirm() async {
    final localizations = AppLocalizations.of(context)!;
    final memo = widget.memo;
    if (memo == null) {
      if (_controller.text == '') {
        return true;
      }
    } else {
      if (_controller.text == memo.text) {
        return true;
      }
    }

    var accepted = false;
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(localizations.confirm),
              content: Text(localizations.doYouReallyWantToDiscardTheChanges),
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

    return accepted;
  }
}
