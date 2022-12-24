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

class SearchingPageContents extends StatefulWidget {
  /// Creates a home page.
  const SearchingPageContents({Key? key}) : super(key: key);

  @override
  State<SearchingPageContents> createState() => _SearchingPageContentsState();
}

class _SearchingPageContentsState extends State<SearchingPageContents> {
  var _strings = <String>[];

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search memos',
          ),
          onSubmitted: (string) {
            setState(() {
              _strings.add(string);
            });
          },
        ),
        /*
        SizedBox(
          height: 500.0,
        */
        Expanded(
          child: ListView.builder(
            itemCount: _strings.length,
            itemBuilder: (context, i) {
              return Card(
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(_strings[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
