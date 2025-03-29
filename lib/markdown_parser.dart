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

class MarkdownParser {
  late final BuildContext _context;
  late final String _text;
  late final Widget _contents;

  MarkdownParser(BuildContext context, String text) {
    _context = context;
    _text = text;
  }

  void execute() {
    // TODO: Implement this.
    
    final theme = Theme.of(_context).textTheme;
    final lines = _text.split('\n');
    final widgets = <Widget>[];
    for (var line in lines) {
      line = line.replaceFirst('\n', '');
      late final Widget widget;
      if (line.startsWith('### ')) {
        line = line.replaceFirst('### ', '');
        widget = Text(
          line,
          style: theme.headlineSmall,
        );
      }
      else if (line.startsWith('## ')) {
        line = line.replaceFirst('## ', '');
        widget = Text(
          line,
          style: theme.headlineMedium,
        );
      }
      else if (line.startsWith('# ')) {
        line = line.replaceFirst('# ', '');
        widget = Text(
          line,
          style: theme.headlineLarge,
        );
      }
      else if (line.startsWith('* ')) {
        line = line.replaceFirst('* ', '');
        widget = Row(
          children: [
            const SizedBox(
              width: 10.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('• '),
              ),
            ),
            Flexible(
              child: Text(line),
            ),
          ],
        );
      }
      else if (line.startsWith('    * ')) {
        line = line.replaceFirst('    * ', '');
        widget = Row(
          children: [
            const SizedBox(
              width: 30.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('• '),
              ),
            ),
            Flexible(
              child: Text(line),
            ),
          ],
        );
      }
      else if (line.startsWith('        * ')) {
        line = line.replaceFirst('        * ', '');
        widget = Row(
          children: [
            const SizedBox(
              width: 50.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('• '),
              ),
            ),
            Flexible(
              child: Text(line),
            ),
          ],
        );
      }
      else {
        widget = Text(
          line,
          style: theme.bodyMedium,
        );
      }
      widgets.add(widget);
    }

    _contents = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,    
      children: widgets,
    );
  }

  Widget get contents => _contents;
}
