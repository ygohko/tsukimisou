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
import 'package:provider/provider.dart';

import 'common_uis.dart';
import 'factories.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_local_saver.dart';

class EditingPage extends StatefulWidget {
  final Memo? memo;
  final String? initialText;
  final bool fullScreen;

  /// Creates a editing page.
  const EditingPage(
      {Key? key, this.memo, this.initialText, this.fullScreen = true})
      : super(key: key);

  @override
  State<EditingPage> createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final memo = widget.memo;
    final initialText = widget.initialText;
    if (memo != null) {
      _controller.text = memo.text;
    } else if (initialText != null) {
      _controller.text = initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    var title = localizations.addANewMemo;
    if (widget.memo != null) {
      title = localizations.editAMemo;
    }
    late Widget leading;
    if (hasLargeScreen() && widget.memo != null) {
      leading = BackButton();
    } else {
      leading = CloseButton();
    }
    final size = MediaQuery.of(context).size;
    // TODO: Add constants for dialog size.
    final width = widget.fullScreen ? size.width : 520.0;
    final height = widget.fullScreen ? size.height : 555.0;
    return WillPopScope(
      onWillPop: _confirm,
      child: Container(
        width: width,
        height: height,
        child: Scaffold(
          appBar: AppBar(
            leading: leading,
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
      ),
    );
  }

  void _save() async {
    final localizations = AppLocalizations.of(context)!;
    final factories = Factories.instance();
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final memo = widget.memo;
    if (memo == null) {
      // Add a new memo
      final newMemo = Memo();
      newMemo.text = _controller.text;
      memoStore.addMemo(newMemo);
    } else {
      // Update a memo
      memo.text = _controller.text;
      memoStore.notifyListeners();
    }
    final memoStoreSaver = await factories.memoStoreLocalSaverFromFileName(
        memoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException catch (exception) {
      // Save error
      await showErrorDialog(context, localizations.savingWasFailed,
          localizations.couldNotSaveMemoStoreToLocalStorage, localizations.ok);
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
    final accepted = await showConfirmationDialog(
        context,
        localizations.discardThisChanges,
        localizations.thisActionCannotBeUndone,
        localizations.ok,
        localizations.cancel,
        true);

    return accepted;
  }
}
