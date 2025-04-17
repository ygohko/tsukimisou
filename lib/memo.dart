/*
 * Copyright (c) 2022, 2025 Yasuaki Gohko
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

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class Memo {
  /// A ID of this memo.
  var id = '';

  /// Epoch milliseconds from last modified.
  var lastModified = 0;

  /// Revision of this memo.
  var revision = 0;

  /// Revision when last merged.
  var lastMergedRevision = 0;

  /// Hash before modified.
  var beforeModifiedHash = '';

  var _text = '';
  var _tags = <String>[];
  var _name = '';
  var _viewingMode = 'Plain';

  /// Creates a memo.
  Memo() {
    const uuid = Uuid();
    id = uuid.v4();
  }

  /// Begins modification by user.
  void beginModification() {
    if (revision == lastMergedRevision) {
      beforeModifiedHash = hash;
    }
  }

  /// Copy this memo.
  Memo copy() {
    final result = Memo();
    result.id = id;
    result.lastModified = lastModified;
    result.revision = revision;
    result.lastMergedRevision = lastMergedRevision;
    result.beforeModifiedHash = beforeModifiedHash;
    result._text = _text;
    result._tags = [..._tags];
    result._name = _name;
    result._viewingMode = _viewingMode;

    return result;
  }

  /// Returns a JSON serializable object.
  dynamic toSerializable() {
    return {
      'id': id,
      'lastModified': lastModified,
      'text': _text,
      'tags': _tags,
      'name': _name,
      'viewingMode': _viewingMode,
      'revision': revision,
      'lastMergedRevision': lastMergedRevision,
      'beforeModifiedHash': beforeModifiedHash
    };
  }

  /// Text of this memo.
  String get text => _text;

  /// Text of this memo.
  set text(String text) {
    _text = text;
    lastModified = DateTime.now().millisecondsSinceEpoch;
    revision++;
  }

  /// Tags added to this memo.
  List<String> get tags => _tags;

  /// Tags added to this memo.
  set tags(List<String> tags) {
    _tags = tags;
    lastModified = DateTime.now().millisecondsSinceEpoch;
    revision++;
  }

  /// Name of this memo.
  String get name => _name;

  /// Name of this memo.
  set name(String name) {
    _name = name;
    lastModified = DateTime.now().millisecondsSinceEpoch;
    revision++;
  }

  /// Viewing mode of this memo.
  String get viewingMode => _viewingMode;

  /// Viewing mode of this memo.
  set viewingMode(String viewingMode) {
    _viewingMode = viewingMode;
    lastModified = DateTime.now().millisecondsSinceEpoch;
    revision++;
  }

  /// Hash generated from this memo.
  String get hash {
    // TODO: Consider name and viewing mode?
    var string = 'text: $_text\ntags: ';
    for (final tag in _tags) {
      string += '$tag, ';
    }
    final values = utf8.encode(string);

    return sha256.convert(values).toString();
  }
}
