import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, {String? message}) {
  return showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Fehler'),
          Icon(Icons.error, color: Colors.red),
        ],
      ),
      children: [
        Center(
          child: ((message != null))
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(message),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Ein unbekannter Fehler ist aufgetreten.'),
                ),
        ),
      ],
    ),
  );
}
