/*
 * Copyright (c) 2025 Yasuaki Gohko
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

typedef MemoLinkCallback = void Function(String memoName);

enum _LineKind {
  none,
  body,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  unorderedList,
  orderedList,
}

enum _SpanState {
  normal,
  strikethroughStarted,
  linkTextStarted,
  linkTargetStarted,
  autolinkStarted,
  codeStarted,
}

class _ProcessedLine {
  var indent = 0;
  var lineKind = _LineKind.body;
  var spans = <InlineSpan>[];
  var paragraphStarted = false;
}

class MarkdownParser {
  late final BuildContext _context;
  late final String _text;
  late final MemoLinkCallback? _onMemoLinkRequested;
  late final Widget _contents;
  late final ColorScheme _colorScheme;
  var _spanState = _SpanState.normal;
  var _processedLine = _ProcessedLine();
  var _linkText = '';

  static TextTheme? _textTheme;

  /// Creates a markdown parser.
  MarkdownParser(BuildContext context, String text,
      {MemoLinkCallback? onMemoLinkRequested}) {
    _context = context;
    _text = text;
    _onMemoLinkRequested = onMemoLinkRequested;
    final theme = Theme.of(_context);
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

  /// Execute this markdown parser.
  void execute() {
    final textTheme = _textTheme!;
    final lines = _text.split('\n');
    final parsers = [
      _parseHeadlineLarge,
      _parseHeadlineMedium,
      _parseHeadlineSmall,
      _parseUnorderedList,
      _parseOrderedList,
      _parseStrikethrough,
      _parseChechboxChecked,
      _parseChechboxUnchecked,
      _parseLinkTextStarted,
      _parseLinkTargetStarted,
      _parseLinkTargetEnded,
      _parseAutolinkStarted,
      _parseAutolinkEnded,
      _parseCode,
      _parseThemeticBreak,
      _parseParagraphStarted,
    ];
    final processedLines = <_ProcessedLine>[];

    for (var line in lines) {
      line = line.replaceFirst('\n', '');
      _processedLine = _ProcessedLine();
      _spanState = _SpanState.normal;
      _processedLine = _ProcessedLine();

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
        _processedLine.spans.add(TextSpan(text: line));
      }

      processedLines.add(_processedLine);
    }

    final listLevels = _listLevelsFromProcessedLines(processedLines);

    final widgets = <Widget>[];
    var previousLineKind = _LineKind.none;
    var orderedListNumber = 1;
    for (final processedLine in processedLines) {
      if (processedLine.paragraphStarted &&
          previousLineKind == _LineKind.body) {
        widgets.add(const SizedBox(height: 10.0));
      }
      if (processedLine.spans.isNotEmpty) {
        late final Widget widget;
        switch (processedLine.lineKind) {
          case _LineKind.body:
            widget = Text.rich(
              TextSpan(
                style: textTheme.bodyMedium,
                children: processedLine.spans,
              ),
            );
            break;

          case _LineKind.headlineLarge:
            widget = Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text.rich(
                TextSpan(
                  style: textTheme.headlineLarge,
                  children: processedLine.spans,
                ),
              ),
            );
            break;

          case _LineKind.headlineMedium:
            widget = Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text.rich(
                TextSpan(
                  style: textTheme.headlineMedium,
                  children: processedLine.spans,
                ),
              ),
            );
            break;

          case _LineKind.headlineSmall:
            widget = Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text.rich(
                TextSpan(
                  style: textTheme.headlineSmall,
                  children: processedLine.spans,
                ),
              ),
            );
            break;

          case _LineKind.unorderedList:
            var listLevel = listLevels[processedLine.indent] ?? 0;
            widget = Row(
              children: [
                SizedBox(
                  width: 10.0 + listLevel * 20.0,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('• '),
                  ),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium,
                      children: processedLine.spans,
                    ),
                  ),
                ),
              ],
            );
            break;

          case _LineKind.orderedList:
            if (previousLineKind != _LineKind.orderedList) {
              orderedListNumber = 1;
            } else {
              orderedListNumber++;
            }
            widget = Row(
              children: [
                SizedBox(
                  width: 15.0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('$orderedListNumber. '),
                  ),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium,
                      children: processedLine.spans,
                    ),
                  ),
                ),
              ],
            );
            break;

          default:
            break;
        }
        widgets.add(widget);
      }

      previousLineKind = processedLine.lineKind;
    }

    _contents = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Contents that are generated by this markdown parser.
  Widget get contents => _contents;

  /// Text theme that is used by this markdown parser.
  TextTheme get textTheme => _textTheme!;

  void _showLinked(String link) {
    final regExp = RegExp(r'^https?://');
    final matched = regExp.firstMatch(link);
    if (matched != null) {
      launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
    } else {
      _onMemoLinkRequested!(link);
    }
  }

  (String, bool) _parseHeadlineLarge(String line) {
    if (line.startsWith('# ')) {
      line = line.replaceFirst('# ', '');
      _processedLine.lineKind = _LineKind.headlineLarge;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseHeadlineMedium(String line) {
    if (line.startsWith('## ')) {
      line = line.replaceFirst('## ', '');
      _processedLine.lineKind = _LineKind.headlineMedium;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseHeadlineSmall(String line) {
    if (line.startsWith('### ')) {
      line = line.replaceFirst('### ', '');
      _processedLine.lineKind = _LineKind.headlineSmall;

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseUnorderedList(String line) {
    final regExp = RegExp(r'^ *[\+\-\*] ');
    final match = regExp.firstMatch(line);
    if (match != null) {
      final string = match.group(0);
      if (string != null) {
        line = line.replaceFirst(regExp, '');
        _processedLine.indent = string.length - 2;
        _processedLine.lineKind = _LineKind.unorderedList;

        return (line, true);
      }
    }

    return (line, false);
  }

  (String, bool) _parseOrderedList(String line) {
    final regExp = RegExp(r'^ *\d+[.)] ');
    final match = regExp.firstMatch(line);
    if (match != null) {
      final string = match.group(0);
      if (string != null) {
        line = line.replaceFirst(regExp, '');
        _processedLine.indent = 0;
        _processedLine.lineKind = _LineKind.orderedList;

        return (line, true);
      }
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
          _processedLine.spans.add(TextSpan(text: aLine));
        }
        _spanState = _SpanState.strikethroughStarted;
      } else {
        if (aLine.isNotEmpty) {
          _processedLine.spans.add(TextSpan(
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
      _processedLine.spans.add(
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
      _processedLine.spans.add(
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
          _processedLine.spans.add(TextSpan(text: aLine));
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
          TapGestureRecognizer? recognizer;
          if (_onMemoLinkRequested != null) {
            recognizer = TapGestureRecognizer()
              ..onTap = () {
                _showLinked(aLine);
              };
          }

          _processedLine.spans.add(TextSpan(
            text: _linkText,
            style: TextStyle(
              color: _colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: recognizer,
          ));
        }
        _spanState = _SpanState.normal;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseAutolinkStarted(String line) {
    final regExp = RegExp(r'<.*>');
    final matched = regExp.firstMatch(line);
    if (matched != null && _spanState != _SpanState.autolinkStarted) {
      final index = line.indexOf('<');
      final aLine = line.substring(0, index);
      line = line.substring(index + 1);
      if (_spanState == _SpanState.normal) {
        if (aLine.isNotEmpty) {
          _processedLine.spans.add(TextSpan(text: aLine));
        }
        _spanState = _SpanState.autolinkStarted;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseAutolinkEnded(String line) {
    final index = line.indexOf('>');
    if (index != -1 && _spanState == _SpanState.autolinkStarted) {
      final aLine = line.substring(0, index);
      line = line.substring(index + 1);
      if (_spanState == _SpanState.autolinkStarted) {
        if (aLine.isNotEmpty) {
          TapGestureRecognizer? recognizer;
          if (_onMemoLinkRequested != null) {
            recognizer = TapGestureRecognizer()
              ..onTap = () {
                _showLinked(aLine);
              };
          }

          _processedLine.spans.add(TextSpan(
            text: aLine,
            style: TextStyle(
              color: _colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: recognizer,
          ));
        }
        _spanState = _SpanState.normal;
      }

      return (line, true);
    }

    return (line, false);
  }

  (String, bool) _parseCode(String line) {
    final index = line.indexOf('`');
    if (index != -1) {
      if (_spanState == _SpanState.normal) {
        final aLine = line.substring(0, index);
        line = line.substring(index + 1);
        if (aLine.isNotEmpty) {
          _processedLine.spans.add(TextSpan(text: aLine));
        }
        _spanState = _SpanState.codeStarted;

        return (line, true);
      } else if (_spanState == _SpanState.codeStarted) {
        final aLine = line.substring(0, index);
        line = line.substring(index + 1);
        if (aLine.isNotEmpty) {
          _processedLine.spans.add(TextSpan(
            text: aLine,
            style: TextStyle(
              backgroundColor: Colors.grey[300],
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
            ),
          ));
        }
        _spanState = _SpanState.normal;
        
        return (line, true);
      }
    }

    return (line, false);
  }

  (String, bool) _parseThemeticBreak(String line) {
    if (line.startsWith('---')) {
      line = '';
      _processedLine.spans.add(
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
    if (_processedLine.paragraphStarted || _processedLine.spans.isNotEmpty) {
      return (line, false);
    }

    if (line.isEmpty) {
      _processedLine.paragraphStarted = true;

      return (line, true);
    }

    return (line, false);
  }

  static Map<int, int> _listLevelsFromProcessedLines(
      List<_ProcessedLine> processedLines) {
    final indents = [];
    for (final processedLine in processedLines) {
      final indent = processedLine.indent;
      if (!indents.contains(indent)) {
        indents.add(indent);
      }
    }
    indents.sort();

    final result = <int, int>{};
    var index = 0;
    for (final indent in indents) {
      result[indent] = index;
      index++;
    }

    return result;
  }
}
