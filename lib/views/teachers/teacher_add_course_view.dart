import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/components/teacher/sports_selector.dart';
import 'package:zeyn/utils/dialogs/show_error_dialog.dart';

import '../../api/pocketbase.dart';
import '../../utils/dialogs/show_loading_dialog.dart';

class TeacherAddCourseView extends StatefulWidget {
  const TeacherAddCourseView({super.key});

  @override
  State<TeacherAddCourseView> createState() => _TeacherAddCourseViewState();
}

class _TeacherAddCourseViewState extends State<TeacherAddCourseView> {
  static const padding = 8.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _courseNameController = TextEditingController();
  RecordModel? selectedSport;

  void addCourse() async {
    showLoadingDialog(context, message: 'Lehrer wird hinzugefügt...');
    final body = <String, dynamic>{
      "courseTitle": _courseNameController.text,
      "school": pb.authStore.record?.data['school'],
      "manager": pb.authStore.record?.id,
      "guestManagers": [],
      "sport": selectedSport!.id,
    };

    try {
      await pb.collection('courses').create(body: body);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kurs erfolgreich hinzugefügt!')),
        );
      }
    } catch (e, s) {
      if (mounted) {
        Navigator.of(context).pop();
        showErrorDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kurs erstellen')),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Kursname',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie den Kursnamen ein.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: SportsSelector(
                onSelected: (RecordModel selectedSport) {
                  setState(() {
                    this.selectedSport = selectedSport;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: ElevatedButton(
                onPressed:
                    selectedSport != null
                        ? () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Handle form submission
                            addCourse();
                          }
                        }
                        : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8.0,
                  children: const [Icon(Icons.add), Text('Kurs hinzufügen')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
