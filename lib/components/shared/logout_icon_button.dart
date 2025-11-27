import 'package:flutter/material.dart';
import 'package:zeyn/api/pocketbase.dart';

class LogoutIconButton extends StatelessWidget {
  final Color? iconColor;
  const LogoutIconButton({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout, color: iconColor),
      tooltip: 'Ausloggen',
      onPressed: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
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
        }
      },
    );
  }
}
