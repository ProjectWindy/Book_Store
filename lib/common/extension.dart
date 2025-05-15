import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension StateExtension on State {
  void mdShowAlert(String title, String message, VoidCallback onPressed,
      {String buttonTitle = "Ok",
      TextAlign messageTextAlign = TextAlign.center}) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(
          message,
          textAlign: messageTextAlign,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(buttonTitle),
            onPressed: () {
              Navigator.pop(context);
              onPressed();
            },
          )
        ],
      ),
    );
  }

  // Safe wrapper for showDialog that uses root navigator
  Future<T?> showSafeDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  // Safe wrapper for showModalBottomSheet that uses root navigator
  Future<T?> showSafeBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      builder: builder,
    );
  }

  void endEditing() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

extension StringExtension on String {
  bool get isEmail {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}

// Extension for context to make dialog showing more convenient
extension ContextExtension on BuildContext {
  Future<T?> showSafeDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      useRootNavigator: true,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  Future<T?> showSafeBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      useRootNavigator: true,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      builder: builder,
    );
  }
}
