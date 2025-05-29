import 'package:flutter/material.dart';
import 'package:sportslogger/components/student/form_elements/form_result.dart';

class StudentRadioFormElement extends StatelessWidget {
  const StudentRadioFormElement({
    super.key,
    required this.questionIndex,
    required this.definition,
    required this.onResult,
    this.value,
  });

  final int questionIndex;
  final dynamic definition;
  /*
    definition:
     {
        "type": "radio",
        "label": "Anwesenheit",
        "id": "attendance",
        "options": [
            {
                "label": "Anwesend",
                "hideFields": [],
                "hint": null
            },
            {
                "label": "Verletzung/Krankheit",
                "hideFields": ["games_count", "tactics_eval", "technique_eval", "fitness_condition_eval"],
                "hint": null
            },
            {
                "label": "Entfallen",
                "hideFields": ["games_count", "tactics_eval", "technique_eval", "fitness_condition_eval"],
                "hint": null
            },
            {
                "label": "Beurlaubt",
                "hideFields": ["games_count", "tactics_eval", "technique_eval", "fitness_condition_eval"],
                "hint": null
            },
            {
                "label": "Sonstiges",
                "hideFields": ["games_count", "tactics_eval", "technique_eval", "fitness_condition_eval"],
                "hint": "Arztbesuch, Schulveranstaltung, Freistellung, Ferien, etc."
            }
        ]
    },
     */
  final FormResultCallback onResult;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(definition['label']),
          Column(
            children: (definition['options'] as List<dynamic>)
                .map<Widget>((option) {
              return RadioListTile<String>(
                value: option['label'],
                groupValue: value,
                title: Text("${option['label']}${option['hint'] != null ? " (${option['hint']})" : ""}"),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final selectedOption = definition['options']
                        .firstWhere((opt) => opt['label'] == newValue);
                    final hiddenFields = (selectedOption['hideFields'] as List<dynamic>)
                        .map((e) => e as String)
                        .toList();
                    onResult(FormResult(
                      questionIndex: questionIndex,
                      id: definition['id'],
                      value: newValue,
                      hiddenFields: hiddenFields,
                    ));
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );

  }
}