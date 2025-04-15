import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(BuildContext context, {String? message}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sind Sie sicher?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message, textAlign: TextAlign.center),
              )
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sind Sie sicher, dass Sie diese Aktion durchführen möchten?',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Bestätigen'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // Handle null return value
}
