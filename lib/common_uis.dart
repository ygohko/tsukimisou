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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

import 'extensions.dart';

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

/// Initializes this library.
void init(BuildContext context) {
  _size = MediaQuery.of(context).size;
}

/// Shows dialogs to indicate progressing.
void showProgressIndicatorDialog(BuildContext context) {
  final platform = LocalPlatform();
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
  final platform = LocalPlatform();
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
  final platform = LocalPlatform();
  if (!platform.isIOS) {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(content),
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




class TestTransition extends AnimatedWidget {
  final Alignment alignment;
  final Widget child;

  TestTransition({Key? key, required Animation<double> scales, this.alignment = Alignment.center, required this.child}) : super(key: key, listenable: scales);

  Animation<double> get scales => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final scale = (1.0 - scales.value) * -0.2 + 1.0;
    final transform = Matrix4.diagonal3Values(scale, scale, scale);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}






Future<T?> showTransitiningDialog<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,
  // required AnimatedWidget transition,
  Curve curve = Curves.linear,
  Duration? duration,
  Alignment alignment = Alignment.center,
  bool barrierDismissible = false,
  Color? barrierColor,
  Axis? axis = Axis.horizontal,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final ThemeData theme = Theme.of(context);




  // TODO: Is this needed?
  // isShowing = true;


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


        return TestTransition(
          scales: animation,
          /*
          CurvedAnimation(
            parent: animation,
            curve: Interval(
              0.0,
              0.5,
              curve: curve,
            ),
          ),
          */
          alignment: alignment,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

        /*
        return ScaleTransition(
          alignment: alignment,
          scale: CurvedAnimation(
            parent: animation,
            curve: Interval(
              0.0,
              0.5,
              curve: curve,
            ),
          ),
          child: child,
        );
        */


    },
  );
}


      /*
      switch (animationType) {
        case DialogTransitionType.fade:
          return FadeTransition(opacity: animation, child: child);
        case DialogTransitionType.slideFromRight:
          return SlideTransition(
            transformHitTests: false,
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          );
        case DialogTransitionType.slideFromLeft:
          return SlideTransition(
            transformHitTests: false,
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          );
        case DialogTransitionType.slideFromRightFade:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        case DialogTransitionType.slideFromLeftFade:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        case DialogTransitionType.slideFromTop:
          return SlideTransition(
            transformHitTests: false,
            position: Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          );
        case DialogTransitionType.slideFromTopFade:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        case DialogTransitionType.slideFromBottom:
          return SlideTransition(
            transformHitTests: false,
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          );
        case DialogTransitionType.slideFromBottomFade:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        case DialogTransitionType.scale:
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
        case DialogTransitionType.fadeScale:
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
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: child,
            ),
          );
        case DialogTransitionType.scaleRotate:
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
            child: CustomRotationTransition(
              alignment: alignment,
              turns: Tween<double>(begin: 1, end: 2).animate(CurvedAnimation(
                  parent: animation, curve: Interval(0.0, 1.0, curve: curve))),
              child: child,
            ),
          );
        case DialogTransitionType.rotate:
          return CustomRotationTransition(
            alignment: alignment,
            turns: Tween<double>(begin: 1, end: 2).animate(CurvedAnimation(
                parent: animation, curve: Interval(0.0, 1.0, curve: curve))),
            child: child,
          );
        case DialogTransitionType.fadeRotate:
          return CustomRotationTransition(
            alignment: alignment,
            turns: Tween<double>(begin: 1, end: 2).animate(CurvedAnimation(
                parent: animation, curve: Interval(0.0, 1.0, curve: curve))),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: child,
            ),
          );
        case DialogTransitionType.rotate3D:
          return Rotation3DTransition(
            alignment: alignment,
            turns: Tween<double>(begin: math.pi, end: 2.0 * math.pi).animate(
                CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.0, 1.0, curve: curve))),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: animation,
                      curve: Interval(0.5, 1.0, curve: Curves.elasticOut))),
              child: child,
            ),
          );
        case DialogTransitionType.size:
          return Align(
            alignment: alignment,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              axis: axis ?? Axis.vertical,
              child: child,
            ),
          );
        case DialogTransitionType.sizeFade:
          return Align(
            alignment: alignment,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: curve,
                ),
                child: child,
              ),
            ),
          );
        case DialogTransitionType.none:
          return child;
        default:
          return FadeTransition(opacity: animation, child: child);
      }
      */




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

/*
/// Creates a scale transition.
AnimatedWidget scaleTransition() {
  return  ScaleTransition(
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
*/

/// Returns whether this device has a large screen.
bool hasLargeScreen() {
  final platform = LocalPlatform();
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
