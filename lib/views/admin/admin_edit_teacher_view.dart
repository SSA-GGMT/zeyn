import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/utils/dialogs/show_confirm_dialog.dart';
import 'package:zeyn/utils/dialogs/show_error_dialog.dart';
import '../../utils/dialogs/show_loading_dialog.dart';
import '../../utils/logger.dart';

import '../../api/pocketbase.dart';

class AdminEditTeacherView extends StatefulWidget {
  const AdminEditTeacherView({super.key, required this.initialData});

  final RecordModel initialData;

  @override
  State<AdminEditTeacherView> createState() => _AdminEditTeacherViewState();
}

class _AdminEditTeacherViewState extends State<AdminEditTeacherView> {
  static const padding = 8.0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _krzController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool editPassword = false;
  final TextEditingController _passwordController = TextEditingController();
  bool showPassword = false;
  final TextEditingController _passwordController2 = TextEditingController();
  bool showPassword2 = false;

  @override
  void initState() {
    _firstNameController.text = widget.initialData.data['firstName'];
    _secondNameController.text = widget.initialData.data['secondName'];
    _krzController.text = widget.initialData.data['krz'];
    _emailController.text = widget.initialData.data['email'];
    super.initState();
  }

  void updateTeacher() async {
    showLoadingDialog(context, message: 'Änderungen vorgenommen...');
    final body = <String, dynamic>{
      if (editPassword) ...{
        "password": _passwordController.text,
        "passwordConfirm": _passwordController2.text,
      },
      "email": _emailController.text,
      "emailVisibility": true,
      "school": pb.authStore.record!.id,
      "krz": _krzController.text,
      "firstName": _firstNameController.text,
      "secondName": _secondNameController.text,
    };

    try {
      await pb.collection('teachers').update(widget.initialData.id, body: body);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Änderungen vorgenommen!')));
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (mounted) {
        Navigator.of(context).pop();
        showErrorDialog(context);
      }
    }
  }

  void deleteTeacher() async {
    if (!(await showConfirmDialog(
      context,
      message: 'Willst du diesen Lehrer wirklich löschen?',
    )))
      return;
    showLoadingDialog(context, message: 'Lehrer wird gelöscht...');
    try {
      await pb.collection('teachers').delete(widget.initialData.id);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Änderungen vorgenommen!')));
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (mounted) {
        Navigator.of(context).pop();
        showErrorDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.initialData.data['krz'].toString().toUpperCase()}, ${widget.initialData.data['secondName']}',
        ),
        actions: [
          IconButton(onPressed: deleteTeacher, icon: Icon(Icons.delete)),
        ],
      ),
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
            SwitchListTile(
              value: editPassword,
              title: Text('Passwort ändern'),
              onChanged:
                  (newVal) => setState(() {
                    editPassword = newVal;
                  }),
            ),
            if (editPassword) ...[
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
                        !showPassword2
                            ? Icons.visibility
                            : Icons.visibility_off,
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
            ],
            Padding(
              padding: const EdgeInsets.all(padding),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Handle form submission
                    updateTeacher();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8.0,
                  children: const [
                    Icon(Icons.save_as),
                    Text('Änderungen speichern'),
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
