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

import 'dart:math' as math;

enum _DiffType { insertion, unchanged, deletion }

/// Generator for generating a diff of two texts.
class DiffGenerator {
  final String _aText;
  final String _bText;
  String? _result;
  String _conflictWarningText = "This memo has conflicts.";
  String _localMarkerText = "Local";
  String _cloudMarkerText = "Cloud";

  /// Creates a DiffGenerator.
  DiffGenerator(this._aText, this._bText);

  /// Executes the diff generation.
  void execute() {
    if (_aText == _bText) {
      _result = _aText;

      return;
    }

    var text = _aText;
    var aLines = <String>[];
    if (text.endsWith('\n')) {
      text = _removeLastLf(text);
      aLines = text.split('\n');
      for (int i = 0; i < aLines.length; i++) {
        aLines[i] += '\n';
      }
    } else {
      aLines = text.split('\n');
      for (int i = 0; i < aLines.length - 1; i++) {
        aLines[i] += '\n';
      }
    }
    text = _bText;
    var bLines = <String>[];
    if (text.endsWith('\n')) {
      text = _removeLastLf(text);
      bLines = text.split('\n');
      for (int i = 0; i < bLines.length; i++) {
        bLines[i] += '\n';
      }
    } else {
      bLines = text.split('\n');
      for (int i = 0; i < bLines.length - 1; i++) {
        bLines[i] += '\n';
      }
    }
    final diffs = _patienceDiff(aLines, bLines);
    var result = '$_conflictWarningText\n\n';
    var removesLastLf = false;
    if (!_endsWithLf(diffs.last)) {
      removesLastLf = true;
    }

    var lines = '';
    var inserted = false;
    var deleted = false;
    for (final diff in diffs) {
      switch (diff) {
        case _Insertion():
          if (deleted) {
            lines += '>>>>>>>>>>\n';
            result += lines;
            deleted = false;
          }
          if (!inserted) {
            inserted = true;
            lines = '<<< $_cloudMarkerText <<<\n';
          }
          lines += '${_removeLastLf(diff.value)}\n';
          break;

        case _Deletion():
          if (inserted) {
            lines += '<<<<<<<<<<\n';
            result += lines;
            inserted = false;
          }
          if (!deleted) {
            deleted = true;
            lines = '>>> $_localMarkerText >>>\n';
          }
          lines += '${_removeLastLf(diff.value)}\n';
          break;

        case _Unchanged():
          if (inserted) {
            lines += '<<<<<<<<<<\n';
            result += lines;
            inserted = false;
          }
          if (deleted) {
            lines += '>>>>>>>>>>\n';
            result += lines;
            deleted = false;
          }
          result += '${_removeLastLf(diff.a)}\n';
          break;
      }
    }
    if (inserted) {
      lines += '<<<<<<<<<<\n';
      result += lines;
      inserted = false;
    }
    if (deleted) {
      lines += '>>>>>>>>>>\n';
      result += lines;
      deleted = false;
    }
    if (removesLastLf) {
      result = _removeLastLf(result);
    }

    _result = result;
  }

  /// Result of the diff generation.
  String? get result => _result;

  /// Sets a conflict warning text.
  set conflictWarningText(String text) {
    _conflictWarningText = text;
  }

  /// Sets a local marker text.
  set localMarkerText(String text) {
    _localMarkerText = text;
  }

  /// Sets a cloud marker text.
  set cloudMarkerText(String text) {
    _cloudMarkerText = text;
  }

  static String _removeLastLf(String string) {
    final length = string.length;
    if (length < 1) {
      return '';
    }
    if (string.endsWith('\n')) {
      return string.substring(0, length - 1);
    }

    return string;
  }

  static bool _endsWithLf(_DiffComponent diff) {
    if (diff is _Insertion) {
      if (diff.value.endsWith('\n')) {
        return true;
      }
    }
    if (diff is _Deletion) {
      if (diff.value.endsWith('\n')) {
        return true;
      }
    }
    if (diff is _Unchanged) {
      if (diff.a.endsWith('\n')) {
        return true;
      }
    }

    return false;
  }
}

class _Indexed {
  final int index;
  final String value;

  _Indexed(this.index, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Indexed &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Indexed($index, $value)';
}

sealed class _DiffComponent {}

class _Insertion extends _DiffComponent {
  final String value;
  _Insertion(this.value);
  @override
  String toString() => 'Insertion($value)';
}

class _Unchanged extends _DiffComponent {
  final String a;
  final String b;
  _Unchanged(this.a, this.b);
  @override
  String toString() => 'Unchanged($a, $b)';
}

class _Deletion extends _DiffComponent {
  final String value;
  _Deletion(this.value);
  @override
  String toString() => 'Deletion($value)';
}

List<_DiffComponent> _patienceDiff(List<String> a, List<String> b) {
  if (a.isEmpty && b.isEmpty) {
    return [];
  }

  if (a.isEmpty) {
    return b.map((e) => _Insertion(e)).toList();
  }

  if (b.isEmpty) {
    return a.map((e) => _Deletion(e)).toList();
  }

  var commonPrefix = _commonPrefix(a, b);
  if (commonPrefix.isNotEmpty) {
    var restA = a.sublist(commonPrefix.length);
    var restB = b.sublist(commonPrefix.length);
    return [...commonPrefix, ..._patienceDiff(restA, restB)];
  }

  var commonSuffix = _commonSuffix(a, b);
  if (commonSuffix.isNotEmpty) {
    var prevA = a.sublist(0, a.length - commonSuffix.length);
    var prevB = b.sublist(0, b.length - commonSuffix.length);
    return [..._patienceDiff(prevA, prevB), ...commonSuffix];
  }

  var indexedA = [for (var i = 0; i < a.length; i++) _Indexed(i, a[i])];
  var indexedB = [for (var i = 0; i < b.length; i++) _Indexed(i, b[i])];

  var uniqA = _uniqueElements(indexedA);
  var uniqB = _uniqueElements(indexedB);

  var table = _LcsTable(uniqA, uniqB);
  var lcs = table.longestCommonSubsequence();

  if (lcs.isEmpty) {
    var fallbackTable = _LcsTable(indexedA, indexedB);
    return fallbackTable.diff().map((c) {
      return switch (c) {
        _LcsInsertion(value: var elemB) => _Insertion(b[elemB.index]),
        _LcsUnchanged(a: var elemA, b: var elemB) =>
          _Unchanged(a[elemA.index], b[elemB.index]),
        _LcsDeletion(value: var elemA) => _Deletion(a[elemA.index]),
      };
    }).toList();
  }

  List<_DiffComponent> ret = [];
  int lastIndexA = 0;
  int lastIndexB = 0;

  for (var match in lcs) {
    var matchA = match.$1;
    var matchB = match.$2;

    var subsetA = a.sublist(lastIndexA, matchA.index);
    var subsetB = b.sublist(lastIndexB, matchB.index);

    ret.addAll(_patienceDiff(subsetA, subsetB));
    ret.add(_Unchanged(matchA.value, matchB.value));

    lastIndexA = matchA.index + 1;
    lastIndexB = matchB.index + 1;
  }

  var subsetA = a.sublist(lastIndexA);
  var subsetB = b.sublist(lastIndexB);
  ret.addAll(_patienceDiff(subsetA, subsetB));

  return ret;
}

List<_DiffComponent> _commonPrefix(List<String> a, List<String> b) {
  List<_DiffComponent> prefix = [];
  int len = a.length < b.length ? a.length : b.length;
  for (int i = 0; i < len; i++) {
    if (a[i] == b[i]) {
      prefix.add(_Unchanged(a[i], b[i]));
    } else {
      break;
    }
  }
  return prefix;
}

List<_DiffComponent> _commonSuffix(List<String> a, List<String> b) {
  List<_DiffComponent> suffix = [];
  int len = a.length < b.length ? a.length : b.length;
  for (int i = 1; i <= len; i++) {
    if (a[a.length - i] == b[b.length - i]) {
      suffix.add(_Unchanged(a[a.length - i], b[b.length - i]));
    } else {
      break;
    }
  }
  return suffix.reversed.toList();
}

List<T> _uniqueElements<T>(List<T> elems) {
  Map<T, int> counts = {};
  for (var elem in elems) {
    counts[elem] = (counts[elem] ?? 0) + 1;
  }
  return elems.where((elem) => counts[elem] == 1).toList();
}

sealed class _LcsDiffComponent {
  const _LcsDiffComponent();
}

class _LcsInsertion extends _LcsDiffComponent {
  final _Indexed value;
  const _LcsInsertion(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _LcsInsertion && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LcsInsertion($value)';
}

class _LcsUnchanged extends _LcsDiffComponent {
  final _Indexed a;
  final _Indexed b;
  const _LcsUnchanged(this.a, this.b);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LcsUnchanged && a == other.a && b == other.b;

  @override
  int get hashCode => Object.hash(a, b);

  @override
  String toString() => 'LcsUnchanged($a, $b)';
}

class _LcsDeletion extends _LcsDiffComponent {
  final _Indexed value;
  const _LcsDeletion(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _LcsDeletion && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LcsDeletion($value)';
}

class _LcsTable {
  final List<List<int>> lengths;
  final List<_Indexed> a;
  final List<_Indexed> b;

  _LcsTable._(this.lengths, this.a, this.b);

  factory _LcsTable(List<_Indexed> a, List<_Indexed> b) {
    List<List<int>> lengths = List.generate(
      a.length + 1,
      (_) => List.filled(b.length + 1, 0),
    );

    for (int i = 0; i < a.length; i++) {
      for (int j = 0; j < b.length; j++) {
        if (a[i] == b[j]) {
          lengths[i + 1][j + 1] = 1 + lengths[i][j];
        } else {
          lengths[i + 1][j + 1] =
              math.max(lengths[i + 1][j], lengths[i][j + 1]);
        }
      }
    }

    return _LcsTable._(lengths, a, b);
  }

  List<(_Indexed, _Indexed)> longestCommonSubsequence() {
    return _findLcs(a.length, b.length);
  }

  List<(_Indexed, _Indexed)> _findLcs(int i, int j) {
    if (i == 0 || j == 0) {
      return [];
    }

    if (a[i - 1] == b[j - 1]) {
      var prefixLcs = _findLcs(i - 1, j - 1);
      prefixLcs.add((a[i - 1], b[j - 1]));
      return prefixLcs;
    } else {
      if (lengths[i][j - 1] > lengths[i - 1][j]) {
        return _findLcs(i, j - 1);
      } else {
        return _findLcs(i - 1, j);
      }
    }
  }

  Set<List<(_Indexed, _Indexed)>> longestCommonSubsequences() {
    return _findAllLcs(a.length, b.length);
  }

  Set<List<(_Indexed, _Indexed)>> _findAllLcs(int i, int j) {
    if (i == 0 || j == 0) {
      return {[]};
    }

    if (a[i - 1] == b[j - 1]) {
      Set<List<(_Indexed, _Indexed)>> sequences = {};
      for (var lcs in _findAllLcs(i - 1, j - 1)) {
        var newLcs = List<(_Indexed, _Indexed)>.from(lcs);
        newLcs.add((a[i - 1], b[j - 1]));
        sequences.add(newLcs);
      }
      return sequences;
    } else {
      Set<List<(_Indexed, _Indexed)>> sequences = {};

      if (lengths[i][j - 1] >= lengths[i - 1][j]) {
        sequences.addAll(_findAllLcs(i, j - 1));
      }

      if (lengths[i - 1][j] >= lengths[i][j - 1]) {
        sequences.addAll(_findAllLcs(i - 1, j));
      }

      return sequences;
    }
  }

  List<_LcsDiffComponent> diff() {
    return _computeDiff(a.length, b.length);
  }

  List<_LcsDiffComponent> _computeDiff(int i, int j) {
    if (i == 0 && j == 0) {
      return [];
    }

    _DiffType diffType;
    if (i == 0) {
      diffType = _DiffType.insertion;
    } else if (j == 0) {
      diffType = _DiffType.deletion;
    } else if (a[i - 1] == b[j - 1]) {
      diffType = _DiffType.unchanged;
    } else if (lengths[i][j - 1] > lengths[i - 1][j]) {
      diffType = _DiffType.insertion;
    } else {
      diffType = _DiffType.deletion;
    }

    var (toAdd, restDiff) = switch (diffType) {
      _DiffType.insertion => (
          _LcsInsertion(b[j - 1]),
          _computeDiff(i, j - 1),
        ),
      _DiffType.unchanged => (
          _LcsUnchanged(a[i - 1], b[j - 1]),
          _computeDiff(i - 1, j - 1),
        ),
      _DiffType.deletion => (
          _LcsDeletion(a[i - 1]),
          _computeDiff(i - 1, j),
        ),
    };

    restDiff.add(toAdd);
    return restDiff;
  }
}
