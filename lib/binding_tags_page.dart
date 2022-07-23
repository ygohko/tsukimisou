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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'memo.dart';

class BindingTagsPage extends StatefulWidget {
  final Memo memo;

  /// Creates a binding tags page.
  const BindingTagsPage({Key? key, required this.memo}) : super(key: key);

  @override
  State<BindingTagsPage> createState() => _BindingTagsPageState();
}

class _BindingTagsPageState extends State<BindingTagsPage> {
  @override
  Widget build(BuildContext context) {
    final tags = widget.memo.tags;
    final listCount = tags.length + 1;
    final itemCount = listCount * 2;
    return Scaffold(
      appBar: AppBar(
        title: Text('Binding tags'),
      ),
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, i) {
          if (i.isOdd) {
            return const Divider();
          }

          final index = i ~/ 2;
          if (index == listCount - 1) {
            return ListTile(
              title: Text('Add a new tag...'),
              onTap: _addTag,
            );
          }
          return ListTile(
            title: Text(widget.memo.tags[index]),
          );
        },
      ),
    );
  }

  void _addTag() async {
    final localizations = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    var accepted = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a new tag'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter a tag name'),
          ),
          actions: [
            FlatButton(
              child: Text(localizations.cancel),
              onPressed: () {
                Navigator.of(context).pop();
            }),
            FlatButton(
              child: Text(localizations.ok),
              onPressed: () {
                accepted = true;
                Navigator.of(context).pop();
            }),
        ]);
      },
    );
    if (accepted) {
      widget.memo.tags.add(controller.text);
      setState(() {});
    }
  }
}
