/*
 * Copyright (c) 2026 Yasuaki Gohko
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

import 'package:diff_match_patch/diff_match_patch.dart';

class _Line {
  String text = '';
  int operation = 0;

  _Line(this.text, this.operation);
}

class DiffGenerator {
  final String _aText;
  final String _bText;
  String? _result;

  DiffGenerator(this._aText, this._bText);

  void execute() {
    final diffMatchPatch = DiffMatchPatch();
    final diffs = diffMatchPatch.diff(_aText, _bText);
    diffMatchPatch.diffCleanupSemantic(diffs);
    if (diffs.isEmpty) {
      return;
    }
    final lastDiffIndex = diffs.length - 1;
    late final bool hasLastLf;
    if (diffs[lastDiffIndex].text.endsWith('\n')) {
      hasLastLf = true;
    } else {
      hasLastLf = false;
      diffs[lastDiffIndex].text += '\n';
    }
    final lines = <_Line>[];
    var notModifiedLine = '';
    var insertedLine = '';
    var deletedLine = '';
    var inserted = false;
    var deleted = false;
    for (final diff in diffs) {
      var aLines = _lines(diff.text);
      for (var line in aLines) {
        if (diff.operation == DIFF_EQUAL) {
          notModifiedLine += line;
          insertedLine += line;
          deletedLine += line;
        } else if (diff.operation == DIFF_INSERT) {
          insertedLine += line;
          inserted = true;
        } else if (diff.operation == DIFF_DELETE) {
          deletedLine += line;
          deleted = true;
        }

        if (line.endsWith('\n')) {
          if (inserted) {
            lines.add(_Line(insertedLine, 1));
          }
          if (deleted) {
            lines.add(_Line(deletedLine, -1));
          }
          if (!inserted && !deleted) {
            lines.add(_Line(notModifiedLine, 0));
          }
          notModifiedLine = '';
          insertedLine = '';
          deletedLine = '';
          inserted = false;
          deleted = false;
        }
      }
    }
    if (inserted) {
      lines.add(_Line(insertedLine, 1));
    }
    if (deleted) {
      lines.add(_Line(deletedLine, -1));
    }
    if (!inserted && !deleted) {
      lines.add(_Line(notModifiedLine, 0));
    }

    var result = '$_conflictWarningText\n\n';
    var currentOperation = 0;
    for (final line in lines) {
      final operation = line.operation;
      if (currentOperation == -1 && operation != -1) {
        result += '>>>>>>>>>>\n';
      }
      if (currentOperation == 1 && operation != 1) {
        result += '<<<<<<<<<<\n';
      }
      if (operation == -1 && currentOperation != -1) {
        result += '>>> $_localMarkerText >>>\n';
      }
      if (operation == 1 && currentOperation != 1) {
        result += '<<< $_cloudMarkerText <<<\n';
      }
      currentOperation = operation;
      result += line.text;
    }
    if (currentOperation == -1) {
      result += '>>>>>>>>>>\n';
    }
    if (currentOperation == 1) {
      result += '<<<<<<<<<<\n';
    }

    if (!hasLastLf) {
      result = result.substring(0, result.length - 1);
    }

    _result = result;
  }

  String? get result => _result;

  List<String> _lines(String text) {
    var done = false;
    final result = <String>[];
    while (!done) {
      final index = text.indexOf('\n');
      if (index < 0) {
        if (text != '') {
          result.add(text);
        }
        done = true;
      } else {
        result.add(text.substring(0, index + 1));
        text = text.substring(index + 1);
      }
    }

    return result;
  }
}
