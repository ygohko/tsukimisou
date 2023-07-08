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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:platform/platform.dart';

import 'extensions.dart';
import 'memo.dart';
import 'viewing_page.dart';

typedef DialogTransitionBuilder = AnimatedWidget Function(
    Animation<double> animation,
    Curve curve,
    Alignment alignment,
    Widget child);

late Size _size;

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
    background: const Color(0xFFF7F7FF),
  );
}

class TsukimisouTextStyles {
  /// Text style for memo attributes on home page.
  static TextStyle homePageMemoAttribute(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyText2;
    if (style == null) {
      style = const TextStyle();
    }
    style = style.apply(color: Colors.black.withOpacity(0.6));

    return style;
  }

  /// Text style for drawer footer on home page.
  static TextStyle homePageDrawerFooter(BuildContext context) {
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
      style = const TextStyle();
    }
    style = style.apply(fontSizeFactor: 1.1);

    return style;
  }

  /// Text style for memo attributes on vieweing page.
  static TextStyle viewingPageMemoAttribute(BuildContext context) {
    var style = Theme.of(context).textTheme.subtitle1;
    if (style == null) {
      style = const TextStyle();
    }
    style = style.apply(color: Colors.black.withOpacity(0.6));

    return style;
  }

  /// Text style for text field on editing page.
  static TextStyle editingPageTextField(BuildContext context) {
    var style = Theme.of(context).textTheme.bodyText2;
    if (style == null) {
      style = const TextStyle();
    }
    style = style.apply(
      fontSizeFactor: 1.1,
    );

    return style;
  }
}

class DialogTransitionBuilders {
  /// Primary dialog transition.
  static final primary = (Animation<double> animation, Curve curve,
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
  };

  /// Transition for editing dialog.
  static final editing = (Animation<double> animation, Curve curve,
      Alignment alignment, Widget child) {
    return SlideTransition(
      transformHitTests: false,
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve)).animate(animation),
      child: child,
    );
  };

  /// Transition when showing dialogs from other dialog.
  static final dialogToDialog = (Animation<double> animation, Curve curve,
      Alignment alignment, Widget child) {
    return DialogToDialogTransition(
      phase: animation,
      alignment: alignment,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  };
}

class DialogToDialogTransition extends AnimatedWidget {
  final Alignment alignment;
  final Widget child;

  /// Creates a dialog to dialog transition.
  DialogToDialogTransition(
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
Future<void> showErrorDialog(BuildContext context, String title, String content,
    String acceptingText) async {
  const platform = LocalPlatform();
  if (!platform.isIOS) {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: content != '' ? Text(content) : null,
              actions: [
                TextButton(
                    child: Text(acceptingText),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]);
        });
  } else {
    await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(acceptingText),
              ),
            ],
          );
        });
  }
}

/// Shows dialogs with transition.
Future<T?> showTransitiningDialog<T>({
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
    await showTransitiningDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Dialog(
            child: ViewingPage(memo: memo, fullScreen: false),
            insetPadding: const EdgeInsets.all(0.0),
          ),
        );
      },
      barrierDismissible: false,
      transitionBuilder: DialogTransitionBuilders.primary,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
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
          style: Theme.of(context).textTheme.caption,
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

/// Returns contents of memo cards.
Widget memoCardContents(BuildContext context, Memo memo, bool unsynchronized) {
  final localizations = AppLocalizations.of(context)!;
  final attributeStyle = TsukimisouTextStyles.homePageMemoAttribute(context);
  final lastModified = DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
  final updated = lastModified.toSmartString();
  final contents = [
    Text(memo.text),
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

  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contents,
    ),
  );
}
