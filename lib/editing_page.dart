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

import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_saver.dart';

class EditingPage extends StatefulWidget {
  final Memo? memo;

  const EditingPage({Key? key, this.memo}) : super(key: key);

  @override
  State<EditingPage> createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.memo != null) {
      _controller.text = widget.memo!.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    var title = 'Add a new memo';
    if (widget.memo != null) {
      title = 'Edit a memo';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: TextField(
            controller: _controller,
            autofocus: true,
            expands: true,
            maxLines: null,
            minLines: null,
          ),
        ),
      ),
    );
  }

  void _save() async {
    final memoStore = MemoStore.getInstance();
    if (widget.memo == null) {
      // Add a new memo
      final memo = Memo();
      memo.text = _controller.text;
      memoStore.addMemo(memo);
    } else {
      // Update a memo
      widget.memo!.text = _controller.text;
    }
    final memoStoreSaver = await MemoStoreSaver.getFromFileName(
        memoStore, 'TsukimisouMemoStore.json');
    try {
      memoStoreSaver.execute();
    } on FileSystemException catch (exception) {
      // Save error
      // Do nothing for now
    }
    Navigator.of(context).pop();
  }
}
