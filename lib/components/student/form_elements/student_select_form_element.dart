import 'package:flutter/material.dart';
import 'package:zeyn/components/student/form_elements/form_result.dart';

class StudentSelectFormElement extends StatelessWidget {
  const StudentSelectFormElement({
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
        "type": "select",
        "label": "Aktivität",
        "id": "activity",
        "options": [
            {
                "label": "TFG",
                "hideFields": ["games_count"],
                "hint": "TFG = Talentfördergruppe"
            },
            {
                "label": "LG",
                "hideFields": ["games_count"],
                "hint": "LG = Leistungsgruppe"
            },
            {
                "label": "Blockunterricht",
                "hideFields": ["games_count"],
                "hint": null
            },
          ],
        }
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
          DropdownButtonFormField<String>(
            value: value,
            items:
                (definition['options'] as List<dynamic>).map<
                  DropdownMenuItem<String>
                >((option) {
                  return DropdownMenuItem<String>(
                    value: option['label'],
                    child: Text(
                      "${option['label']}${option['hint'] != null ? " (${option['hint']})" : ""}",
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                final selectedOption = definition['options'].firstWhere(
                  (option) => option['label'] == newValue,
                );
                final hiddenFields =
                    (selectedOption['hideFields'] as List<dynamic>)
                        .map((e) => e as String)
                        .toList();
                onResult(
                  FormResult(
                    questionIndex: questionIndex,
                    id: definition['id'],
                    value: newValue,
                    hiddenFields: hiddenFields,
                  ),
                );
              }
            },
            decoration: InputDecoration(
              hintText: definition['hint'],
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
