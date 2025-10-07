import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/utils/dialogs/show_error_dialog.dart';
import 'package:zeyn/utils/password_generator.dart';

import '../../api/pocketbase.dart';
import '../../utils/dialogs/show_loading_dialog.dart';
import '../../utils/logger.dart';

class TeacherAddStudentToCourseView extends StatefulWidget {
  const TeacherAddStudentToCourseView({super.key, required this.courseData});
  final RecordModel courseData;

  @override
  State<TeacherAddStudentToCourseView> createState() =>
      _TeacherAddStudentToCourseViewState();
}

class _TeacherAddStudentToCourseViewState
    extends State<TeacherAddStudentToCourseView> {
  static const padding = 8.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  String kaderStatus = 'TSP';
  String sex = 'Männlich';
  int birthYear = DateTime.now().year - 14;

  void addStudent() async {
    showLoadingDialog(context, message: 'Schüler wird hinzugefügt...');
    final password = passwordGenerator(length: 70);
    final int unixTime = DateTime.now().millisecondsSinceEpoch;
    final fictionalMail =
        '${pb.authStore.record?.data['school']}.${widget.courseData.id}.$unixTime@schule.null';
    final body = <String, dynamic>{
      "courseTitle": _firstNameController.text,
      "school": pb.authStore.record?.data['school'],
      "createdByTeacher": pb.authStore.record?.id,
      "course": widget.courseData.id,
      "firstName": _firstNameController.text,
      "secondName": _secondNameController.text,
      "password": password,
      "passwordConfirm": password,
      "clearTextPassword": password,
      "emailVisibility": true,
      "verified": true,
      "email": fictionalMail,
      "kaderStatus": kaderStatus,
      "sex": sex,
      "birthYear": birthYear,
    };

    try {
      final recordModel = await pb.collection('students').create(body: body);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(recordModel);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schüler erfolgreich hinzugefügt!')),
        );
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
      appBar: AppBar(title: const Text('Schüler erstellen')),
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
                    return 'Bitte geben Sie den Nachname ein.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownMenu<String>(
                label: Text('Kaderstatus'),
                width: double.infinity,
                initialSelection: 'TSP',
                onSelected: (String? value) {
                  setState(() {
                    kaderStatus = value!;
                  });
                },
                dropdownMenuEntries: ['TSP', 'NK1', 'NK2', 'LK', 'PK', 'OK']
                    .map(
                      (String value) => DropdownMenuEntry<String>(
                        value: value,
                        label: value,
                      ),
                    ).toList(),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownMenu<String>(
                label: Text('Geschlecht'),
                width: double.infinity,
                initialSelection: 'Männlich',
                onSelected: (String? value) {
                  setState(() {
                    sex = value!;
                  });
                },
                dropdownMenuEntries: ['Männlich', 'Weiblich', 'Divers']
                    .map(
                      (String value) => DropdownMenuEntry<String>(
                        value: value,
                        label: value,
                      ),
                    ).toList(),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownMenu<int>(
                label: Text('Geburtsjahr'),
                width: double.infinity,
                initialSelection: birthYear,
                onSelected: (int? value) {
                  setState(() {
                    birthYear = value!;
                  });
                },
                dropdownMenuEntries: List<DropdownMenuEntry<int>>.generate(
                  50,
                  (int index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuEntry<int>(
                      value: year,
                      label: year.toString(),
                    );
                  },
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    addStudent();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8.0,
                  children: const [Icon(Icons.add), Text('Schüler erstellen')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
