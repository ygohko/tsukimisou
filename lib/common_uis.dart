/*
 * Copyright (c) 2022 - 2025 Yasuaki Gohko
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platform/platform.dart';

import 'extensions.dart';
import 'markdown_parser.dart';
import 'memo.dart';
import 'viewing_page.dart';
import 'gen_l10n/app_localizations.dart';

typedef DialogTransitionBuilder = AnimatedWidget Function(
    Animation<double> animation,
    Curve curve,
    Alignment alignment,
    Widget child);

late Size _size;

enum ArchiveNotFoundDialogResult {
  ok,
  removeThisArchive,
}

class MemoDialogsSize {
  /// Width of memo dialogs.
  static const width = 520.0;

  /// Height of memo dialogs.
  static const height = 555.0;
}

class TsukimisouColors {
  /// Color scheme for this application.
  static final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF00003F),
    surface: const Color(0xFFF7F7FF),
  );

  /// Color for memo card.
  static const memoCard = Color(0xFFFFFFFF);

  /// Color for unchecked check box.
  static const checkBoxUnchecked = Colors.red;

  /// Color for checked check box.
  static const checkBoxChecked = Colors.green;

  /// Color for code text.
  static const codeText = Color(0xFFEFEFFF);

  /// Color for code span background.
  static const codeSpanBackground = Color(0x6FBFBFBF);

  /// Color for code block background.
  static const codeBlockBackground = Color(0xFF00002F);

  /// Color for block quote indicator.
  static const blockQuoteIndicator = Colors.grey;
}

class TsukimisouTextStyles {
  /// Text style for memo attributes on home page.
  static TextStyle homePageMemoAttribute(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyMedium;
    style ??= const TextStyle();
    style = style.apply(color: Colors.black.withValues(alpha: 0.6));

    return style;
  }

  /// Text style for drawer footer on home page.
  static TextStyle homePageDrawerFooter(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyMedium;
    style ??= const TextStyle();
    style = style.apply(color: Colors.black.withValues(alpha: 0.6));

    return style;
  }

  /// Text style for memo text on vieweing page.
  static TextStyle viewingPageMemoText(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyMedium;
    style ??= const TextStyle();
    style = style.apply(fontSizeFactor: 1.1);

    return style;
  }

  /// Text style for memo attributes on vieweing page.
  static TextStyle viewingPageMemoAttribute(BuildContext context) {
    var style = Theme.of(context).textTheme.titleMedium;
    style ??= const TextStyle();
    style = style.apply(color: Colors.black.withValues(alpha: 0.6));

    return style;
  }

  /// Text style for code spans on vieweing page.
  static TextStyle viewingPageCodeSpan(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyMedium;
    style ??= const TextStyle();
    style = GoogleFonts.mPlus1Code(textStyle: style);
    style = style.apply(
      backgroundColor: TsukimisouColors.codeSpanBackground,
      fontWeightDelta: 2,
    );

    return style;
  }

  /// Text style for code blocks on vieweing page.
  static TextStyle viewingPageCodeBlock(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyMedium;
    style ??= const TextStyle();
    style = GoogleFonts.mPlus1Code(textStyle: style);
    style = style.apply(
      color: TsukimisouColors.codeText,
      fontWeightDelta: 2,
    );

    return style;
  }

  /// Text style for text field on editing page.
  static TextStyle editingPageTextField(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyMedium;
    style ??= const TextStyle();
    style = style.apply(
      fontSizeFactor: 1.1,
    );

    return style;
  }

  /// Text style for indicator shown when there are no mems.
  static TextStyle noMemosIndicator(BuildContext context) {
    var style = Theme.of(context).textTheme.titleLarge;
    style ??= const TextStyle();
    style = style.apply(color: Colors.black.withValues(alpha: 0.6));

    return style;
  }
}

class Durations {
  /// Duration for editing transition.
  static const editing = Duration(milliseconds: 400);
}

class DialogTransitionBuilders {
  /// Primary dialog transition.
  static AnimatedWidget primary(Animation<double> animation, Curve curve,
      Alignment alignment, Widget child) {
    return ScaleTransition(
      alignment: alignment,
      scale: CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.00,
          0.50,
          curve: curve,
        ),
      ),
      child: child,
    );
  }

  /// Transition for editing dialog.
  static AnimatedWidget editing(Animation<double> animation, Curve curve,
      Alignment alignment, Widget child) {
    return SlideTransition(
      transformHitTests: false,
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve)).animate(animation),
      child: child,
    );
  }

  /// Transition when showing dialogs from other dialog.
  static AnimatedWidget dialogToDialog(Animation<double> animation, Curve curve,
      Alignment alignment, Widget child) {
    return DialogToDialogTransition(
      phase: animation,
      alignment: alignment,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class DialogToDialogTransition extends AnimatedWidget {
  final Alignment alignment;
  final Widget child;

  /// Creates a dialog to dialog transition.
  const DialogToDialogTransition(
      {Key? key,
      required Animation<double> phase,
      this.alignment = Alignment.center,
      required this.child})
      : super(key: key, listenable: phase);

  Animation<double> get _phase => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 + (1.0 - _phase.value) * -0.2;
    final transform = Matrix4.diagonal3Values(scale, scale, scale);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}

/// Initializes this library.
void init(BuildContext context) {
  _size = MediaQuery.of(context).size;
}

/// Shows dialogs to indicate progressing.
void showProgressIndicatorDialog(BuildContext context) {
  const platform = LocalPlatform();
  late final Widget indicator;
  if (!platform.isApple) {
    indicator = const CircularProgressIndicator();
  } else {
    indicator = const CupertinoActivityIndicator(
      color: Colors.white,
      radius: 20.0,
    );
  }
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: indicator,
      );
    },
    barrierDismissible: false,
  );
}

/// Shows dialogs to prompt confirmation.
Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    String acceptingText,
    String rejectingText,
    bool destructive) async {
  const platform = LocalPlatform();
  var accepted = false;
  if (!platform.isIOS) {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                    child: Text(rejectingText),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text(acceptingText),
                    onPressed: () {
                      accepted = true;
                      Navigator.of(context).pop();
                    }),
              ]);
        });
  } else {
    late final Widget leftWidget;
    if (destructive) {
      leftWidget = CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: () {
          accepted = true;
          Navigator.of(context).pop();
        },
        child: Text(acceptingText),
      );
    } else {
      leftWidget = CupertinoDialogAction(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(rejectingText),
      );
    }
    late final Widget rightWidget;
    if (destructive) {
      rightWidget = CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(rejectingText),
      );
    } else {
      rightWidget = CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          accepted = true;
          Navigator.of(context).pop();
        },
        child: Text(acceptingText),
      );
    }
    await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              leftWidget,
              rightWidget,
            ],
          );
        });
  }

  return accepted;
}

/// Shows dialogs to indicate errors.
Future<void> showErrorDialog(
    BuildContext context, String title, String content, String acceptingText,
    {Exception? exception, StackTrace? stackTrace}) async {
  final localizations = AppLocalizations.of(context)!;
  const platform = LocalPlatform();
  if (!platform.isIOS) {
    final actions = <Widget>[];
    if (isDevelopmentFlavor()) {
      actions.add(
        TextButton(
          onPressed: () {
            final text =
                '## exception\n\n$exception\n\n## stackTrace\n\n$stackTrace';
            Clipboard.setData(ClipboardData(text: text));
          },
          child: Text(localizations.copyException),
        ),
      );
    }
    actions.add(
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(acceptingText),
      ),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: content != '' ? Text(content) : null,
          actions: actions,
        );
      },
    );
  } else {
    final actions = <Widget>[];
    if (appFlavor == 'development') {
      actions.add(
        CupertinoDialogAction(
          onPressed: () {
            final text =
                '## Exception\n\n$exception\n\n## Stack trace\n\n$stackTrace';
            Clipboard.setData(ClipboardData(text: text));
          },
          child: Text(localizations.copyException),
        ),
      );
    }
    actions.add(
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(acceptingText),
      ),
    );

    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions,
        );
      },
    );
  }
}

Future<ArchiveNotFoundDialogResult> showArchiveNotFoundDialog(
    BuildContext context,
    {Exception? exception,
    StackTrace? stackTrace}) async {
  final localizations = AppLocalizations.of(context)!;
  final actions = <Widget>[];
  if (isDevelopmentFlavor()) {
    actions.add(
      TextButton(
        onPressed: () {
          final text =
              '## exception\n\n$exception\n\n## stackTrace\n\n$stackTrace';
          Clipboard.setData(ClipboardData(text: text));
        },
        child: Text(localizations.copyException),
      ),
    );
  }
  actions.addAll([
    TextButton(
      onPressed: () {
        Navigator.of(context)
            .pop(ArchiveNotFoundDialogResult.removeThisArchive);
      },
      child: Text(localizations.removeThisArchive),
    ),
    TextButton(
      onPressed: () {
        Navigator.of(context).pop(ArchiveNotFoundDialogResult.ok);
      },
      child: Text(localizations.ok),
    ),
  ]);

  final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.archiveNotFound),
          content:
              Text(localizations.cloudNotLoadArchiveMemoStoreFromLocalStorage),
          actions: actions,
        );
      });
  if (result == null) {
    return ArchiveNotFoundDialogResult.ok;
  }

  return result;
}

/// Shows dialogs with transition.
Future<T?> showTransitioningDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required DialogTransitionBuilder transitionBuilder,
  Curve curve = Curves.linear,
  Duration? duration,
  Alignment alignment = Alignment.center,
  bool barrierDismissible = false,
  Color? barrierColor,
  Axis? axis = Axis.horizontal,
}) {
  assert(debugCheckHasMaterialLocalizations(context));
  final ThemeData theme = Theme.of(context);
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        top: false,
        child: Builder(builder: (BuildContext context) {
          return Theme(data: theme, child: pageChild);
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: duration ?? const Duration(milliseconds: 400),
    transitionBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return transitionBuilder(animation, curve, alignment, child);
    },
  );
}

/// Views this memo.
Future<void> viewMemo(BuildContext context, Memo memo) async {
  if (!hasLargeScreen()) {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ViewingPage(memo: memo);
        },
      ),
    );
  } else {
    await showTransitioningDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Dialog(
            insetPadding: const EdgeInsets.all(0.0),
            child: ViewingPage(memo: memo, fullScreen: false),
          ),
        );
      },
      barrierDismissible: false,
      transitionBuilder: DialogTransitionBuilders.primary,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 500),
    );
  }
}

/// Creates a subtitle.
Container subtitle(BuildContext context, String text) {
  return Container(
    padding: const EdgeInsets.only(left: 10),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(text,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.start),
    ),
  );
}

/// Returns whether this device has a large screen.
bool hasLargeScreen() {
  const platform = LocalPlatform();
  if (platform.isDesktop) {
    return true;
  }
  if (platform.isMobile) {
    if (_size.width < 600 || _size.height < 600) {
      return false;
    }

    return true;
  }

  return false;
}

/// Returns whether this application is development flavor.
bool isDevelopmentFlavor() {
  const platform = LocalPlatform();
  if (platform.isMobile) {
    if (appFlavor == "development") {
      return true;
    }

    return false;
  }

  const flavor = String.fromEnvironment("FLAVOR");
  if (flavor == "development") {
    return true;
  }

  return false;
}

/// Returns contents of memo cards.
Widget memoCardContents(BuildContext context, Memo memo, bool unsynchronized) {
  final localizations = AppLocalizations.of(context)!;
  final attributeStyle = TsukimisouTextStyles.homePageMemoAttribute(context);
  final lastModified = DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
  final updated = lastModified.toSmartString();
  late final Widget memoContents;
  if (memo.viewingMode == 'TinyMarkdown') {
    memoContents = richTextContents(context, memo.text);
  } else {
    memoContents = Text(memo.text);
  }
  final contents = [
    memoContents,
    Align(
      alignment: Alignment.centerRight,
      child: Text(
        localizations.updated(updated),
        style: attributeStyle,
      ),
    ),
  ];
  if (unsynchronized) {
    contents.add(
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          localizations.unsynchronized,
          style: attributeStyle,
        ),
      ),
    );
  }
  final archiveName = memo.archiveName;
  if (archiveName != null) {

    print('archiveName: $archiveName');

    contents.add(
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          localizations.inArchive(archiveName),
          style: attributeStyle
        ),
      )
    );
  }

  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contents,
    ),
  );
}

/// Returns rich text contents.
Widget richTextContents(BuildContext context, String text,
    {MemoLinkCallback? onMemoLinkRequested}) {
  final parser =
      MarkdownParser(context, text, onMemoLinkRequested: onMemoLinkRequested);
  parser.execute();

  return parser.contents;
}

/// Returns a indicator used when there are no memmos.
Widget noMemosIndicator(BuildContext context, IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: TsukimisouColors.scheme.primary,
          size: 150.0,
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(
          text,
          style: TsukimisouTextStyles.noMemosIndicator(context),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
