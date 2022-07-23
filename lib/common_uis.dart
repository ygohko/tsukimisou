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

class ThemeColors {
  /// Primary color for this application.
  static const primary = Color(0xFF00003F);

  /// On primary color for this application.
  static const onPrimary = Color(0xFFEFEFFF);
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
              FlatButton(
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
