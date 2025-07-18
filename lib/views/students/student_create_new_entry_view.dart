import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeyn/components/student/form_elements/student_range_form_element.dart';
import 'package:zeyn/components/student/form_elements/student_select_form_element.dart';

import '../../api/pocketbase.dart';
import '../../components/student/form_elements/form_result.dart';
import '../../components/student/form_elements/student_radio_form_element.dart';
import '../../utils/dialogs/show_error_dialog.dart';
import '../../utils/dialogs/show_loading_dialog.dart';
import '../../utils/logger.dart';


typedef FormDataCallback = Future<void> Function(Map<String, String> result);

class StudentCreateNewEntryView extends StatefulWidget {
  const StudentCreateNewEntryView({super.key, required this.form});
  final List<dynamic> form;

  @override
  State<StudentCreateNewEntryView> createState() => _StudentCreateNewEntryViewState();
}

class _StudentCreateNewEntryViewState extends State<StudentCreateNewEntryView> {
  List<FormResult> results = [];
  DateTime createdAt = DateTime.now();

  bool isFormComplete = false;

  Widget typeWidget({
    required String type,
    required int questionIndex,
    required dynamic definition,
    required FormResultCallback onResult,
    String? value,
  }) {
    if (type == "select") {
      return StudentSelectFormElement(questionIndex: questionIndex, definition: definition, onResult: onResult, value: value,);
    } else if (type == "radio") {
      return StudentRadioFormElement(questionIndex: questionIndex, definition: definition, onResult: onResult, value: value,);
    } else if (type == "range") {
      return StudentRangeFormElement(questionIndex: questionIndex, definition: definition, onResult: onResult);
    }
    return Placeholder();
  }

  Widget createdAtPicker() {
    final DateFormat day = DateFormat('dd.MM.yyyy');
    final DateFormat time = DateFormat('HH:mm');

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              spacing: 4.0,
              children: [
                Icon(Icons.calendar_today),
                Text(day.format(createdAt), style: Theme.of(context).textTheme.headlineMedium,)
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              spacing: 4.0,
              children: [
                Text(time.format(createdAt), style: Theme.of(context).textTheme.headlineMedium,),
                Icon(Icons.access_time),
              ],
            ),
          ),
        ],
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: createdAt,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null && mounted) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(createdAt),
          );
          if (pickedTime != null && mounted) {
            final newDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            if (newDateTime.isBefore(DateTime.now()) || newDateTime.isAtSameMomentAs(DateTime.now())) {
              setState(() {
                createdAt = newDateTime;
              });
            }
          }
        }
      },
    );
  }

  List<Widget> getFormWidgets() {
    logger.d('Results: $results');
    List forbiddenFields = results.expand((e) => e.hiddenFields).toList();
    List<Widget> widgets = [];
    bool foundUnanswered = false;

    for (int i = 0; i < widget.form.length; i++) {
      final formElement = widget.form[i];
      if (forbiddenFields.contains(formElement['id'])) continue;

      // Check if the question is already answered
      final existingResult = results.firstWhere(
            (e) => e.id == formElement['id'],
        orElse: () => FormResult.empty(),
      );

      if (existingResult.value == null && !foundUnanswered) {
        // Append the next unanswered question
        foundUnanswered = true;
        isFormComplete = false;
      } else if (existingResult.value == null) {
        // Skip other unanswered questions
        isFormComplete = false;
        continue;
      }

      List<FormResult> localResultsCopy = List.from(results);
      localResultsCopy.removeWhere((element) => element.questionIndex >= i);

      widgets.add(
        typeWidget(
          type: formElement['type'],
          questionIndex: i,
          definition: formElement,
          onResult: (result) {
            setState(() {
              results = [...localResultsCopy, result];
            });
          },
          value: existingResult.value,
        ),
      );
    }
    isFormComplete = !foundUnanswered && results.length == widgets.length;
    return widgets;
  }

  Map<String, String> collectFormData() {
    Map<String, String> formData = {};
    for (var result in results) {
      formData[result.id] = result.value ?? '';
    }
    return formData;
  }

  void postEntry() async {
    showLoadingDialog(context, message: 'Schüler wird hinzugefügt...');
    final formData = collectFormData();

    final body = <String, dynamic>{
      "student": pb.authStore.record?.id,
      "course": pb.authStore.record?.data['course'],
      "school": pb.authStore.record?.data['school'],
      "questionAnswer": jsonEncode(formData),
      "created_at": createdAt.toUtc().toIso8601String(),
    };


    try {
      final recordModel = await pb.collection('studentRecords').create(body: body);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(recordModel);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eintrag erstellt!')),
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
      appBar: AppBar(
        title: Text("Neuer Eintrag"),
      ),
        body: ListView(
          children: [
            createdAtPicker(),
            Divider(),
            ...getFormWidgets(),
            if (isFormComplete) Padding(
              padding: EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: postEntry,
                child: Text("Eintrag speichern"),
              ),
            )
          ],
        )
    );
  }
}
