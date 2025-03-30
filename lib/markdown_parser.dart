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

enum _State {
  body,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  unorderedList1,
  unorderedList2,
  unorderedList3,
}

enum _SpanState {
  normal,
  strikethroughStarted,
}

class MarkdownParser {
  late final BuildContext _context;
  late final String _text;
  late final Widget _contents;
  var _state = _State.body;
  var _spanState = _SpanState.normal;

  MarkdownParser(BuildContext context, String text) {
    _context = context;
    _text = text;
  }

  void execute() {
    final theme = Theme.of(_context).textTheme;
    final lines = _text.split('\n');
    final widgets = <Widget>[];
    for (var line in lines) {
      line = line.replaceFirst('\n', '');
      _state = _State.body;
      if (line.startsWith('### ')) {
        line = line.replaceFirst('### ', '');
        _state = _State.headlineSmall;
      }
      else if (line.startsWith('## ')) {
        line = line.replaceFirst('## ', '');
        _state = _State.headlineMedium;
      }
      else if (line.startsWith('# ')) {
        line = line.replaceFirst('# ', '');
        _state = _State.headlineLarge;
      }
      else if (line.startsWith('* ')) {
        line = line.replaceFirst('* ', '');
        _state = _State.unorderedList1;
      }
      else if (line.startsWith('    * ')) {
        line = line.replaceFirst('    * ', '');
        _state = _State.unorderedList2;
      }
      else if (line.startsWith('        * ')) {
        line = line.replaceFirst('        * ', '');
        _state = _State.unorderedList3;
      }

      var done = false;
      _spanState = _SpanState.normal;
      final spans = <InlineSpan>[];
      while (!done) {
        final index = line.indexOf('~~');
        if (index != -1) {
          final aLine = line.substring(0, index);
          line = line.substring(index + 2);
          if (_spanState == _SpanState.normal) {
            if (aLine.length > 0) {
              spans.add(TextSpan(text: aLine));
            }
            _spanState = _SpanState.strikethroughStarted;
          } else {
            if (aLine.length > 0) {
              spans.add(TextSpan(
                  text: aLine,
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                  ),
              ));
            }
            _spanState = _SpanState.normal;
          }
        } else {
          done = true;
        }
      }
      if (line.length > 0) {
        spans.add(TextSpan(text: line));
      }
      
      late final Widget widget;
      switch (_state) {
      case _State.body:
        widget = RichText(
          text: TextSpan(
            style: theme.bodyMedium,
            children: spans,
          )
        );
        break;

      case _State.headlineLarge:
        widget = RichText(
          text: TextSpan(
            style: theme.headlineLarge,
            children: spans,
          ),
        );
        break;

      case _State.headlineMedium:
        widget = RichText(
          text: TextSpan(
            style: theme.headlineMedium,
            children: spans,
          ),
        );
        break;

      case _State.headlineSmall:
        widget = RichText(
          text: TextSpan(
            style: theme.headlineSmall,
            children: spans,
          ),
        );
        break;
        
      case _State.unorderedList1:
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
              child: RichText(
                text: TextSpan(
                  children: spans
                ),
              ),
            ),
          ],
        );
        break;

      case _State.unorderedList2:
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
              child: RichText(
                text: TextSpan(
                  children: spans,
                ),
              ),
            ),
          ],
        );
        break;

      case _State.unorderedList3:
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
              child: RichText(
                text :TextSpan(
                  children: spans,
                ),
              ),
            ),
          ],
        );
        break;
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
