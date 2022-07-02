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

import 'memo.dart';

class ViewingPage extends StatefulWidget {
  final Memo memo;

  const ViewingPage({Key? key, required this.memo}) : super(key: key);

  @override
  State<ViewingPage> createState() => _ViewingPageState();
}

class _ViewingPageState extends State<ViewingPage> {
  @override
  Widget build(BuildContext context) {
    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(widget.memo.lastModified);
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo at ${dateTime.toString()}'),
      ),
      body: SingleChildScrollView(
        child: Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(widget.memo.text),
            ),
          ),
        ),
      ),
    );
  }
}
