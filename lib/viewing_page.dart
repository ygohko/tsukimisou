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
import 'package:platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'binding_tags_page.dart';
import 'common_uis.dart' as common_uis;
import 'editing_page.dart';
import 'extensions.dart';
import 'factories.dart';
import 'memo.dart';
import 'memo_store.dart';

enum _Direction {
  forward,
  backward,
}

class ViewingPage extends StatefulWidget {
  final Memo memo;
  final bool fullScreen;

  /// Creates a viewing page.
  const ViewingPage({Key? key, required this.memo, this.fullScreen = true})
      : super(key: key);

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
  late Memo _memo;
  final _previousMemos = <Memo>[];
  var _fullScreen = false;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(_memo.lastModified);
    final lastModified =
    DateTime.fromMillisecondsSinceEpoch(_memo.lastModified);
    final lastMerged = DateTime.fromMillisecondsSinceEpoch(
      Provider.of<MemoStore>(context, listen: false).lastMerged);
    final unsynchronized = lastModified.isAfter(lastMerged);
    var tagsString = '';
    for (final tag in _memo.tags) {
      tagsString += '$tag, ';
    }
    if (tagsString != '') {
      tagsString = tagsString.substring(0, tagsString.length - 2);
    }
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
    actions.addAll([
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: _share,
        tooltip: localizations.share,
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: _delete,
        tooltip: localizations.delete,
      ),
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: _edit,
        tooltip: localizations.edit,
      ),
    ]);
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
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
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
              onTap: _bindTags,
            ),
            const Divider(),
            ListTile(
              title:
                  Text(localizations.name(_memo.name), style: attributeStyle),
              onTap: _modifyName,
            ),
            const Divider(),
            ListTile(
              title: Text(localizations.viewingMode(_memo.viewingMode),
                  style: attributeStyle),
              onTap: _chooseViewingMode,
            ),
            const Divider(),
            if (unsynchronized) ...[
              ListTile(
                title: Text(
                  localizations.unsynchronized,
                  style: attributeStyle,
                ),
              ),
              const Divider(),
            ]
          ],
        ),
      ),
    );
  }

  void _edit() async {
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EditingPage(memo: _memo);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return const OpenUpwardsPageTransitionsBuilder().buildTransitions(
              null, context, animation, secondaryAnimation, child);
        },
      ));
    } else {
      await common_uis.showTransitiningDialog(
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
        duration: const Duration(milliseconds: 300),
      );
    }
    setState(() {});
  }

  void _share() async {
    final localizations = AppLocalizations.of(context)!;
    await Share.share(_memo.text, subject: localizations.sharedFromTsukimisou);
  }

  void _delete() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    final accepted = await common_uis.showConfirmationDialog(
        context,
        localizations.deleteThisMemo,
        localizations.thisActionCannotBeUndone,
        localizations.ok,
        localizations.cancel,
        true);
    if (!accepted) {
      return;
    }

    final factories = Factories.instance();
    memoStore.removeMemo(_memo);
    final memoStoreSaver = await factories.memoStoreLocalSaverFromFileName(
        memoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException {
      if (mounted) {
        // Save error
        await common_uis.showErrorDialog(
            context,
            localizations.savingWasFailed,
            localizations.couldNotSaveMemoStoreToLocalStorage,
            localizations.ok);
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _bindTags() async {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return BindingTagsPage(memo: _memo, additinalTags: memoStore.tags);
        },
      ));
    } else {
      await common_uis.showTransitiningDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(0.0),
              elevation: 0,
              child: BindingTagsPage(
                  memo: _memo,
                  additinalTags: memoStore.tags,
                  fullScreen: _fullScreen),
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

  void _modifyName() async {
    final localizations = AppLocalizations.of(context)!;
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    _textEditingController.text = _memo.name;
    var error = false;
    final name = await showDialog(
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
    );
    if (name != null) {
      _memo.beginModification();
      _memo.name = name;
      await _save();
      setState(() {});
    }
  }

  void _chooseViewingMode() async {
    // TODO: Add constants.dart?
    const viewingModeNames = ['Plain', 'TinyMarkdown'];

    final tiles = <Widget>[];
    for (final name in viewingModeNames) {
      tiles.add(
        ListTile(
          leading: Radio(
              value: name,
              groupValue: _memo.viewingMode,
              onChanged: (value) async {
                if (value != null) {
                  _memo.beginModification();
                  _memo.viewingMode = value;
                  await _save();
                }
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }),
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
        return AlertDialog(
          content: SizedBox(
            width: 200.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: tiles,
            ),
          ),
        );
      },
    );
    setState(() {});
  }

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context)!;
    final factories = Factories.instance();
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    memoStore.markAsChanged();
    final memoStoreSaver = await factories.memoStoreLocalSaverFromFileName(
        memoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException {
      if (mounted) {
        // Save error
        await common_uis.showErrorDialog(
            context,
            localizations.savingWasFailed,
            localizations.couldNotSaveMemoStoreToLocalStorage,
            localizations.ok);
      }
    }
  }

  void _showLinkedMemo(String memoName) async {
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
