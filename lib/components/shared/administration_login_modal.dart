import 'package:flutter/material.dart';

import '../../api/pocketbase.dart';
import '../../utils/dialogs/show_error_dialog.dart';
import '../../utils/dialogs/show_loading_dialog.dart';
import '../../utils/logger.dart';

void showAdministrationLoginModal(BuildContext context) {
  final schoolNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Icon(Icons.admin_panel_settings, size: 60),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 8,
                  children: [Icon(Icons.person), Text('Administrations Login')],
                ),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: schoolNumberController,
                        decoration: InputDecoration(labelText: 'Schulnummer'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Schulnummer eingeben';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Passwort'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Passwort eingeben';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            showLoadingDialog(
                              context,
                              message: 'Bitte warten...',
                            );
                            try {
                              await pb
                                  .collection('schools')
                                  .authWithPassword(
                                    '${schoolNumberController.text}@schule.null',
                                    passwordController.text,
                                  );
                              if (!pb.authStore.isValid) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  showErrorDialog(
                                    context,
                                    message: 'Login fehlgeschlagen',
                                  );
                                }
                                return;
                              }
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
                            } catch (e, stackTrace) {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                logger.e(e, stackTrace: stackTrace);
                                showErrorDialog(context);
                              }
                            }
                          }
                        },
                        child: Text('Login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}
