import 'package:flutter/material.dart';

Future<void> showLoadingDialog(BuildContext context, {String? message}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: message != null ? Text(message) : null,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      );
    },
  );
}
