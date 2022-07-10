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
import 'google_drive_file.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_google_drive_loader.dart';
import 'memo_store_google_drive_saver.dart';
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
            final updated =
                DateTime.fromMillisecondsSinceEpoch(memo.lastModified)
                    .toString();
            return Card(
                child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(memo.text),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Updated: ${updated}'),
                      ),
                    ]),
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
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF00003F),
              ),
              child: Text('Tsukimisou', style:TextStyle(color: Colors.white, fontSize: 24)),
            ),
            // TODO: Add a helper function
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('Google Drive tests', style: Theme.of(context).textTheme.caption, textAlign: TextAlign.start),
                ),
              ),
            ListTile(
              title: Text('Test Google Drive'),
              onTap: _testGoogleDrive,
            ),
            ListTile(
              title: Text('Save to Google Drive'),
              onTap: _saveToGoogleDrive,
            ),
            ListTile(
              title: Text('Load from Google Drive'),
              onTap: _loadFromGoogleDrive,
            ),
            Divider(),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('Tags', style: Theme.of(context).textTheme.caption, textAlign: TextAlign.start),
                ),
              ),
            ListTile(
              title: Text('Tags'),
            ),
            ListTile(
              title: Text('Will be'),
            ),
            ListTile(
              title: Text('Listed'),
            ),
            ListTile(
              title: Text('Here'),
            ),
          ],
        ),
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
      _updateShownMemos();
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
      _updateShownMemos();
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
      _updateShownMemos();
    });
  }

  void _testGoogleDrive() async {
    final file = GoogleDriveFile('test.txt');
    await file.writeAsString('Hello, World!\nこんにちわ、世界!');
  }

  void _saveToGoogleDrive() async {
    final memoStore = MemoStore.getInstance();
    final memoStoreGoogleDriveSaver = MemoStoreGoogleDriveSaver(memoStore, 'TsukimisouMemoStore.json');
    await memoStoreGoogleDriveSaver.execute();
  }

  void _loadFromGoogleDrive() async {
    final memoStore = MemoStore.getInstance();
    final memoStoreGoogleDriveLoader = MemoStoreGoogleDriveLoader(memoStore, 'TsukimisouMemoStore.json');
    await memoStoreGoogleDriveLoader.execute();
    setState(() {
      _updateShownMemos();
    });
  }

  void _updateShownMemos() {
    final memoStore = MemoStore.getInstance();
    final memos = memoStore.memos;
    _shownMemos = [...memos];
    _shownMemos.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  }
}
