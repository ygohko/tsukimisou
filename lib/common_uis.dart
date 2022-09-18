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

import 'dart:io';

import 'package:flutter/material.dart';

late Size _size;

class ColorTheme {
  /// Primary color for this application.
  static const primary = Color(0xFF00003F);

  /// On primary color for this application.
  static const onPrimary = Color(0xFFEFEFFF);

  /// Primary light color for this application.
  static const primaryLight = Color(0xFFE7E7FF);
}

class TextTheme {
  /// Text style for memo attributes on home page.
  static TextStyle homePageMemoAttribute(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyText2;
    if (style == null) {
      style = TextStyle();
    }
    style = style.apply(color: Colors.black.withOpacity(0.6));

    return style;
  }

  /// Text style for memo text on vieweing page.
  static TextStyle viewingPageMemoText(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyText2;
    if (style == null) {
      style = TextStyle();
    }
    style = style.apply(fontSizeFactor: 1.1);

    return style;
  }

  /// Text style for memo attributes on vieweing page.
  static TextStyle viewingPageMemoAttribute(BuildContext context) {
    var style = Theme.of(context).textTheme.subtitle1;
    if (style == null) {
      style = TextStyle();
    }
    style = style.apply(color: Colors.black.withOpacity(0.6));

    return style;
  }
}

/// Shows dialogs to indicate progressing.
void showProgressIndicatorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: const CircularProgressIndicator(),
      );
    },
    barrierDismissible: false,
  );
}

/// Shows dialogs to indicate errors.
Future<void> showErrorDialog(BuildContext context, String text) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('Error'),
            content: Text(text),
            actions: [
              TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ]);
      });
}

/// Creates a subtitle.
Container subtitle(BuildContext context, String text) {
  return Container(
    padding: const EdgeInsets.only(left: 10),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(text,
          style: Theme.of(context).textTheme.caption,
          textAlign: TextAlign.start),
    ),
  );
}

/// Initializes this library.
void init(BuildContext context) {
  _size = MediaQuery.of(context).size;
}

/// Returns whether this device has a large screen.
bool hasLargeScreen() {
  if (Platform.isWindows || Platform.isMacOS) {
    return true;
  }
  if (Platform.isAndroid || Platform.isIOS) {
    if (_size.width < 600 || _size.height < 600) {
      return false;
    }

    return true;
  }

  return false;
}
