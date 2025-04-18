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
import 'extensions.dart';
import 'factories.dart';
import 'memo.dart';
import 'memo_store.dart';

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
      leading = const BackButton();
    } else {
      leading = const CloseButton();
    }
    final size = MediaQuery.of(context).size;
    final width = widget.fullScreen ? size.width : MemoDialogsSize.width;
    final height = widget.fullScreen ? size.height : MemoDialogsSize.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _confirm,
      child: SizedBox(
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
            color: TsukimisouColors.memoCard,
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              expands: true,
              maxLines: null,
              minLines: null,
              style: TsukimisouTextStyles.editingPageTextField(context),
              decoration: const InputDecoration(
                filled: true,
                fillColor: TsukimisouColors.memoCard,
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
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
      final lastModified =
          DateTime.fromMillisecondsSinceEpoch(newMemo.lastModified);
      newMemo.name = lastModified.toDetailedString();
      memoStore.addMemo(newMemo);
    } else {
      // Update a memo
      memo.beginModification();
      memo.text = _controller.text;
      memoStore.markAsChanged();
    }
    final memoStoreSaver = await factories.memoStoreLocalSaverFromFileName(
        memoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException {
      if (mounted) {
        // Save error
        await showErrorDialog(
            context,
            localizations.savingWasFailed,
            localizations.couldNotSaveMemoStoreToLocalStorage,
            localizations.ok);
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _confirm(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    final memo = widget.memo;
    if (memo == null) {
      if (_controller.text == '') {
        Navigator.of(context).pop();

        return;
      }
    } else {
      if (_controller.text == memo.text) {
        Navigator.of(context).pop();

        return;
      }
    }
    final accepted = await showConfirmationDialog(
        context,
        localizations.discardThisChanges,
        localizations.thisActionCannotBeUndone,
        localizations.ok,
        localizations.cancel,
        true);
    if (!mounted) {
      return;
    }
    if (accepted) {
      Navigator.of(context).pop();
    }
  }
}
