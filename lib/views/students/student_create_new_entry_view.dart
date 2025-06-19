import 'dart:convert';

import 'package:flutter/material.dart';
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
      "questionAnswer": jsonEncode(formData)
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
