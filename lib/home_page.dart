/*
 * Copyright (c) 2022 - 2025 Yasuaki Gohko
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
import 'package:platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'app_state.dart';
import 'common_uis.dart' as common_uis;
import 'editing_page.dart';
import 'extensions.dart';
import 'google_drive_file.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_google_drive_loader.dart';
import 'memo_store_google_drive_saver.dart';
import 'memo_store_loader.dart';
import 'memo_store_local_loader.dart';
import 'memo_store_local_saver.dart';
import 'memo_store_merger.dart';
import 'searching_page.dart';
import 'searching_page_contents.dart';
import 'settings.dart';
import 'settings_page.dart';
import 'gen_l10n/app_localizations.dart';

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
  var _savingToGoogleDrive = false;
  var _searching = false;
  var _fileLockedCount = 0;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final settings = Provider.of<Settings>(context);
    await settings.init();
    setState(() {});
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
    const platform = LocalPlatform();
    if (platform.isAndroid) {
      final intent = ReceiveSharingIntent.instance;
      final medias = await intent.getInitialMedia();
      if (medias.isNotEmpty) {
        final media = medias[0];
        if (media.mimeType == 'text/plain') {
          final text = media.path;
          intent.reset();
          _addMemo(initialText: text);
        } else {
          intent.reset();
        }
      }
    }
  }

  Future<void> _load() async {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final memoStoreLoader =
        await MemoStoreLocalLoader.fromFileName(memoStore, 'MemoStore.json');
    try {
      await memoStoreLoader.execute();
    } on FileNotCompatibleException {
      if (mounted) {
        // Not compatible error.
        // TODO: Showing error at here may cause problem. Check this later.
        final localizations = AppLocalizations.of(context)!;
        await common_uis.showErrorDialog(
            context,
            localizations.memoStoreIsNotCompatible,
            localizations.memoStoreInTheLocalStorageIsNotCompatible,
            localizations.ok);
      }
    } on IOException {
      // Load error
      // Do nothing for now
    }
  }

  void _addMemo({String? initialText}) async {
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EditingPage(initialText: initialText);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return const OpenUpwardsPageTransitionsBuilder().buildTransitions(
              null, context, animation, secondaryAnimation, child);
        },
        transitionDuration: common_uis.Durations.editing,
        reverseTransitionDuration: common_uis.Durations.editing,
      ));
    } else {
      await common_uis.showTransitioningDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(0.0),
              elevation: 24,
              child: EditingPage(initialText: initialText, fullScreen: false),
            ),
          );
        },
        barrierDismissible: false,
        transitionBuilder: common_uis.DialogTransitionBuilders.editing,
        curve: Curves.fastOutSlowIn,
        duration: common_uis.Durations.editing,
      );
    }
  }

  Future<void> _mergeWithGoogleDrive() async {
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
    final localizations = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    appState.mergingWithGoogleDrive = true;
    _showSynchronizingBanner();
    final toMemoStore = Provider.of<MemoStore>(context, listen: false);
    final fromMemoStore = MemoStore();
    final loader = MemoStoreGoogleDriveLoader(fromMemoStore, 'MemoStore.json');
    try {
      await loader.execute();
    } on FileNotFoundException {
      // Loading failure can be ignored because the file may not exists. Do nothing.
    } on FileLockedException {
      // Loading failure caused by locked memo store.
      _fileLockedCount++;
      if (_fileLockedCount < 3) {
        messenger.hideCurrentMaterialBanner();
        appState.mergingWithGoogleDrive = false;
        if (!mounted) {
          return;
        }
        await common_uis.showErrorDialog(
            context,
            localizations.memoStoreIsLocked,
            localizations.memoStoreIsLockedByOtherDevice,
            localizations.ok);
        return;
      } else {
        // Confirm to force unlock
        messenger.hideCurrentMaterialBanner();
        appState.mergingWithGoogleDrive = false;
        if (!mounted) {
          return;
        }
        final accepted = await common_uis.showConfirmationDialog(
            context,
            localizations.memoStoreIsLocked,
            localizations.memoStoreIsStillLocked,
            localizations.unlock,
            localizations.cancel,
            false);
        if (accepted) {
          await _unlockGoogleDrive();
        }
        return;
      }
    } on FileNotCompatibleException {
      // Not compatible error.
      messenger.hideCurrentMaterialBanner();
      appState.mergingWithGoogleDrive = false;
      if (!mounted) {
        return;
      }
      await common_uis.showErrorDialog(
          context,
          localizations.memoStoreIsNotCompatible,
          localizations.memoStoreOnTheGoogleDriveIsNotCompatible,
          localizations.ok);
      return;
    } on Exception {
      // Other failure.
      messenger.hideCurrentMaterialBanner();
      appState.mergingWithGoogleDrive = false;
      if (!mounted) {
        return;
      }
      await common_uis.showErrorDialog(context, localizations.loadingWasFailed,
          localizations.couldNotLoadMemoStoreFromGoogleDrive, localizations.ok);
      return;
    }
    _fileLockedCount = 0;
    final merger = MemoStoreMerger(toMemoStore, fromMemoStore);
    merger.conflictWarningText = localizations.thisMemoHasConflicts;
    merger.localMarkerText = localizations.local;
    merger.cloudMarkerText = localizations.cloud;
    merger.execute();

    final localSaver =
        await MemoStoreLocalSaver.fromFileName(toMemoStore, 'MemoStore.json');
    try {
      localSaver.execute();
    } on FileSystemException {
      // Saving failed.
      messenger.hideCurrentMaterialBanner();
      appState.mergingWithGoogleDrive = false;
      if (mounted) {
        await common_uis.showErrorDialog(
            context,
            localizations.savingWasFailed,
            localizations.couldNotSaveMemoStoreToLocalStorage,
            localizations.ok);
      }
      return;
    }
    messenger.hideCurrentMaterialBanner();
    appState.mergingWithGoogleDrive = false;

    setState(() {
      _savingToGoogleDrive = true;
    });
    final saver = MemoStoreGoogleDriveSaver(toMemoStore, 'MemoStore.json');
    try {
      await saver.execute();
    } on Exception {
      // Saving failed.
      if (mounted) {
        await common_uis.showErrorDialog(context, localizations.savingWasFailed,
            localizations.couldNotSaveMemoStoreToGoogleDrive, localizations.ok);
      }
    }
    setState(() {
      _savingToGoogleDrive = false;
    });
  }

  Future<void> _unlockGoogleDrive() async {
    final file = GoogleDriveFile('MemoStore.json');
    await file.unlock();
  }

  Future<void> _searchForSmallScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const SearchingPage();
        },
      ),
    );
  }

  void _searchForLargeScreen() {
    setState(() {
      _searching = true;
    });
  }

  void _showSettings() async {
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return const SettingsPage(fullScreen: true);
          },
        ),
      );
    } else {
      await common_uis.showTransitioningDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: SizedBox(
              width: 450.0,
              height: 215.0,
              child: SettingsPage(fullScreen: false),
            ),
          );
        },
        barrierDismissible: false,
        transitionBuilder: common_uis.DialogTransitionBuilders.editing,
        curve: Curves.fastOutSlowIn,
        duration: common_uis.Durations.editing,
      );
    }
  }

  void _showSynchronizingBanner() {
    final localizations = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 17.0,
              height: 17.0,
              child: CircularProgressIndicator(
                color: common_uis.TsukimisouColors.scheme.primaryContainer,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(localizations.synchronizing,
                style: TextStyle(
                  color: common_uis.TsukimisouColors.scheme.onSecondary,
                )),
            const Spacer(),
          ],
        ),
        backgroundColor: common_uis.TsukimisouColors.scheme.secondary,
        actions: [
          const Text(''),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text(localizations.dismiss,
                style: TextStyle(
                  color: common_uis.TsukimisouColors.scheme.primaryContainer,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildForSmallScreen(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tsukimisou),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchForSmallScreen,
            tooltip: localizations.search,
          ),
        ],
      ),
      body: Scrollbar(
        child: Consumer2<MemoStore, AppState>(
          builder: (context, memoStore, appState, child) {
            if (memoStore.memos.isNotEmpty) {
              _updateShownMemos();
              return _memoListView();
            } else {
              return common_uis.noMemosIndicator(
                  context, Icons.add, localizations.toCreateANewMemo);
            }
          },
        ),
      ),
      floatingActionButton: Consumer<AppState>(
        builder: (context, appState, child) {
          return FloatingActionButton(
            onPressed: appState.mergingWithGoogleDrive ? null : _addMemo,
            tooltip: localizations.addAMemo,
            child: const Icon(Icons.add),
          );
        },
      ),
      drawer: SafeArea(
        bottom: false,
        child: Drawer(
          child: Consumer3<MemoStore, AppState, Settings>(
            builder: (context, memoStore, appState, settings, child) {
              _updateShownMemos();
              return _drawerListView(true);
            },
          ),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searching ? null : _searchForLargeScreen,
            tooltip: _searching ? null : localizations.search,
          ),
        ],
      ),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 0.0,
              maxWidth: drawerWidth,
            ),
            child: Consumer2<MemoStore, AppState>(
              builder: (context, memoStore, appStore, child) {
                _updateShownMemos();
                return _drawerListView(false);
              },
            ),
          ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                late Widget rightPaneWidget;
                if (!_searching) {
                  rightPaneWidget = Consumer<MemoStore>(
                    builder: (context, memoStore, child) {
                      _updateShownMemos();
                      return _memoListView();
                    },
                  );
                } else {
                  rightPaneWidget = const SearchingPageContents();
                }
                const platform = LocalPlatform();
                if (platform.isMobile) {
                  rightPaneWidget = Scrollbar(
                    child: rightPaneWidget,
                  );
                }
                return rightPaneWidget;
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<AppState>(
        builder: (context, appState, child) {
          return FloatingActionButton(
            onPressed: appState.mergingWithGoogleDrive ? null : _addMemo,
            tooltip: localizations.addAMemo,
            child: const Icon(Icons.add),
          );
        },
      ),
      drawerEnableOpenDragGesture: false,
    );
  }

  ListView _memoListView() {
    return ListView.builder(
      itemCount: _shownMemos.length,
      itemBuilder: (context, i) {
        final appState = Provider.of<AppState>(context, listen: false);
        final settings = Provider.of<Settings>(context, listen: false);
        final memo = _shownMemos[i];
        final lastModified =
            DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
        final lastMerged = DateTime.fromMillisecondsSinceEpoch(
            Provider.of<MemoStore>(context, listen: false).lastMerged);
        late final bool unsynchronized;
        if (!settings.getSynchronizationHidden() &&
            lastModified.isAfter(lastMerged)) {
          unsynchronized = true;
        } else {
          unsynchronized = false;
        }
        return Card(
          color: common_uis.TsukimisouColors.memoCard,
          elevation: 2.0,
          child: InkWell(
            onTap: appState.mergingWithGoogleDrive
                ? null
                : () {
                    common_uis.viewMemo(context, memo);
                  },
            child: common_uis.memoCardContents(context, memo, unsynchronized),
          ),
        );
      },
    );
  }

  ListView _drawerListView(bool primary) {
    const allMemosIndex = 0;
    const tagsSubtitleIndex = 1;
    const tagsBeginIndex = 2;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);
    final settings = Provider.of<Settings>(context, listen: false);
    final tags = memoStore.tags;
    final tagScores = settings.getTagScores();
    tags.sortByScores(tagScores);
    final tagsEndIndex = tagsBeginIndex + tags.length - 1;
    late final int integrationDividerIndex;
    late final int integrationSubtitleIndex;
    late final int synchronizeIndex;
    late final int othersDividerIndex;
    final hidden = settings.getSynchronizationHidden();
    if (!hidden) {
      integrationDividerIndex = tagsEndIndex + 1;
      integrationSubtitleIndex = integrationDividerIndex + 1;
      synchronizeIndex = integrationSubtitleIndex + 1;
      othersDividerIndex = synchronizeIndex + 1;
    } else {
      integrationDividerIndex = -1;
      integrationSubtitleIndex = -1;
      synchronizeIndex = -1;
      othersDividerIndex = tagsEndIndex + 1;
    }
    final othersSubtitleIndex = othersDividerIndex + 1;
    final settingsIndex = othersSubtitleIndex + 1;
    final footerIndex = settingsIndex + 1;
    final drawerItemCount = footerIndex + 1;
    final localizations = AppLocalizations.of(context)!;
    const border = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(40.0),
      ),
    );
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      primary: primary,
      itemCount: drawerItemCount,
      itemBuilder: (context, i) {
        if (i == allMemosIndex) {
          return ListTile(
            title: Text(localizations.allMemos),
            onTap: _disableFiltering,
            selected: !_filteringEnabled && !_searching,
            selectedColor:
                common_uis.TsukimisouColors.scheme.onPrimaryContainer,
            selectedTileColor:
                common_uis.TsukimisouColors.scheme.primaryContainer,
            shape: border,
          );
        } else if (i == tagsSubtitleIndex) {
          return common_uis.subtitle(context, localizations.tags);
        } else if (i >= tagsBeginIndex && i <= tagsEndIndex) {
          final tag = tags[i - tagsBeginIndex];
          return ListTile(
            title: Text(tag),
            onTap: () async {
              await _filter(tag);
            },
            selected: _filteringEnabled && _filteringTag == tag && !_searching,
            selectedColor:
                common_uis.TsukimisouColors.scheme.onPrimaryContainer,
            selectedTileColor:
                common_uis.TsukimisouColors.scheme.primaryContainer,
            shape: border,
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
            enabled: !(appState.mergingWithGoogleDrive || _savingToGoogleDrive),
            shape: border,
          );
        } else if (i == othersDividerIndex) {
          return const Divider();
        } else if (i == othersSubtitleIndex) {
          return common_uis.subtitle(context, localizations.others);
        } else if (i == settingsIndex) {
          return ListTile(
            title: Text(localizations.settings),
            onTap: _showSettings,
            shape: border,
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                localizations.showingMemos(
                    _shownMemos.length, memoStore.memos.length, tags.length),
                style: common_uis.TsukimisouTextStyles.homePageDrawerFooter(
                    context),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _filter(String tag) async {
    final settings = Provider.of<Settings>(context, listen: false);
    final tagScores = settings.getTagScores();
    for (final key in tagScores.keys) {
      var score = tagScores[key];
      if (score != null) {
        score *= 0.9;
        if (key == tag) {
          score += 1.0;
        }
        tagScores[key] = score;
      }
    }
    if (!tagScores.containsKey(tag)) {
      tagScores[tag] = 1.0;
    }
    await settings.setTagScores(tagScores);
    if (!mounted) {
      return;
    }
    _filteringTag = tag;
    _filteringEnabled = true;
    _searching = false;
    setState(() {
      _updateShownMemos();
    });
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
  }

  void _disableFiltering() {
    _filteringEnabled = false;
    _searching = false;
    setState(() {
      _updateShownMemos();
    });
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
    }
  }

  void _updateShownMemos() {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
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
    if (_shownMemos.isEmpty) {
      _filteringEnabled = false;
      _shownMemos = [...memos];
    }
    _shownMemos.sort((a, b) => b.lastModified.compareTo(a.lastModified));
  }
}
