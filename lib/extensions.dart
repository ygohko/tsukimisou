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

import 'package:intl/intl.dart';

extension StringConverting on DateTime {
  /// Returns a string that contains detailed information of this instance.
  String toDetailedString() {
    final format = DateFormat('yyyy/MM/dd HH:mm');
    return format.format(this);
  }

  /// Returns a string that contains information changes depended by elapsed days of this instance.
  String toSmartString() {
    final now = DateTime.now();
    if (year == now.year) {
      if (month == now.month && day == now.day) {
        final format = DateFormat('HH:mm');
        return format.format(this);
      } else {
        final format = DateFormat('MM/dd HH:mm');
        return format.format(this);
      }
    } else {
      final format = DateFormat('yyyy/MM/dd');
      return format.format(this);
    }
  }
}
