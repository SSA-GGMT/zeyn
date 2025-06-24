import 'package:flutter/material.dart';
import 'package:zeyn/utils/dialogs/show_error_dialog.dart';

import '../../api/pocketbase.dart';
import '../../utils/dialogs/show_loading_dialog.dart';

class AdminAddTeacherView extends StatefulWidget {
  const AdminAddTeacherView({super.key});

  @override
  State<AdminAddTeacherView> createState() => _AdminAddTeacherViewState();
}

class _AdminAddTeacherViewState extends State<AdminAddTeacherView> {
  static const padding = 8.0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _krzController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showPassword = false;
  final TextEditingController _passwordController2 = TextEditingController();
  bool showPassword2 = false;

  void addTeacher() async {
    showLoadingDialog(context, message: 'Lehrer wird hinzugefügt...');
    final body = <String, dynamic>{
      "password": _passwordController.text,
      "passwordConfirm": _passwordController2.text,
      "email": _emailController.text,
      "emailVisibility": true,
      "school": pb.authStore.record!.id,
      "krz": _krzController.text.toUpperCase(),
      "firstName": _firstNameController.text,
      "secondName": _secondNameController.text,
    };

    try {
      await pb.collection('teachers').create(body: body);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lehrer erfolgreich hinzugefügt!')),
      );
    } catch (e) {
      showErrorDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lehrer hinzufügen')),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Vorname',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie den Vornamen ein.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _secondNameController,
                decoration: const InputDecoration(
                  labelText: 'Nachname',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie den Nachnamen ein.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _krzController,
                decoration: const InputDecoration(
                  labelText: 'KRZ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie das KRZ ein.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie die E-Mail-Adresse ein.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed:
                        () => setState(() {
                          showPassword = !showPassword;
                        }),
                    icon: Icon(
                      !showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: !showPassword,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  bool hasNumber = RegExp(r'\d').hasMatch(value ?? '');
                  bool hasSpecialCharacter = RegExp(
                    r'[!@#$%^&*(),.?":{}|<>]',
                  ).hasMatch(value ?? '');
                  if (value == null ||
                      value.isEmpty ||
                      value.length < 8 ||
                      !hasNumber ||
                      !hasSpecialCharacter) {
                    return 'Bitte geben sie ein Passwort ein. (mind. 8 Zeichen, 1 Zahl, 1 Sonderzeichen)';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _passwordController2,
                decoration: InputDecoration(
                  labelText: 'Passwort wiederholen',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed:
                        () => setState(() {
                          showPassword2 = !showPassword2;
                        }),
                    icon: Icon(
                      !showPassword2 ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: !showPassword2,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  if (_passwordController.text != _passwordController2.text) {
                    return 'Die Passwörter müssen übereinstimmen.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Handle form submission
                    addTeacher();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8.0,
                  children: const [
                    Icon(Icons.person_add),
                    Text('Lehrer hinzufügen'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
