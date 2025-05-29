import 'package:flutter/material.dart';
import 'package:sportslogger/components/student/form_elements/student_range_form_element.dart';
import 'package:sportslogger/components/student/form_elements/student_select_form_element.dart';

import '../../utils/logger.dart';
import 'form_elements/form_result.dart';
import 'form_elements/student_radio_form_element.dart';

class ChainedFormsBuilder extends StatefulWidget {
  const ChainedFormsBuilder({super.key, required this.form});
  final List<dynamic> form;

  @override
  State<ChainedFormsBuilder> createState() => _ChainedFormsBuilderState();
}

class _ChainedFormsBuilderState extends State<ChainedFormsBuilder> {
  List<FormResult> results = [];

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
      } else if (existingResult.value == null) {
        // Skip other unanswered questions
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
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: getFormWidgets(),
    );
  }
}
