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
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Rename to LineKind?
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
  linkTextStarted,
  linkTargetStarted,
  autolinkStarted,
}

class MarkdownParser {
  late final BuildContext _context;
  late final String _text;
  late final Widget _contents;
  late final ColorScheme _colorScheme;
  var _state = _State.body;
  var _spanState = _SpanState.normal;
  var _spans = <InlineSpan>[];
  var _linkText = '';
  var _paragraphStarted = false;

  static TextTheme? _textTheme;

  MarkdownParser(BuildContext context, String text) {
    _context = context;
    _text = text;
    final theme = Theme.of(_context);
    // TODO: Store text theme into static variable.
    if (_textTheme == null) {
      var headlineLargeStyle = theme.textTheme.headlineLarge;
      if (headlineLargeStyle != null) {
        final fontSize = headlineLargeStyle.fontSize;
        if (fontSize != null) {
          headlineLargeStyle =
              headlineLargeStyle.copyWith(fontSize: fontSize * 0.7);
        }
      }
      var headlineMediumStyle = theme.textTheme.headlineMedium;
      if (headlineMediumStyle != null) {
        final fontSize = headlineMediumStyle.fontSize;
        if (fontSize != null) {
          headlineMediumStyle =
              headlineMediumStyle.copyWith(fontSize: fontSize * 0.7);
        }
      }
      var headlineSmallStyle = theme.textTheme.headlineSmall;
      if (headlineSmallStyle != null) {
        final fontSize = headlineSmallStyle.fontSize;
        if (fontSize != null) {
          headlineSmallStyle =
              headlineSmallStyle.copyWith(fontSize: fontSize * 0.7);
        }
      }
      _textTheme = theme.textTheme.copyWith(
        headlineLarge: headlineLargeStyle,
        headlineMedium: headlineMediumStyle,
        headlineSmall: headlineSmallStyle,
      );
    }
    _colorScheme = theme.colorScheme;
  }

  void execute() {
    final textTheme = _textTheme!;
    final lines = _text.split('\n');
    final widgets = <Widget>[];

    final parsers = [
      _parseHeadlineLarge,
      _parseHeadlineMedium,
      _parseHeadlineSmall,
      _parseUnorderdList1,
      _parseUnorderdList2,
      _parseUnorderdList3,
      _parseStrikethrough,
      _parseChechboxChecked,
      _parseChechboxUnchecked,
      _parseLinkTextStarted,
      _parseLinkTargetStarted,
      _parseLinkTargetEnded,
      _parseAutolinkStarted,
      _parseAutolinkEnded,
      _parseThemeticBreak,
      _parseParagraphStarted,
    ];

    for (var line in lines) {
      line = line.replaceFirst('\n', '');
      _state = _State.body;
      _spanState = _SpanState.normal;
      _spans = <InlineSpan>[];

      var aDone = false;
      while (!aDone) {
        aDone = true;
        for (final parser in parsers) {
          final (aLine, parsed) = parser(line);
          line = aLine;
          if (parsed) {
            aDone = false;
            break;
          }
        }
      }
      if (line.isNotEmpty) {
        _spans.add(TextSpan(text: line));
      }

      if (_paragraphStarted) {
        widgets.add(const SizedBox(height: 10.0));
        _paragraphStarted = false;
      }
      if (_spans.isNotEmpty) {
        late final Widget widget;
        switch (_state) {
          case _State.body:
            widget = RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: _spans,
              ),
            );
            break;

          case _State.headlineLarge:
            widget = Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: RichText(
                text: TextSpan(
                  style: textTheme.headlineLarge,
                  children: _spans,
                ),
              ),
            );
            break;

          case _State.headlineMedium:
            widget = Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: RichText(
                text: TextSpan(
                  style: textTheme.headlineMedium,
                  children: _spans,
                ),
              ),
            );
            break;

          case _State.headlineSmall:
            widget = Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: RichText(
                text: TextSpan(
                  style: textTheme.headlineSmall,
                  children: _spans,
                ),
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
                      style: textTheme.bodyMedium,
                      children: _spans,
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
                      style: textTheme.bodyMedium,
                      children: _spans,
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
                    text: TextSpan(
                      style: textTheme.bodyMedium,
                      children: _spans,
                    ),
                  ),
                ),
              ],
            );
            break;
        }
        widgets.add(widget);
      }
    }

    _contents = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget get contents => _contents;

  TextTheme get textTheme => _textTheme!;

  (String, bool) _parseHeadlineLarge(String line) {
    if (line.startsWith('# ')) {
      line = line.replaceFirst('# ', '');
      _state = _State.headlineLarge;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseHeadlineMedium(String line) {
    if (line.startsWith('## ')) {
      line = line.replaceFirst('## ', '');
      _state = _State.headlineMedium;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseHeadlineSmall(String line) {
    if (line.startsWith('### ')) {
      line = line.replaceFirst('### ', '');
      _state = _State.headlineSmall;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseUnorderdList1(String line) {
    final regExp = RegExp(r'^[\+\-\*] ');
    final match = regExp.firstMatch(line);
    if (match != null) {
      line = line.replaceFirst(regExp, '');
      _state = _State.unorderedList1;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseUnorderdList2(String line) {
    final regExp = RegExp(r'^    [\+\-\*] ');
    final match = regExp.firstMatch(line);
    if (match != null) {
      line = line.replaceFirst(regExp, '');
      _state = _State.unorderedList2;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseUnorderdList3(String line) {
    final regExp = RegExp(r'^        [\+\-\*] ');
    final match = regExp.firstMatch(line);
    if (match != null) {
      line = line.replaceFirst(regExp, '');
      _state = _State.unorderedList3;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseStrikethrough(String line) {
    final index = line.indexOf('~~');
    if (index != -1) {
      final aLine = line.substring(0, index);
      line = line.substring(index + 2);
      if (_spanState == _SpanState.normal) {
        if (aLine.isNotEmpty) {
          _spans.add(TextSpan(text: aLine));
        }
        _spanState = _SpanState.strikethroughStarted;
      } else {
        if (aLine.isNotEmpty) {
          _spans.add(TextSpan(
            text: aLine,
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          ));
        }
        _spanState = _SpanState.normal;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseChechboxChecked(String line) {
    if (line.startsWith('[x]')) {
      line = line.replaceFirst('[x]', '');
      _spans.add(
        const WidgetSpan(
          child: Icon(
            Icons.check_box_rounded,
            size: 20.0,
            color: Colors.green,
          ),
        ),
      );

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseChechboxUnchecked(String line) {
    if (line.startsWith('[ ]')) {
      line = line.replaceFirst('[ ]', '');
      _spans.add(
        const WidgetSpan(
          child: Icon(
            Icons.check_box_outline_blank_rounded,
            size: 20.0,
            color: Colors.red,
          ),
        ),
      );

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseLinkTextStarted(String line) {
    final index = line.indexOf('[');
    if (index != -1) {
      final aLine = line.substring(0, index);
      line = line.substring(index + 1);
      if (_spanState == _SpanState.normal) {
        if (aLine.isNotEmpty) {
          _spans.add(TextSpan(text: aLine));
        }
        _spanState = _SpanState.linkTextStarted;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseLinkTargetStarted(String line) {
    final index = line.indexOf('](');
    if (index != -1) {
      final aLine = line.substring(0, index);
      line = line.substring(index + 2);
      if (_spanState == _SpanState.linkTextStarted) {
        if (aLine.isNotEmpty) {
          _linkText = aLine;
        }
        _spanState = _SpanState.linkTargetStarted;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseLinkTargetEnded(String line) {
    if (_spanState != _SpanState.linkTargetStarted) {
      return (line, false);
    }

    final index = line.indexOf(')');
    if (index != -1) {
      final aLine = line.substring(0, index);
      line = line.substring(index + 1);
      if (_spanState == _SpanState.linkTargetStarted) {
        if (aLine.isNotEmpty) {
          _spans.add(TextSpan(
            text: _linkText,
            style: TextStyle(
              color: _colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(
                  Uri.parse(aLine),
                  mode: LaunchMode.externalApplication,
                );
              },
          ));
        }
        _spanState = _SpanState.normal;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseAutolinkStarted(String line) {
    final index = line.indexOf('<');
    if (index != -1) {
      final aLine = line.substring(0, index);
      line = line.substring(index + 1);
      if (_spanState == _SpanState.normal) {
        if (aLine.isNotEmpty) {
          _spans.add(TextSpan(text: aLine));
        }
        _spanState = _SpanState.autolinkStarted;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseAutolinkEnded(String line) {
    final index = line.indexOf('>');
    if (index != -1) {
      final aLine = line.substring(0, index);
      line = line.substring(index + 1);
      if (_spanState == _SpanState.autolinkStarted) {
        if (aLine.isNotEmpty) {
          _spans.add(TextSpan(
            text: aLine,
            style: TextStyle(
              color: _colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(
                  Uri.parse(aLine),
                  mode: LaunchMode.externalApplication,
                );
              },
          ));
        }
        _spanState = _SpanState.normal;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseThemeticBreak(String line) {
    if (line.startsWith('---')) {
      line = '';
      _spans.add(
        WidgetSpan(
            child: Row(
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Container(
                height: 3.0,
                color: _colorScheme.surfaceDim,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        )),
      );

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseParagraphStarted(String line) {
    if (_paragraphStarted || _spans.isNotEmpty) {
      return (line, false);
    }

    if (line.isEmpty) {
      _paragraphStarted = true;

      return (line, true);
    }

    return (line, false);
  }
}
