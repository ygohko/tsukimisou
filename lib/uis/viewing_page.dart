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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'binding_tags_page.dart';
import 'common_uis.dart' as common_uis;
import 'editing_page.dart';
import '../extensions.dart';
import '../models/memo.dart';
import '../models/memo_store.dart';
import '../models/memo_store_local_saver.dart';
import '../models/settings.dart';
import '../gen_l10n/app_localizations.dart';

enum ViewingPageResult {
  deleted,
  archived,
}

enum _Direction {
  forward,
  backward,
}

class TestTransition extends AnimatedWidget {
  final Alignment alignment;
  final Widget child;

  /// Creates a dialog to dialog transition.
  const TestTransition(
      {super.key,
      required Animation<double> phase,
      this.alignment = Alignment.center,
      required this.child})
      : super(listenable: phase);

  Animation<double> get _phase => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final scale = _phase.value;
    // final transform = Matrix4.diagonal3Values(scale, scale, scale);
    // final transform = Matrix4.diagonal3Values(1.0, 1.0, 1.0);
    final transform = Matrix4.translationValues((1.0 - _phase.value) * 200.0, (1.0 - _phase.value) * 200.0, 0.0);
    transform.scale(scale, scale, scale);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}

class ViewingPage extends StatefulWidget {
  final Memo memo;
  final bool fullScreen;

  /// Creates a viewing page.
  const ViewingPage({super.key, required this.memo, this.fullScreen = true});

  @override
  State<ViewingPage> createState() => _ViewingPageState();
}

class _ViewingPageState extends State<ViewingPage>
    with TickerProviderStateMixin {
  final _textEditingController = TextEditingController();
  late final AnimationController _animationController;
  final _scrollController = ScrollController();
  Animation<Offset> _animation =
      const AlwaysStoppedAnimation<Offset>(Offset(0.0, 0.0));
  final _viewingModeListTileKey = GlobalKey();
  final _modifyingNameListTileKey = GlobalKey();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late Memo _memo;
  final _previousMemos = <Memo>[];
  var _fullScreen = false;
  var _controlKeyPressed = false;

  @override
  void initState() {
    super.initState();
    const platform = LocalPlatform();
    if (platform.isDesktop) {
      HardwareKeyboard.instance.addHandler(_handleKeyboard);
    }
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _memo = widget.memo;
    _fullScreen = widget.fullScreen;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _textEditingController.dispose();
    const platform = LocalPlatform();
    if (platform.isDesktop) {
      HardwareKeyboard.instance.removeHandler(_handleKeyboard);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const platform = LocalPlatform();
    final localizations = AppLocalizations.of(context)!;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(_memo.lastModified);
    final lastModified =
        DateTime.fromMillisecondsSinceEpoch(_memo.lastModified);
    final lastMerged = DateTime.fromMillisecondsSinceEpoch(
        Provider.of<MemoStore>(context, listen: false).lastMerged);
    final settings = Provider.of<Settings>(context, listen: false);
    late final bool unsynchronized;
    if (!settings.getSynchronizationHidden() &&
        lastModified.isAfter(lastMerged)) {
      unsynchronized = true;
    } else {
      unsynchronized = false;
    }
    var tagsString = '';
    for (final tag in _memo.tags) {
      tagsString += '$tag, ';
    }
    if (tagsString != '') {
      tagsString = tagsString.substring(0, tagsString.length - 2);
    }
    final archiveName = _memo.archiveName;
    final textStyle =
        common_uis.TsukimisouTextStyles.viewingPageMemoText(context);
    final attributeStyle =
        common_uis.TsukimisouTextStyles.viewingPageMemoAttribute(context);
    final size = MediaQuery.of(context).size;
    final width = _fullScreen ? size.width : common_uis.MemoDialogsSize.width;
    final height =
        _fullScreen ? size.height : common_uis.MemoDialogsSize.height;
    var actions = <Widget>[];
    if (_previousMemos.isNotEmpty) {
      actions.add(
        IconButton(
          key: const ValueKey('backToPreviousMemoButton'),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _showPreviousMemo,
          tooltip: localizations.backToPreviousMemo,
        ),
      );
    }
    if (common_uis.hasLargeScreen()) {
      actions.add(
        IconButton(
          icon: _fullScreen
              ? const Icon(Icons.fullscreen_exit)
              : const Icon(Icons.fullscreen),
          onPressed: () {
            setState(() {
              _fullScreen = !_fullScreen;
            });
          },
          tooltip: _fullScreen
              ? localizations.exitFullScreen
              : localizations.fullScreen,
        ),
      );
    }
    actions.add(IconButton(
      icon: const Icon(Icons.share),
      onPressed: _share,
      tooltip: localizations.share,
    ));
    if (archiveName == null) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.delete_outlined),
          onPressed: _delete,
          tooltip: localizations.delete,
        ),
        IconButton(
          icon: const Icon(Icons.archive_outlined),
          onPressed: _archive,
          tooltip: localizations.archive,
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _edit,
          tooltip: localizations.edit,
        ),
      ]);
    } else {
      actions.add(IconButton(
        key: const ValueKey('unarchiveMemoButton'),
        icon: const Icon(Icons.unarchive_outlined),
        onPressed: _unarchive,
        tooltip: localizations.unarchive,
      ));
    }
    late final Widget textContents;
    // TODO: Consider expandable implementation.
    if (_memo.viewingMode == 'TinyMarkdown') {
      textContents = SelectionArea(
        child: common_uis.richTextContents(context, _memo.text,
            onMemoLinkRequested: _showLinkedMemo),
      );
    } else {
      textContents = SelectableText(
        _memo.text,
        style: textStyle,
        contextMenuBuilder: (context, editableTextState) {
          final value = editableTextState.textEditingValue;
          final items = editableTextState.contextMenuButtonItems;
          final string = value.selection.textInside(value.text);
          if (string.startsWith('http') && string.contains('://')) {
            items.insert(
                0,
                ContextMenuButtonItem(
                    label: localizations.openAsUrl,
                    onPressed: () {
                      ContextMenuController.removeAny();
                      launchUrl(
                        Uri.parse(string),
                        mode: LaunchMode.externalApplication,
                      );
                    }));
          }
          return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: items);
        },
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            leading: common_uis.hasLargeScreen()
                ? const CloseButton()
                : const BackButton(),
            title: Text(_memo.name),
            actions: actions,
          ),
          body: ListView(
            controller: _scrollController,
            children: [
              ClipRect(
                child: SlideTransition(
                  position: _animation,
                  child: Card(
                    color: common_uis.TsukimisouColors.memoCard,
                    elevation: 2.0,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: textContents,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(localizations.updated(dateTime.toDetailedString()),
                    style: attributeStyle),
              ),
              const Divider(),
              ListTile(
                title: Text(localizations.boundTags(tagsString),
                    style: attributeStyle),
                onTap: archiveName == null
                    ? () {
                        _bindTags(!_controlKeyPressed);
                      }
                    : null,
                onLongPress: archiveName == null && !platform.isDesktop
                    ? () {
                        _bindTags(false);
                      }
                    : null,
              ),
              const Divider(),
              ListTile(
                key: _modifyingNameListTileKey,
                title:
                    Text(localizations.name(_memo.name), style: attributeStyle),
                onTap: archiveName == null ? _modifyName : null,
              ),
              const Divider(),
              ListTile(
                key: _viewingModeListTileKey,
                title: Text(localizations.viewingMode(_memo.viewingMode),
                    style: attributeStyle),
                onTap: archiveName == null ? _chooseViewingMode : null,
              ),
              const Divider(),
              if (!settings.getSynchronizationHidden() && unsynchronized) ...[
                ListTile(
                  title: Text(
                    localizations.unsynchronized,
                    style: attributeStyle,
                  ),
                ),
                const Divider(),
              ],
              if (archiveName != null) ...[
                ListTile(
                  title: Text(
                    localizations.inArchive(archiveName),
                    style: attributeStyle,
                  ),
                ),
                const Divider(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  bool _handleKeyboard(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        _controlKeyPressed = true;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        _controlKeyPressed = false;
      }
    }

    return false;
  }

  Future<void> _edit() async {
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EditingPage(memo: _memo);
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
          const platform = LocalPlatform();
          return Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(0.0),
              elevation: platform.isDesktop ? 0 : 24,
              child: EditingPage(memo: _memo, fullScreen: _fullScreen),
            ),
          );
        },
        barrierDismissible: false,
        barrierColor: const Color(0x00000000),
        transitionBuilder: common_uis.DialogTransitionBuilders.editing,
        curve: Curves.fastOutSlowIn,
        duration: common_uis.Durations.editing,
      );
    }
    setState(() {});
  }

  Future<void> _share() async {
    final localizations = AppLocalizations.of(context)!;
    await SharePlus.instance.share(
      ShareParams(
        text: _memo.text,
        subject: localizations.sharedFromTsukimisou,
      ),
    );
  }

  Future<void> _delete() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final accepted = await common_uis.showConfirmationDialog(
      context,
      localizations.deleteThisMemo,
      localizations.thisActionCannotBeUndone,
      localizations.ok,
      localizations.cancel,
      true,
    );
    if (!accepted) {
      return;
    }

    memoStore.removeMemo(_memo);
    final memoStoreSaver =
        await MemoStoreLocalSaver.fromFileName(memoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on Exception catch (exception, stackTrace) {
      if (mounted) {
        // Save error
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
    if (mounted) {
      Navigator.of(context).pop(ViewingPageResult.deleted);
    }
  }

  Future<void> _archive() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    late final MemoStore archiveMemoStore;
    try {
      archiveMemoStore = await memoStore.archiveMemo(_memo);
    } on Exception catch (exception, stackTrace) {
      if (!mounted) {
        return;
      }

      final result = await common_uis.showArchiveNotFoundDialog(
        context,
        exception: exception,
        stackTrace: stackTrace,
      );
      final name = switch (exception) {
        ArchiveNotFoundException exception => exception.name,
        _ => null,
      };
      if (name != null &&
          result == common_uis.ArchiveNotFoundDialogResult.removeThisArchive) {
        memoStore.removeArchive(name);
        archiveMemoStore = await memoStore.archiveMemo(_memo);
      } else {
        return;
      }
    }
    final archiveName = _memo.archiveName;
    if (archiveName == null) {
      return;
    }

    final saver =
        await MemoStoreLocalSaver.fromFileName(memoStore, 'MemoStore.json');
    final archiveSaver = await MemoStoreLocalSaver.fromFileName(
        archiveMemoStore, 'Archive-$archiveName.json');
    try {
      saver.execute();
      archiveSaver.execute();
    } on Exception catch (exception, stackTrace) {
      if (mounted) {
        // Save error
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

    if (mounted) {
      Navigator.of(context).pop(ViewingPageResult.archived);
    }
  }

  Future<void> _unarchive() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final archiveName = _memo.archiveName;
    if (archiveName == null) {
      return;
    }
    late final MemoStore archiveMemoStore;
    try {
      archiveMemoStore = await memoStore.unarchiveMemo(_memo);
    } on Exception catch (exception, stackTrace) {
      if (!mounted) {
        return;
      }

      await common_uis.showErrorDialog(
        context,
        localizations.unarchivingWasFailed,
        localizations.couldNotUnarchiveMemo,
        localizations.ok,
        exception: exception,
        stackTrace: stackTrace,
      );

      return;
    }

    final saver =
        await MemoStoreLocalSaver.fromFileName(memoStore, 'MemoStore.json');
    final archiveSaver = await MemoStoreLocalSaver.fromFileName(
        archiveMemoStore, 'Archive-$archiveName.json');
    try {
      saver.execute();
      archiveSaver.execute();
    } on Exception catch (exception, stackTrace) {
      if (mounted) {
        // Save error
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

    setState(() {});
    if (mounted) {
      final snackBar = SnackBar(
        content: Text(
          localizations.memoUnarchived,
          style: TextStyle(
            color: common_uis.TsukimisouColors.scheme.onSecondary,
          ),
        ),
        backgroundColor: common_uis.TsukimisouColors.scheme.secondary,
        width: 300.0,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      );
      _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    }
  }

  Future<void> _bindTags(bool updatesLastModified) async {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final settings = Provider.of<Settings>(context, listen: false);
    final tagScores = settings.getTagScores();
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return BindingTagsPage(
              memo: _memo,
              additionalTags: memoStore.tags,
              tagScores: tagScores,
              updatesLastModified: updatesLastModified);
        },
      ));
    } else {
      await common_uis.showTransitioningDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(0.0),
              elevation: 0,
              child: BindingTagsPage(
                  memo: _memo,
                  additionalTags: memoStore.tags,
                  tagScores: tagScores,
                  fullScreen: _fullScreen,
                  updatesLastModified: updatesLastModified),
            ),
          );
        },
        barrierDismissible: false,
        barrierColor: const Color(0x00000000),
        transitionBuilder: common_uis.DialogTransitionBuilders.dialogToDialog,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 150),
      );
    }
    setState(() {});
  }

  Future<void> _modifyName() async {
    AnimatedWidget testTransitionBuilder(Animation<double> animation, Curve curve,
      Alignment alignment, Widget child) {
      return TestTransition(
        phase: animation,
        alignment: alignment,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    }

    final localizations = AppLocalizations.of(context)!;

    final query = MediaQuery.of(context);
    var tappedPositionX = query.size.width * 0.5;
    var tappedPositionY = query.size.height * 0.5;
    final renderBox = _modifyingNameListTileKey.currentContext?.findRenderObject();
    if (renderBox is RenderBox) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      tappedPositionX = position.dx + size.width * 0.5;
      tappedPositionY = position.dy + size.height * 0.5;
    }

    final memoStore = Provider.of<MemoStore>(context, listen: false);
    _textEditingController.text = _memo.name;
    var error = false;
    
    final name = await common_uis.showTransitioningDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.modifyTheName),
              content: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: localizations.enterTheMemoName,
                  errorText: error ? localizations.nameAlreadyExists : null,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
                onSubmitted: (name) {
                  final memo = memoStore.memoFromName(name);
                  if (memo != null) {
                    setState(() {
                        error = true;
                    });
                  } else {
                    Navigator.of(context).pop(name);
                  }
              }),
              actions: [
                TextButton(
                  child: Text(localizations.cancel),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                TextButton(
                  child: Text(localizations.ok),
                  onPressed: () {
                    final name = _textEditingController.text;
                    final memo = memoStore.memoFromName(name);
                    if (memo != null) {
                      if (memo != _memo) {
                        setState(() {
                            error = true;
                        });
                      } else {
                        Navigator.of(context).pop(null);
                      }
                    } else {
                      Navigator.of(context).pop(name);
                    }
                }),
            ]);
        });
      },
      barrierDismissible: true,
      transitionBuilder: testTransitionBuilder,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 150),
    );
    
    if (name != null) {
      _memo.beginModification();
      _memo.name = name;
      await _save();
      setState(() {});
    }
  }

  Future<void> _chooseViewingMode() async {
    // TODO: Add constants.dart?
    const viewingModeNames = ['Plain', 'TinyMarkdown'];

    final dialogHeight = 200.0;
    double? dialogCenterY;
    final renderBox = _viewingModeListTileKey.currentContext?.findRenderObject();
    if (renderBox is RenderBox) {
      final position = renderBox.localToGlobal(Offset.zero);
      final height = renderBox.size.height;
      dialogCenterY = position.dy + height * 0.5;
    }

    final tiles = <Widget>[];
    for (final name in viewingModeNames) {
      tiles.add(
        ListTile(
          leading: Radio(value: name),
          title: Text(name),
          onTap: () async {
            _memo.beginModification();
            _memo.viewingMode = name;
            await _save();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final viewHeight = MediaQuery.of(context).size.height;
            var offsetY = 0.0;
            if (dialogCenterY != null) {
              var centerY = dialogCenterY;
              var difference = (centerY + dialogHeight * 0.5) - viewHeight;
              if (difference > 0.0) {
                centerY -= difference;
              }
              difference = centerY - dialogHeight * 0.5;
              if (difference < 0.0) {
                centerY -= difference;
              }

              offsetY = centerY - (viewHeight * 0.5);
            }

            return Transform(
              transform: Matrix4.translationValues(0.0, offsetY, 0.0),
              child: AlertDialog(
                content: SizedBox(
                  width: 200.0,
                  child: RadioGroup(
                    groupValue: _memo.viewingMode,
                    onChanged: (value) async {
                      if (value != null) {
                        _memo.beginModification();
                        _memo.viewingMode = value;
                        await _save();
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: tiles,
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
    );
    setState(() {});
  }

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    memoStore.markAsChanged();
    final memoStoreSaver =
        await MemoStoreLocalSaver.fromFileName(memoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on Exception catch (exception, stackTrace) {
      if (mounted) {
        // Save error
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

  Future<void> _showLinkedMemo(String memoName) async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final memo = memoStore.memoFromName(memoName);
    if (memo == null) {
      if (mounted) {
        await common_uis.showErrorDialog(context, localizations.memoNotFound,
            localizations.linkedMemoIsNotFound, localizations.ok);
      }

      return;
    }
    _previousMemos.add(_memo);
    _animateCard(_Direction.forward);
    _scrollController.jumpTo(0.0);
    setState(() {
      _memo = memo;
    });
  }

  void _showPreviousMemo() {
    _animateCard(_Direction.backward);
    _scrollController.jumpTo(0.0);
    setState(() {
      _memo = _previousMemos.last;
      _previousMemos.removeLast();
    });
  }

  void _animateCard(_Direction direction) {
    late final Offset offset;
    if (direction == _Direction.forward) {
      offset = const Offset(0.2, 0.0);
    } else {
      offset = const Offset(-0.2, 0.0);
    }
    _animation = Tween<Offset>(
      begin: offset,
      end: const Offset(0.0, 0.0),
    ).animate(_animationController);
    _animationController.value = 0.0;
    _animationController.animateTo(
      1.0,
      curve: Curves.easeOutCubic,
    );
  }
}
