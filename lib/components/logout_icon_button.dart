import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:zeyn/api/pocketbase.dart';

class LogoutIconButton extends StatelessWidget {
  const LogoutIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Ausloggen',
      onPressed: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Ausloggen?'),
                content: const Text(
                  'Bist du sicher, dass du dich abmelden möchtest?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Abbruch'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Abmelden'),
                  ),
                ],
              ),
        );

        if (shouldLogout == true) {
          pb.authStore.clear();
          if (context.mounted) Phoenix.rebirth(context);
        }
      },
    );
  }
}
