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

import 'package:uuid/uuid.dart';

class Memo {
  var _id = '';
  var _lastModified = 0;
  var _text = '';
  var _tags = <String>[];
  var _revision = 0;
  var _lastMergedRevision = 0;

  /// Creates a memo.
  Memo() {
    final uuid = Uuid();
    _id = uuid.v4();
  }

  /// Returns a JSON serializable object.
  dynamic toSerializable() {
    return {
      'id': _id,
      'lastModified': _lastModified,
      'text': _text,
      'tags': _tags,
      'revision': _revision,
      'lastMergedRevision': _lastMergedRevision
    };
  }

  /// A ID of this memo.
  String get id => _id;

  /// A ID of this memo.
  void set id(String id) {
    _id = id;
  }

  /// Epoch milliseconds from last modified.
  int get lastModified => _lastModified;

  /// Epoch milliseconds from last modified.
  void set lastModified(int lastModified) {
    _lastModified = lastModified;
  }

  /// Text of this memo.
  String get text => _text;

  /// Text of this memo.
  void set text(String text) {
    _text = text;
    _lastModified = DateTime.now().millisecondsSinceEpoch;
    _revision++;
  }

  /// Tags added to this memo.
  List<String> get tags => _tags;

  /// Tags added to this memo.
  void set tags(List<String> tags) {
    _tags = tags;
    _lastModified = DateTime.now().millisecondsSinceEpoch;
    _revision++;
  }

  /// Revision of this memo.
  int get revision => _revision;

  /// Revision of this memo.
  void set revision(int revision) {
    _revision = revision;
  }

  /// Revision when last merged.
  int get lastMergedRevision => _lastMergedRevision;

  /// Revision when last merged.
  void set lastMergedRevision(int lastMergedRevision) {
    _lastMergedRevision = lastMergedRevision;
  }
}
