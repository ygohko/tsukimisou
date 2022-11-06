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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform/platform.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_uis.dart' as common_uis;
import 'editing_page.dart';
import 'extensions.dart';
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
  var _commonUiInitialized = false;
  var _licenseAdded = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    if (!_commonUiInitialized) {
      common_uis.init(context);
      _commonUiInitialized = true;
    }
    if (!common_uis.hasLargeScreen()) {
      return _buildForSmallScreen(context);
    } else {
      return _buildForLargeScreen(context);
    }
  }

  Future<void> _initAsync() async {
    await _load();
    final platform = LocalPlatform();
    if (platform.isAndroid) {
      final initialText = await ReceiveSharingIntent.getInitialText();
      if (initialText != null) {
        _addMemo(initialText: initialText);
      }
    }
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

  void _addMemo({String? initialText}) async {
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EditingPage(initialText: initialText);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return OpenUpwardsPageTransitionsBuilder().buildTransitions(
              null, context, animation, secondaryAnimation, child);
        },
      ));
    } else {
      await common_uis.showTransitiningDialog(
        context: context,
        builder: (context) {
          final platform = LocalPlatform();
          return Center(
            child: SizedBox(
              width: 600.0,
              height: platform.isDesktop ? 600.0 : null,
              child: Dialog(
                child: EditingPage(initialText: initialText),
                elevation: 24,
              ),
            ),
          );
        },
        barrierDismissible: false,
        transitionBuilder: common_uis.DialogTransitionBuilders.editing,
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 300),
      );
    }
    setState(() {
      _updateShownMemos();
    });
  }

  void _viewMemo(Memo memo) async {
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) {
            return ViewingPage(memo: memo);
          },
        ),
      );
    } else {
      await common_uis.showTransitiningDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SizedBox(
              width: 600.0,
              height: 600.0,
              child: Dialog(
                child: ViewingPage(memo: memo),
              ),
            ),
          );
        },
        barrierDismissible: false,
        transitionBuilder: common_uis.DialogTransitionBuilders.primary,
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 300),
      );
    }
    setState(() {
      _updateShownMemos();
    });
  }

  Future<void> _mergeWithGoogleDrive() async {
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
    common_uis.showProgressIndicatorDialog(context);
    final localizations = AppLocalizations.of(context)!;
    final fromMemoStore = MemoStore();
    final loader = MemoStoreGoogleDriveLoader(fromMemoStore, 'MemoStore.json');
    try {
      await loader.execute();
    } on FileNotFoundException {
      // Loading failure can be ignored because the file may not exists. Do nothing.
    } on FileLockedException {
      // Loading failure caused by locked memo store.
      await common_uis.showErrorDialog(
          context,
          localizations.error,
          localizations.memoStoreIsLockedByOtherDevice,
          localizations.ok);
      Navigator.of(context).pop();
      return;
    } on Exception catch (exception) {
      // Other failure.
      await common_uis.showErrorDialog(
          context,
          localizations.error,
          localizations.loadingMemoStoreFromGoogleDriveFailed,
          localizations.ok);
      Navigator.of(context).pop();
      return;
    }
    final toMemoStore = MemoStore.instance();
    final merger = MemoStoreMerger(toMemoStore, fromMemoStore);
    merger.execute();
    final saver = MemoStoreGoogleDriveSaver(toMemoStore, 'MemoStore.json');
    try {
      await saver.execute();
    } on Exception catch (exception) {
      // Saving failed.
      await common_uis.showErrorDialog(context, localizations.error,
          localizations.savingMemoStoreToGoogleDriveFailed, localizations.ok);
      setState(() {
        _updateShownMemos();
      });
      Navigator.of(context).pop();
      return;
    }
    final localSaver =
        await MemoStoreLocalSaver.fromFileName(toMemoStore, 'MemoStore.json');
    try {
      localSaver.execute();
    } on FileSystemException catch (exception) {
      // Saving failed.
      await common_uis.showErrorDialog(context, localizations.error,
          localizations.savingMemoStoreToLocalStorageFailed, localizations.ok);
    }
    setState(() {
      _updateShownMemos();
    });
    Navigator.of(context).pop();
  }

  void _showAbout() async {
    if (!_licenseAdded) {
      _addLicenses();
      _licenseAdded = true;
    }
    final localizations = AppLocalizations.of(context)!;
    final packageInfo = await PackageInfo.fromPlatform();
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
    showAboutDialog(
      context: context,
      applicationName: localizations.tsukimisou,
      applicationVersion: packageInfo.version,
      applicationIcon: Image(
        image: AssetImage('assets/images/about_icon.png'),
      ),
      applicationLegalese: '(c) 2022 Yasuaki Gohko',
    );
  }

  void _showPrivacyPolicy() async {
    await launch('https://sites.gonypage.jp/home/tsukimisou/privacy-policy');
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildForSmallScreen(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tsukimisou),
      ),
      body: Scrollbar(
        child: _memoListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: localizations.addAMemo,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: _drawerListView(true),
      ),
    );
  }

  Widget _buildForLargeScreen(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    late double drawerWidth;
    final windowWidth = MediaQuery.of(context).size.width;
    if (windowWidth > 512.0) {
      drawerWidth = 256.0;
    } else {
      drawerWidth = windowWidth / 2.0;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tsukimisou),
      ),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 0.0,
              maxWidth: drawerWidth,
            ),
            child: _drawerListView(false),
          ),
          Expanded(
            child: Scrollbar(
              child: _memoListView(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: localizations.addAMemo,
        child: const Icon(Icons.add),
      ),
    );
  }

  ListView _memoListView() {
    return ListView.builder(
      itemCount: _shownMemos.length,
      itemBuilder: (context, i) {
        final localizations = AppLocalizations.of(context)!;
        final attributeStyle =
            common_uis.TsukimisouTextStyles.homePageMemoAttribute(context);
        final memo = _shownMemos[(_shownMemos.length - 1) - i];
        final updated = DateTime.fromMillisecondsSinceEpoch(memo.lastModified)
            .toSmartString();
        final lastModified = DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
        final lastMerged = DateTime.fromMillisecondsSinceEpoch(MemoStore.instance().lastMerged);
        final contents = [
          Text(memo.text),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              localizations.updated(updated),
              style: attributeStyle,
            ),
          ),
        ];
        if (lastModified.isAfter(lastMerged)) {
          contents.add(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                localizations.unsynchronized,
                style: attributeStyle,
              ),
            ),
          );
        }
        return Card(
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contents,
              ),
            ),
            onTap: () {
              _viewMemo(memo);
            },
          ));
        },
    );
  }

  ListView _drawerListView(bool primary) {
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
    final privacyPolicyIndex = aboutIndex + 1;
    final drawerItemCount = privacyPolicyIndex + 1;
    final localizations = AppLocalizations.of(context)!;
    return ListView.builder(
      primary: primary,
      itemCount: drawerItemCount,
      itemBuilder: (context, i) {
        if (i == headerIndex) {
          return SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: common_uis.TsukimisouColors.primary,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    localizations.showingMemos(_shownMemos.length,
                        memoStore.memos.length, tags.length),
                    style: const TextStyle(
                        color: common_uis.TsukimisouColors.onPrimary)),
              ),
            ),
          );
        } else if (i == allMemosIndex) {
          return ListTile(
            title: Text(localizations.allMemos),
            onTap: _disableFiltering,
            selected: !_filteringEnabled,
            selectedColor: common_uis.TsukimisouColors.primary,
            selectedTileColor: common_uis.TsukimisouColors.primaryLight,
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
            selectedColor: common_uis.TsukimisouColors.primary,
            selectedTileColor: common_uis.TsukimisouColors.primaryLight,
          );
        } else if (i == integrationDividerIndex) {
          return const Divider();
        } else if (i == integrationSubtitleIndex) {
          return common_uis.subtitle(
              context, localizations.googleDriveIntegration);
        } else if (i == synchronizeIndex) {
          return ListTile(
            title: Text(localizations.synchronize),
            onTap: _mergeWithGoogleDrive,
          );
        } else if (i == othersDividerIndex) {
          return const Divider();
        } else if (i == othersSubtitleIndex) {
          return common_uis.subtitle(context, localizations.others);
        } else if (i == aboutIndex) {
          return ListTile(
            title: Text(localizations.about),
            onTap: _showAbout,
          );
        } else {
          return ListTile(
            title: Text(localizations.privacyPolicy),
            onTap: _showPrivacyPolicy,
          );
        }
      },
    );
  }

  void _filter(String tag) {
    _filteringTag = tag;
    _filteringEnabled = true;
    setState(() {
      _updateShownMemos();
    });
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
  }

  void _disableFiltering() {
    _filteringEnabled = false;
    setState(() {
      _updateShownMemos();
    });
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
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
    if (_shownMemos.length <= 0) {
      _filteringEnabled = false;
      _shownMemos = [...memos];
    }
    _shownMemos.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  }

  void _addLicenses() async {
    LicenseRegistry.addLicense(() async* {
      var text = await rootBundle.loadString('assets/licenses/noto_fonts.txt');
      yield LicenseEntryWithLineBreaks(
        ['Noto Fonts'],
        text,
      );
      text = await rootBundle.loadString('assets/licenses/tsukimisou.txt');
      yield LicenseEntryWithLineBreaks(
        ['Tsukimisou'],
        text,
      );
    });
  }
}
