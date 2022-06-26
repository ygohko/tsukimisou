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

import 'memo_store.dart';
import 'memo_store_saver.dart';

class EditingPage extends StatefulWidget {
  const EditingPage({Key? key}) : super(key: key);

  @override
  State<EditingPage> createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
  final _controller = TextEditingController();

  void _save() async {
    final memo_store = MemoStore.getInstance();
    memo_store.addMemo(_controller.text);
    final memo_store_saver = await MemoStoreSaver.getFromFileName(memo_store, 'TsukimisouMemoStore.json');
    memo_store_saver.execute();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a new memo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Card(
          child: SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _controller,
              maxLines: null,
            ),
          ),
        ),
      ),
    );
  }
}

