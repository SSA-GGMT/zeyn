import 'package:flutter/material.dart';
import 'package:zeyn/api/pocketbase.dart';
import 'package:zeyn/utils/created_at_picker.dart';
import 'package:zeyn/utils/dialogs/show_error_dialog.dart';
import 'package:zeyn/utils/dialogs/show_loading_dialog.dart';
import 'package:zeyn/utils/logger.dart';

class CreateBookHistoryEventView extends StatefulWidget {
  final String courseId;
  const CreateBookHistoryEventView({super.key, required this.courseId});

  @override
  State<CreateBookHistoryEventView> createState() =>
      _CreateBookHistoryEventViewState();
}

class _CreateBookHistoryEventViewState
    extends State<CreateBookHistoryEventView> {
  static const padding = 8.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int studentCount = 0;
  final TextEditingController _notesController = TextEditingController();
  DateTime created = DateTime.now();

  void addEntry() async {
    showLoadingDialog(context, message: 'Eintrag wird hinzugefügt...');
    final body = <String, dynamic>{
      "course": widget.courseId,
      "student_count": studentCount,
      "createdBy": pb.authStore.record!.id,
      "notes": _notesController.text,
    };

    try {
      final recordModel = await pb
          .collection('courseHistoryRecords')
          .create(body: body);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(recordModel);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eintrag erfolgreich hinzugefügt!')),
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
      appBar: AppBar(title: const Text('Eintrag erstellen')),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(padding),
              child: CreatedAtPicker(
                initialDateTime: created,
                onChanged: (value) {
                  setState(() {
                    created = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                initialValue: studentCount.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Anzahl der Schüler',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    studentCount = int.tryParse(value) ?? 0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Anzahl der Schüler eingeben';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Bitte eine gültige Zahl eingeben';
                  }
                  if (int.parse(value) < 0) {
                    return 'Die Anzahl der Schüler kann nicht negativ sein';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: TextFormField(
                controller: _notesController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Notizen (Optional)',
                  hint: Text('Für Schüler sichtbar'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    addEntry();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8.0,
                  children: const [Icon(Icons.add), Text('Eintrag erstellen')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
