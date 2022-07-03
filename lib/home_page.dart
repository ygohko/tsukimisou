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

import 'editing_page.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_loader.dart';
import 'viewing_page.dart';

class HomePage extends StatefulWidget {
  /// Creates a home page.
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _shownMemos = <Memo>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final memoStore = MemoStore.getInstance();
    return Scaffold(
      appBar: AppBar(
        title: Text('Tsukimisou'),
      ),
      body: ListView.builder(
          itemCount: memoStore.memos.length,
          itemBuilder: (context, i) {
            final memo = _shownMemos[(_shownMemos.length - 1) - i];
            return Card(
                child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(memo.text),
              ),
              onTap: () {
                print('tapped ${memo.text}');
                _viewMemo(memo);
              },
            ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: 'Add a memo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _load() async {
    final memoStore = MemoStore.getInstance();
    final memoStoreLoader = await MemoStoreLoader.fromFileName(
        memoStore, 'TsukimisouMemoStore.json');
    try {
      await memoStoreLoader.execute();
    } on FileSystemException catch (exception) {
      // Load error
      // Do nothing for now
    }
    setState(() {
      updateShownMemos();
    });
  }

  void _addMemo() async {
    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditingPage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return OpenUpwardsPageTransitionsBuilder().buildTransitions(
            null, context, animation, secondaryAnimation, child);
      },
    ));
    setState(() {
      updateShownMemos();
    });
  }

  void _viewMemo(Memo memo) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ViewingPage(memo: memo);
        },
      ),
    );
    setState(() {
      updateShownMemos();
    });
  }

  void updateShownMemos() {
    final memoStore = MemoStore.getInstance();
    final memos = memoStore.memos;
    _shownMemos = [...memos];
    _shownMemos.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  }
}
