import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/pocketbase.dart';
import '../components/shared/administration_login_modal.dart';
import '../components/shared/barcode_scanner_simple.dart';
import '../components/shared/student_qr_login_screen.dart';
import '../utils/dialogs/show_loading_dialog.dart';
import '../utils/logger.dart';
import '../utils/dialogs/show_error_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Z. E. Y. N.'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.code),
            onPressed: () {
              launchUrl(
                Uri.parse('https://github.com/SSA-GGMT/zeyn')
              );
            },
          )
        ]
        ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              Icon(Icons.login, size: 60),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [Icon(Icons.school), Text('Schüler Login')],
              ),
              ElevatedButton(
                onPressed: () async {
                  final token = await scanBarcode(context);
                  if (token == null || !context.mounted) return;
                  showLoadingDialog(context);
                  try {
                    final loginAuthRecord = StudentQrModel.fromLoginToken(token);
                    await pb
                        .collection('students')
                        .authWithPassword(
                      loginAuthRecord.email,
                      loginAuthRecord.password,
                    );
                  } catch (e, s) {
                    logger.e(e, stackTrace: s);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.qr_code),
                    Text('QR Code Scannen'),
                    Container(),
                  ],
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [Icon(Icons.person), Text('Lehrer Login')],
              ),
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte E-Mail eingeben';
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
                          showLoadingDialog(context, message: 'Bitte warten...');
                          try {
                            await pb
                                .collection('teachers')
                                .authWithPassword(
                              usernameController.text,
                              passwordController.text,
                            );
                            if (!pb.authStore.isValid) {
                              if (context.mounted) Navigator.of(context).pop();
                              showErrorDialog(
                                context,
                                message: 'Login fehlgeschlagen',
                              );
                              return;
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          } catch (e, stackTrace) {
                            if (context.mounted) Navigator.of(context).pop();
                            logger.e(e, stackTrace: stackTrace);
                            showErrorDialog(context);
                          }
                        }
                      },
                      child: Text('Login'),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Icon(Icons.privacy_tip),
                        Text('Datenschutz'),
                      ],
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse('https://ssa-ggmt.github.io/zeyn/'));
                    },
                  ),
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Icon(Icons.account_balance),
                        Text('Administration'),
                      ],
                    ),
                    onPressed: () {
                      showAdministrationLoginModal(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
