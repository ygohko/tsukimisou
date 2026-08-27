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

import 'package:material_ui/material_ui.dart';
import 'package:platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'app_state.dart';
import 'common_uis.dart' as common_uis;
import 'editing_page.dart';
import 'searching_page.dart';
import 'searching_page_contents.dart';
import 'settings_page.dart';
import 'viewing_page.dart';
import '../extensions.dart';
import '../gen_l10n/app_localizations.dart';
import '../models/google_drive_file.dart';
import '../models/memo.dart';
import '../models/memo_store.dart';
import '../models/memo_store_google_drive_loader.dart';
import '../models/memo_store_google_drive_saver.dart';
import '../models/memo_store_loader.dart';
import '../models/memo_store_local_loader.dart';
import '../models/memo_store_local_saver.dart';
import '../models/memo_store_merger.dart';
import '../models/settings.dart';

class HomePage extends StatefulWidget {
  /// Creates a home page.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _shownMemos = <Memo>[];
  var _filteringTag = '';
  var _filteringEnabled = false;
  var _availableMemoCount = 0;
  var _availableTags = <String>[];
  final _shownArchiveNames = <String>[];
  var _includesMain = true;
  var _commonUiInitialized = false;
  var _savingToGoogleDrive = false;
  var _searching = false;
  var _actionButtonShown = true;
  var _fileLockedCount = 0;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  Future<void> didChangeDependencies() async {
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
    memoStore.onArchiveMemoStoreRequired = (name) async {
      final memoStore = MemoStore();
      final loader = await MemoStoreLocalLoader.fromFileName(
          memoStore, 'Archive-$name.json');
      await loader.execute();
      for (final memo in memoStore.memos) {
        memo.archiveName = name;
      }
      return memoStore;
    };
    try {
      await memoStoreLoader.execute();
    } on FileNotCompatibleException catch (exception, stackTrace) {
      if (mounted) {
        // Not compatible error.
        // TODO: Showing error at here may cause problem. Check this later.
        final localizations = AppLocalizations.of(context)!;
        await common_uis.showErrorDialog(
            context,
            localizations.memoStoreIsNotCompatible,
            localizations.memoStoreInTheLocalStorageIsNotCompatible,
            localizations.ok,
            exception: exception,
            stackTrace: stackTrace);
      }
    } on IOException {
      // Load error
      // Do nothing for now
    }
  }

  Future<void> _viewMemo(Memo memo) async {
    setState(() {
      _actionButtonShown = false;
    });
    final result = await common_uis.viewMemo(context, memo);
    if (result == null) {
      setState(() {
        _actionButtonShown = true;
      });
      return;
    }
    if (!mounted) {
      return;
    }

    if (result == ViewingPageResult.archived) {
      final localizations = AppLocalizations.of(context)!;
      final snackBar = SnackBar(
        content: Text(
          localizations.memoArchived,
          style: TextStyle(
            color: common_uis.TsukimisouColors.scheme.onSecondary,
          ),
        ),
        backgroundColor: common_uis.TsukimisouColors.scheme.secondary,
        width: 300.0,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      );
      _showSnackBar(snackBar);
    } else {
      final localizations = AppLocalizations.of(context)!;
      final snackBar = SnackBar(
        content: Text(
          localizations.memoDeleted,
          style: TextStyle(
            color: common_uis.TsukimisouColors.scheme.onSecondary,
          ),
        ),
        backgroundColor: common_uis.TsukimisouColors.scheme.secondary,
        width: 300.0,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      );
      _showSnackBar(snackBar);
    }
  }

  Future<void> _addMemo({String? initialText}) async {
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
    final toMemoStore = Provider.of<MemoStore>(context, listen: false);
    MemoStoreMerger? merger;
    appState.mergingWithGoogleDrive = true;
    _showSynchronizingBanner();

    try {
      final fromMemoStore =
          await _loadFromMemoStore(localizations, messenger, appState);
      if (fromMemoStore == null) {
        return;
      }
      _fileLockedCount = 0;

      try {
        merger = await _mergeMemoStores(
            toMemoStore, fromMemoStore, localizations, false);
      } on Exception catch (exception, stackTrace) {
        if (mounted) {
          final accepted = await common_uis.showConfirmationDialog(
            context,
            localizations.loadingArchiveMemoStoresFailed,
            localizations.couldNotLoadArchiveMemoStores,
            localizations.retry,
            localizations.cancel,
            false,
            exception: exception,
            stackTrace: stackTrace,
          );
          if (!accepted) {
            return;
          }
        }
      }
      if (merger == null) {
        try {
          merger = await _mergeMemoStores(
              toMemoStore, fromMemoStore, localizations, true);
        } on Exception catch (exception, stackTrace) {
          if (mounted) {
            await common_uis.showErrorDialog(
              context,
              localizations.synchronizationWasFailed,
              localizations.couldNotSynchronizeWithGoogleDrive,
              localizations.ok,
              exception: exception,
              stackTrace: stackTrace,
            );
            return;
          }
        }
      }
      if (merger == null) {
        return;
      }

      final result = await _saveMergedMemoStoresLocal(
          toMemoStore, merger, localizations, messenger, appState);
      if (!result) {
        return;
      }
    } finally {
      messenger.hideCurrentMaterialBanner();
      appState.mergingWithGoogleDrive = false;
    }

    setState(() {
      _savingToGoogleDrive = true;
    });
    await _saveMergedMemoStoresGoogleDrive(
        toMemoStore, merger, localizations, messenger, appState);
    setState(() {
      _savingToGoogleDrive = false;
    });
  }

  Future<MemoStore?> _loadFromMemoStore(AppLocalizations localizations,
      ScaffoldMessengerState messenger, AppState appState) async {
    final fromMemoStore = MemoStore();
    final loader = MemoStoreGoogleDriveLoader(fromMemoStore, 'MemoStore.json');
    try {
      await loader.execute();
    } on FileNotFoundException {
      // Loading failure can be ignored because the file may not exists. Do nothing.
    } on FileLockedException catch (exception, stackTrace) {
      // Loading failure caused by locked memo store.
      _fileLockedCount++;
      if (_fileLockedCount < 3) {
        messenger.hideCurrentMaterialBanner();
        appState.mergingWithGoogleDrive = false;
        if (!mounted) {
          return null;
        }
        await common_uis.showErrorDialog(
          context,
          localizations.memoStoreIsLocked,
          localizations.memoStoreIsLockedByOtherDevice,
          localizations.ok,
          exception: exception,
          stackTrace: stackTrace,
        );
        return null;
      } else {
        // Confirm to force unlock
        messenger.hideCurrentMaterialBanner();
        appState.mergingWithGoogleDrive = false;
        if (!mounted) {
          return null;
        }
        final accepted = await common_uis.showConfirmationDialog(
          context,
          localizations.memoStoreIsLocked,
          localizations.memoStoreIsStillLocked,
          localizations.unlock,
          localizations.cancel,
          false,
          exception: exception,
          stackTrace: stackTrace,
        );
        if (accepted) {
          await _unlockGoogleDrive();
        }
        return null;
      }
    } on FileNotCompatibleException catch (exception, stackTrace) {
      // Not compatible error.
      messenger.hideCurrentMaterialBanner();
      appState.mergingWithGoogleDrive = false;
      if (!mounted) {
        return null;
      }
      await common_uis.showErrorDialog(
        context,
        localizations.memoStoreIsNotCompatible,
        localizations.memoStoreOnTheGoogleDriveIsNotCompatible,
        localizations.ok,
        exception: exception,
        stackTrace: stackTrace,
      );
      return null;
    } on Exception catch (exception, stackTrace) {
      // Other failure.
      messenger.hideCurrentMaterialBanner();
      appState.mergingWithGoogleDrive = false;
      if (!mounted) {
        return null;
      }
      await common_uis.showErrorDialog(
        context,
        localizations.loadingWasFailed,
        localizations.couldNotLoadMemoStoreFromGoogleDrive,
        localizations.ok,
        exception: exception,
        stackTrace: stackTrace,
      );
      return null;
    }
    fromMemoStore.onArchiveMemoStoreRequired = (name) async {
      final memoStore = MemoStore();
      final loader =
          MemoStoreGoogleDriveLoader(memoStore, 'Archive-$name.json');
      await loader.execute();
      return memoStore;
    };

    return fromMemoStore;
  }

  Future<MemoStoreMerger?> _mergeMemoStores(
      MemoStore toMemoStore,
      MemoStore fromMemoStore,
      AppLocalizations localizations,
      bool missingArchivesIgnored) async {
    final merger = MemoStoreMerger(toMemoStore, fromMemoStore,
        missingArchivesIgnored: missingArchivesIgnored);
    merger.conflictWarningText = localizations.thisMemoHasConflicts;
    merger.localMarkerText = localizations.local;
    merger.cloudMarkerText = localizations.cloud;
    await merger.execute();

    return merger;
  }

  Future<bool> _saveMergedMemoStoresLocal(
      MemoStore toMemoStore,
      MemoStoreMerger merger,
      AppLocalizations localizations,
      ScaffoldMessengerState messenger,
      AppState appState) async {
    final localSaver =
        await MemoStoreLocalSaver.fromFileName(toMemoStore, 'MemoStore.json');
    try {
      localSaver.execute();
    } on Exception catch (exception, stackTrace) {
      // Saving failed.
      messenger.hideCurrentMaterialBanner();
      appState.mergingWithGoogleDrive = false;
      if (mounted) {
        await common_uis.showErrorDialog(
          context,
          localizations.savingWasFailed,
          localizations.couldNotSaveMemoStoreToLocalStorage,
          localizations.ok,
          exception: exception,
          stackTrace: stackTrace,
        );
      }
      return false;
    }

    final updatedArchiveNames = merger.updatedArchiveNames;
    for (final name in updatedArchiveNames) {
      final memoStore = await toMemoStore.archiveMemoStore(name);
      final saver = await MemoStoreLocalSaver.fromFileName(
          memoStore, 'Archive-$name.json');
      try {
        await saver.execute();
      } on Exception catch (exception, stackTrace) {
        // Saving failed.
        if (mounted) {
          await common_uis.showErrorDialog(
            context,
            localizations.savingWasFailed,
            localizations.couldNotSaveMemoStoreToLocalStorage,
            localizations.ok,
            exception: exception,
            stackTrace: stackTrace,
          );
        }
      }
    }

    return true;
  }

  Future<bool> _saveMergedMemoStoresGoogleDrive(
      MemoStore toMemoStore,
      MemoStoreMerger merger,
      AppLocalizations localizations,
      ScaffoldMessengerState messenger,
      AppState appState) async {
    final saver = MemoStoreGoogleDriveSaver(toMemoStore, 'MemoStore.json');
    try {
      await saver.execute();
    } on Exception catch (exception, stackTrace) {
      // Saving failed.
      if (mounted) {
        await common_uis.showErrorDialog(
          context,
          localizations.savingWasFailed,
          localizations.couldNotSaveMemoStoreToGoogleDrive,
          localizations.ok,
          exception: exception,
          stackTrace: stackTrace,
        );
      }
    }

    final updatedArchiveNames = merger.updatedArchiveNames;
    for (final name in updatedArchiveNames) {
      final memoStore = await toMemoStore.archiveMemoStore(name);
      final saver = MemoStoreGoogleDriveSaver(memoStore, 'Archive-$name.json');
      try {
        await saver.execute();
      } on Exception catch (exception, stackTrace) {
        // Saving failed.
        if (mounted) {
          await common_uis.showErrorDialog(
            context,
            localizations.savingWasFailed,
            localizations.couldNotSaveMemoStoreToGoogleDrive,
            localizations.ok,
            exception: exception,
            stackTrace: stackTrace,
          );
        }
      }
    }

    return true;
  }

  Future<void> _unlockGoogleDrive() async {
    final file = GoogleDriveFile('MemoStore.json');
    await file.unlock();
  }

  Future<void> _searchForSmallScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SearchingPage(shownArchiveNames: _shownArchiveNames);
        },
      ),
    );
  }

  void _searchForLargeScreen() {
    setState(() {
      _searching = true;
    });
  }

  Future<void> _showSettings() async {
    if (!common_uis.hasLargeScreen()) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) {
        return;
      }
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

  void _showSnackBar(SnackBar snackBar) {
    final controller = ScaffoldMessenger.of(context).showSnackBar(snackBar);
    controller.closed.then((reason) {
      setState(() {
        _actionButtonShown = true;
      });
    });
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
      floatingActionButton: _actionButtonShown
          ? Consumer<AppState>(
              builder: (context, appState, child) {
                return FloatingActionButton(
                  onPressed: appState.mergingWithGoogleDrive ? null : _addMemo,
                  tooltip: localizations.addAMemo,
                  child: const Icon(Icons.add),
                );
              },
            )
          : null,
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
      drawerEnableOpenDragGesture: false,
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
                  rightPaneWidget = SearchingPageContents(
                      shownArchiveNames: _shownArchiveNames);
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
      floatingActionButton: _actionButtonShown
          ? Consumer<AppState>(
              builder: (context, appState, child) {
                return FloatingActionButton(
                  onPressed: appState.mergingWithGoogleDrive ? null : _addMemo,
                  tooltip: localizations.addAMemo,
                  child: const Icon(Icons.add),
                );
              },
            )
          : null,
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
                    _viewMemo(memo);
                  },
            child: common_uis.memoCardContents(context, memo, unsynchronized),
          ),
        );
      },
    );
  }

  ListView _drawerListView(bool primary) {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);
    final settings = Provider.of<Settings>(context, listen: false);
    final tags = [..._availableTags];
    final tagScores = settings.getTagScores();
    tags.sortByScores(tagScores);
    final hidden = settings.getSynchronizationHidden();
    final localizations = AppLocalizations.of(context)!;
    const border = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(40.0),
      ),
    );

    final children = [
      ListTile(
        title: Text(localizations.allMemos),
        onTap: _disableFiltering,
        selected: !_filteringEnabled && !_searching,
        selectedColor: common_uis.TsukimisouColors.scheme.onPrimaryContainer,
        selectedTileColor: common_uis.TsukimisouColors.scheme.primaryContainer,
        shape: border,
      ),
      common_uis.subtitle(context, localizations.tags),
    ];
    for (final tag in tags) {
      children.add(ListTile(
        title: Text(tag),
        onTap: () async {
          await _filter(tag);
        },
        selected: _filteringEnabled && _filteringTag == tag && !_searching,
        selectedColor: common_uis.TsukimisouColors.scheme.onPrimaryContainer,
        selectedTileColor: common_uis.TsukimisouColors.scheme.primaryContainer,
        shape: border,
      ));
    }
    if (memoStore.archiveHashes.isNotEmpty) {
      children.addAll([
        const Divider(),
        common_uis.subtitle(context, localizations.archives),
      ]);
      final names = List.from(memoStore.archiveHashes.keys);
      names.sort((a, b) {
        return b.compareTo(a);
      });
      for (final name in names) {
        final shown = _shownArchiveNames.contains(name);
        children.add(ListTile(
          title: Text(name),
          trailing: Icon(
            shown ? Icons.check_circle : Icons.check_circle_outline,
            color: shown ? common_uis.TsukimisouColors.scheme.primary : null,
          ),
          onTap: () {
            _toggleShownArchives(name);
          },
          enabled: true,
          shape: border,
        ));
      }
      children.add(ListTile(
        title: Text(localizations.includeMain),
        onTap: () {
          _setIncludesMain(!_includesMain);
        },
        trailing: Switch(
          value: _includesMain,
          onChanged: _shownArchiveNames.isNotEmpty ? _setIncludesMain : null,
        ),
        enabled: _shownArchiveNames.isNotEmpty,
        shape: border,
      ));
    }
    if (!hidden) {
      children.addAll([
        const Divider(),
        common_uis.subtitle(context, localizations.googleDriveIntegration),
        ListTile(
          title: Text(localizations.synchronize),
          onTap: _mergeWithGoogleDrive,
          enabled: !(appState.mergingWithGoogleDrive || _savingToGoogleDrive),
          shape: border,
        ),
      ]);
    }
    children.addAll([
      const Divider(),
      common_uis.subtitle(context, localizations.others),
      ListTile(
        title: Text(localizations.settings),
        onTap: _showSettings,
        shape: border,
      ),
      Container(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations.showingMemos(
                _shownMemos.length, _availableMemoCount, _availableTags.length),
            style:
                common_uis.TsukimisouTextStyles.homePageDrawerFooter(context),
          ),
        ),
      ),
    ]);

    return ListView(
      padding: const EdgeInsets.all(10.0),
      primary: primary,
      children: children,
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

  Future<void> _toggleShownArchives(String name) async {
    if (_shownArchiveNames.contains(name)) {
      setState(() {
        _shownArchiveNames.remove(name);
        if (_shownArchiveNames.isEmpty) {
          _includesMain = true;
        }
        _updateShownMemos();
      });
    } else {
      final memoStore = Provider.of<MemoStore>(context, listen: false);
      try {
        await memoStore.archiveMemoStore(name);
      } on Exception catch (exception, stackTrace) {
        if (!mounted) {
          return;
        }

        final result = await common_uis.showArchiveNotFoundDialog(
          context,
          exception: exception,
          stackTrace: stackTrace,
        );
        if (result ==
            common_uis.ArchiveNotFoundDialogResult.removeThisArchive) {
          memoStore.removeArchive(name);
        }
        return;
      }
      setState(() {
        _shownArchiveNames.add(name);
        _updateShownMemos();
      });
    }
  }

  void _setIncludesMain(bool includesMain) {
    setState(() {
      _includesMain = includesMain;
      _updateShownMemos();
    });
  }

  void _updateShownMemos() {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final sourceMemos = <Memo>[];
    _availableTags = <String>[];
    if (_includesMain) {
      sourceMemos.addAll(memoStore.memos);
      _availableTags.addAll(memoStore.tags);
    }
    for (final name in _shownArchiveNames) {
      final archiveMemoStore = memoStore.archiveMemoStoreIfLoaded(name);
      if (archiveMemoStore != null) {
        sourceMemos.addAll(archiveMemoStore.memos);
        for (final tag in archiveMemoStore.tags) {
          if (!_availableTags.contains(tag)) {
            _availableTags.add(tag);
          }
        }
      }
    }
    _availableMemoCount = sourceMemos.length;

    if (!_filteringEnabled) {
      _shownMemos = [...sourceMemos];
    } else {
      _shownMemos.clear();
      for (final memo in sourceMemos) {
        if (memo.tags.contains(_filteringTag)) {
          _shownMemos.add(memo);
        }
      }
    }
    if (_shownMemos.isEmpty) {
      _filteringEnabled = false;
      _shownMemos = [...sourceMemos];
    }

    _shownMemos.sort((a, b) => b.lastModified.compareTo(a.lastModified));
  }
}
