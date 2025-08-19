import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeyn/utils/dialogs/show_confirm_dialog.dart';

class FeedbackButton extends StatelessWidget {
  final String urlSubPath;
  const FeedbackButton({super.key, required this.urlSubPath});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final Uri url = Uri.parse(
          'https://zeyn.umfrage.meinschulamt-ruesselsheim.de/$urlSubPath',
        );
        final result = await showConfirmDialog(
          context,
          message:
              'Sie werden auf die Feedback-Seite weitergeleitet. Möchten Sie fortfahren?',
        );
        if (result) launchUrl(url);
      },
      icon: const Icon(Icons.feedback),
    );
  }
}
