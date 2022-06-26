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
import 'memo_store.dart';
import 'memo_store_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _memoStore = MemoStore.getInstance();
  var _initialized = false;

  Future<void> _initialize() async {
    final memoStore = MemoStore.getInstance();
    final memoStoreLoader = await MemoStoreLoader.getFromFileName(memoStore, 'TsukimisouMemoStore.json');
    try {
      await memoStoreLoader.execute();
    }
    on FileSystemException catch (exception) {
      // Load error
      // Do nothing for now
    }
    setState(() {
    });
    _initialized = true;
  }

  void _addMemo() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EditingPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return OpenUpwardsPageTransitionsBuilder().buildTransitions(null, context, animation, secondaryAnimation, child);
        },
      )
    );
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    if (!_initialized) {
      _initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tsukimisou'),
      ),
      body: ListView.builder(
        itemCount: _memoStore.getMemos().length,
        itemBuilder: (context, i) {
          final memos = _memoStore.getMemos();
          return Card(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(memos[(memos.length - 1) - i]),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: 'Add a memo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
