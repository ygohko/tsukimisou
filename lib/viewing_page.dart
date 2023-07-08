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
import 'memo_store_local_saver.dart';

class ViewingPage extends StatefulWidget {
  final Memo memo;
  final bool fullScreen;

  /// Creates a viewing page.
  const ViewingPage({Key? key, required this.memo, this.fullScreen = true})
      : super(key: key);

  @override
  State<ViewingPage> createState() => _ViewingPageState();
}

class _ViewingPageState extends State<ViewingPage> {
  var _fullScreen = true;

  @override
  void initState() {
    _fullScreen = widget.fullScreen;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(widget.memo.lastModified);
    var tagsString = '';
    for (final tag in widget.memo.tags) {
      tagsString += tag + ', ';
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
    final height = _fullScreen ? size.height : common_uis.MemoDialogsSize.height;
    var actions = <Widget>[];
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      child: Scaffold(
        appBar: AppBar(
          leading: common_uis.hasLargeScreen() ? const CloseButton() : const BackButton(),
          title: Text(localizations.memoAtDateTime(dateTime.toSmartString())),
          actions: actions,
        ),
        body: ListView(
          children: [
            Card(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SelectableText(
                    widget.memo.text,
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
                                  launch(string);
                                }));
                      }
                      return AdaptiveTextSelectionToolbar.buttonItems(
                          anchors: editableTextState.contextMenuAnchors,
                          buttonItems: items);
                    },
                  ),
                ),
              ),
              elevation: 2.0,
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
          ],
        ),
      ),
    );
  }

  void _edit() async {
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EditingPage(memo: widget.memo);
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
              child: EditingPage(memo: widget.memo, fullScreen: _fullScreen),
              insetPadding: const EdgeInsets.all(0.0),
              elevation: platform.isDesktop ? 0 : 24,
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
    await Share.share(widget.memo.text,
        subject: localizations.sharedFromTsukimisou);
  }

  void _delete() async {
    final localizations = AppLocalizations.of(context)!;
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
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    memoStore.removeMemo(widget.memo);
    final memoStoreSaver = await factories.memoStoreLocalSaverFromFileName(
        memoStore, 'MemoStore.json');
    try {
      memoStoreSaver.execute();
    } on IOException catch (exception) {
      // Save error
      await common_uis.showErrorDialog(context, localizations.savingWasFailed,
          localizations.couldNotSaveMemoStoreToLocalStorage, localizations.ok);
    }
    Navigator.of(context).pop();
  }

  void _bindTags() async {
    final memoStore = Provider.of<MemoStore>(context, listen: false);
    if (!common_uis.hasLargeScreen()) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return BindingTagsPage(
              memo: widget.memo, additinalTags: memoStore.tags);
        },
      ));
    } else {
      await common_uis.showTransitiningDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Dialog(
              child: BindingTagsPage(
                  memo: widget.memo,
                  additinalTags: memoStore.tags,
                  fullScreen: _fullScreen),
              insetPadding: const EdgeInsets.all(0.0),
              elevation: 0,
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
}
