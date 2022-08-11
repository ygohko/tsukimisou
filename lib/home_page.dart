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
import 'package:package_info_plus/package_info_plus.dart';

import 'common_uis.dart' as common_uis;
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
  var _filteringTag = '';
  var _filteringEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    const headerIndex = 0;
    const allMemosIndex = 1;
    const tagsSubtitleIndex = 2;
    const tagsBeginIndex = 3;
    final memoStore = MemoStore.instance();
    final tags = memoStore.tags;
    final tagsEndIndex = tagsBeginIndex + tags.length - 1;
    final integrationDividerIndex = tagsEndIndex + 1;
    final integrationSubtitleIndex = integrationDividerIndex + 1;
    final synchronizeIndex = integrationSubtitleIndex + 1;
    final othersDividerIndex = synchronizeIndex + 1;
    final othersSubtitleIndex = othersDividerIndex + 1;
    final aboutIndex = othersSubtitleIndex + 1;
    final drawerItemCount = aboutIndex + 1;
    final localizations = AppLocalizations.of(context)!;
    final attributeStyle = common_uis.TextTheme.homePageMemoAttribute(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tsukimisou),
      ),
      body: ListView.builder(
          itemCount: _shownMemos.length,
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
                        child: Text(
                          localizations.updated(updated),
                          style: attributeStyle,
                        ),
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
        child: ListView.builder(
          itemCount: drawerItemCount,
          itemBuilder: (context, i) {
            if (i == headerIndex) {
              return SizedBox(
                height: 120,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: common_uis.ColorTheme.primary,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        localizations.showingMemos(_shownMemos.length,
                            memoStore.memos.length, tags.length),
                        style: const TextStyle(
                            color: common_uis.ColorTheme.onPrimary)),
                  ),
                ),
              );
            } else if (i == allMemosIndex) {
              return ListTile(
                title: Text(localizations.allMemos),
                onTap: _disableFiltering,
                selected: !_filteringEnabled,
                selectedColor: common_uis.ColorTheme.primary,
                selectedTileColor: common_uis.ColorTheme.primaryLight,
              );
            } else if (i == tagsSubtitleIndex) {
              return common_uis.subtitle(context, localizations.tags);
            } else if (i >= tagsBeginIndex && i <= tagsEndIndex) {
              final tag = tags[i - tagsBeginIndex];
              return ListTile(
                title: Text(tag),
                onTap: () {
                  _filter(tag);
                },
                selected: _filteringEnabled && _filteringTag == tag,
                selectedColor: common_uis.ColorTheme.primary,
                selectedTileColor: common_uis.ColorTheme.primaryLight,
              );
            } else if (i == integrationDividerIndex) {
              return const Divider();
            } else if (i == integrationSubtitleIndex) {
              return common_uis.subtitle(
                  context, localizations.googleDriveIntegration);
            } else if (i == synchronizeIndex){
              return ListTile(
                title: Text(localizations.synchronize),
                onTap: _mergeWithGoogleDrive,
              );
            } else if (i == othersDividerIndex) {
              return const Divider();
            } else if (i == othersSubtitleIndex) {
              return common_uis.subtitle(
                context, localizations.others);
            } else {
              return ListTile(
                title: Text(localizations.about),
                onTap: _showAbout,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _load() async {
    final memoStore = MemoStore.instance();
    final memoStoreLoader =
        await MemoStoreLocalLoader.fromFileName(memoStore, 'MemoStore.json');
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

  Future<void> _mergeWithGoogleDrive() async {
    Navigator.of(context).pop();
    common_uis.showProgressIndicatorDialog(context);
    final localizations = AppLocalizations.of(context)!;
    final fromMemoStore = MemoStore();
    final memoStoreGoogleDriveLoader =
        MemoStoreGoogleDriveLoader(fromMemoStore, 'MemoStore.json');
    try {
      await memoStoreGoogleDriveLoader.execute();
    } on HttpException {
      // Loading failure can be ignored because the file may not exists. Do nothing.
    } on Exception catch (exception) {
      // Other failure.
      await common_uis.showErrorDialog(
          context, localizations.loadingMemoStoreFromGoogleDriveFailed);
      Navigator.of(context).pop();
      return;
    }
    final toMemoStore = MemoStore.instance();
    final memoStoreMerger = MemoStoreMerger(toMemoStore, fromMemoStore);
    memoStoreMerger.execute();
    final memoStoreGoogleDriveSaver =
        MemoStoreGoogleDriveSaver(toMemoStore, 'MemoStore.json');
    try {
      await memoStoreGoogleDriveSaver.execute();
    } on Exception catch (exception) {
      // Saving failed.
      await common_uis.showErrorDialog(
          context, localizations.savingMemoStoreToGoogleDriveFailed);
      setState(() {
        _updateShownMemos();
      });
      Navigator.of(context).pop();
      return;
    }
    final memoStoreSaver =
        await MemoStoreLocalSaver.fromFileName(toMemoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on FileSystemException catch (exception) {
      // Saving failed.
      await common_uis.showErrorDialog(
          context, localizations.savingMemoStoreToLocalStorageFailed);
    }
    setState(() {
      _updateShownMemos();
    });
    Navigator.of(context).pop();
  }

  void _showAbout() async {
    final localizations = AppLocalizations.of(context)!;
    final packageInfo = await PackageInfo.fromPlatform();
    Navigator.of(context).pop();
    showAboutDialog(
      context: context,
      applicationName: localizations.tsukimisou,
      applicationVersion: packageInfo.version,
      applicationLegalese: '(c) 2022 Yasuaki Gohko',
    );
  }

  void _filter(String tag) {
    _filteringTag = tag;
    _filteringEnabled = true;
    setState(() {
      _updateShownMemos();
    });
    Navigator.of(context).pop();
  }

  void _disableFiltering() {
    _filteringEnabled = false;
    setState(() {
      _updateShownMemos();
    });
    Navigator.of(context).pop();
  }

  void _updateShownMemos() {
    final memoStore = MemoStore.instance();
    final memos = memoStore.memos;
    if (!_filteringEnabled) {
      _shownMemos = [...memos];
    } else {
      _shownMemos.clear();
      for (final memo in memos) {
        if (memo.tags.contains(_filteringTag)) {
          _shownMemos.add(memo);
        }
      }
    }
    _shownMemos.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  }
}
