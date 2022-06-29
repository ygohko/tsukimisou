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

class Memo {
  var _id = 0;
  var _lastModified = 0;
  var _text = '';
  var _tags = [];
  var _revision = 0;
  var _lastMergedRevision = 0;

  Memo() {
    // Do nothing
  }

  int get id {
    return _id;
  }

  void set id(int id) {
    _id = id;
  }

  int get lastModified {
    return _lastModified;
  }

  void set lastModified(int lastModified) {
    _lastModified = lastModified;
  }

  String get text {
    return text;
  }

  void set text(String text) {
    _text = text;
  }

  int get revision {
    return _revision;
  }

  void set revision(int revision) {
    _revision = revision;
  }

  int get lastMergedRevition {
    return _lastMergedRevision;
  }

  void set lastMergedRevition(int lastMergedRevition) {
    _lastMergedRevision = lastMergedRevition;
  }
}
