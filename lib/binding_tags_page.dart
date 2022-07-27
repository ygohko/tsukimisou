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

class BindingTagsPage extends StatefulWidget {
  final Memo memo;
  final List<String> additinalTags;

  /// Creates a binding tags page.
  const BindingTagsPage({Key? key, required this.memo, required this.additinalTags}) : super(key: key);

  @override
  State<BindingTagsPage> createState() => _BindingTagsPageState();
}

class _BindingTagsPageState extends State<BindingTagsPage> {
  List<String> _candidateTags = [];
  List<String> _boundTags = [];

  @override
  void initState() {
    _candidateTags = [...widget.memo.tags];
    for (final tag in widget.additinalTags) {
      if (!_candidateTags.contains(tag)) {
        _candidateTags.add(tag);
      }
    }
    _boundTags = [...widget.memo.tags];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final listCount = _candidateTags.length + 1;
    final itemCount = listCount * 2;
    return WillPopScope(
      onWillPop: _apply,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.bindTags),
        ),
        body: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, i) {
            if (i.isOdd) {
              return const Divider();
            }

            final index = i ~/ 2;
            if (index == listCount - 1) {
              return ListTile(
                title: Text(localizations.addANewTag),
                onTap: _addTag,
              );
            }
            final tag = _candidateTags[index];
            final bound = _boundTags.contains(tag);
            return ListTile(
              title: Text(tag),
              trailing: Icon(
                bound ? Icons.check_circle : Icons.check_circle_outline,
                color: bound ? Colors.blue : null,
              ),
              onTap: () {
                setState(() {
                    if (bound) {
                      _boundTags.remove(tag);
                    } else {
                      _boundTags.add(tag);
                    }
                });
              }
            );
          },
        ),
      ),
    );
  }

  void _addTag() async {
    final localizations = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    var accepted = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.addANewTagTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: localizations.enterATagName),
            autofocus: true,
          ),
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
      },
    );
    if (accepted) {
      var added = false;
      setState(() {
        final tag = controller.text;
        if (!_candidateTags.contains(tag)) {
          _candidateTags.add(tag);
          added = true;
        }
        if (!_boundTags.contains(tag)) {
          _boundTags.add(tag);
        }
      });
      if (!added) {
        final snackBar = SnackBar(
          content: Text(localizations.thatTagAlreadyExists),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<bool> _apply() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = MemoStore.instance();
    final memo = widget.memo;
    memo.tags = [..._boundTags];
    final memoStoreSaver = await MemoStoreLocalSaver.fromFileName(
        memoStore, 'TsukimisouMemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException catch (exception) {
      // Save error
      await showErrorDialog(
          context, localizations.savingMemoStoreToLocalStorageFailed);
    }

    return true;
  }
}
