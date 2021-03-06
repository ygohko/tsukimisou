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
import 'google_drive_file.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_google_drive_loader.dart';
import 'memo_store_google_drive_saver.dart';
import 'memo_store_local_loader.dart';
import 'memo_store_local_saver.dart';
import 'memo_store_merger.dart';
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
    final localizations = AppLocalizations.of(context)!;
    final memoStore = MemoStore.instance();
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tsukimisou),
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(memo.text),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${localizations.updated}${updated}'),
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
        tooltip: localizations.addAMemo,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: ThemeColors.primary,
              ),
              child: Text(localizations.tsukimisou,
                  style: const TextStyle(
                      color: ThemeColors.onPrimary, fontSize: 24)),
            ),
            subtitle(context, localizations.tags),
            const ListTile(
              title: const Text('Tags'),
            ),
            const ListTile(
              title: const Text('Will be'),
            ),
            const ListTile(
              title: const Text('Listed'),
            ),
            const ListTile(
              title: const Text('Here'),
            ),
            const Divider(),
            subtitle(context, localizations.googleDriveIntegration),
            ListTile(
              title: Text(localizations.synchronize),
              onTap: _mergeWithGoogleDrive,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    final memoStore = MemoStore.instance();
    final memoStoreLoader = await MemoStoreLocalLoader.fromFileName(
        memoStore, 'TsukimisouMemoStore.json');
    try {
      await memoStoreLoader.execute();
    } on IOException catch (exception) {
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
    Navigator.of(context).pop();
    showProgressIndicatorDialog(context);
    final file = GoogleDriveFile('test.txt');
    await file.writeAsString('Hello, World!\n????????????????????????!');
    Navigator.of(context).pop();
  }

  void _saveToGoogleDrive() async {
    Navigator.of(context).pop();
    showProgressIndicatorDialog(context);
    final memoStore = MemoStore.instance();
    final memoStoreGoogleDriveSaver =
        MemoStoreGoogleDriveSaver(memoStore, 'TsukimisouMemoStore.json');
    await memoStoreGoogleDriveSaver.execute();
    Navigator.of(context).pop();
  }

  void _loadFromGoogleDrive() async {
    Navigator.of(context).pop();
    showProgressIndicatorDialog(context);
    final memoStore = MemoStore.instance();
    final memoStoreGoogleDriveLoader =
        MemoStoreGoogleDriveLoader(memoStore, 'TsukimisouMemoStore.json');
    await memoStoreGoogleDriveLoader.execute();
    final memoStoreSaver = await MemoStoreLocalSaver.fromFileName(
        memoStore, 'TsukimisouMemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException catch (exception) {
      // Save error
      // Do nothing for now
    }
    setState(() {
      _updateShownMemos();
    });
    Navigator.of(context).pop();
  }

  Future<void> _mergeWithGoogleDrive() async {
    Navigator.of(context).pop();
    showProgressIndicatorDialog(context);
    final localizations = AppLocalizations.of(context)!;
    final fromMemoStore = MemoStore();
    final memoStoreGoogleDriveLoader =
        MemoStoreGoogleDriveLoader(fromMemoStore, 'TsukimisouMemoStore.json');
    try {
      await memoStoreGoogleDriveLoader.execute();
    } on IOException catch (exception) {
      // Load error
      await showErrorDialog(
          context, localizations.loadingMemoStoreFromGoogleDriveFailed);
      Navigator.of(context).pop();
      return;
    }
    final toMemoStore = MemoStore.instance();
    final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
    memoStoreMerger.execute();
    final memoStoreGoogleDriveSaver =
        MemoStoreGoogleDriveSaver(toMemoStore, 'TsukimisouMemoStore.json');
    try {
      await memoStoreGoogleDriveSaver.execute();
    } on IOException catch (exception) {
      // Save error
      await showErrorDialog(
          context, localizations.savingMemoStoreToGoogleDriveFailed);
      setState(() {
        _updateShownMemos();
      });
      Navigator.of(context).pop();
      return;
    }
    final memoStoreSaver = await MemoStoreLocalSaver.fromFileName(
        toMemoStore, 'TsukimisouMemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException catch (exception) {
      // Save error
      await showErrorDialog(
          context, localizations.savingMemoStoreToLocalStorageFailed);
    }
    setState(() {
      _updateShownMemos();
    });
    Navigator.of(context).pop();
  }

  void _updateShownMemos() {
    final memoStore = MemoStore.instance();
    final memos = memoStore.memos;
    _shownMemos = [...memos];
    _shownMemos.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  }
}
