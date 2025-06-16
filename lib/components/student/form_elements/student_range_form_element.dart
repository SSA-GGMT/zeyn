import 'package:flutter/material.dart';
import 'package:sportslogger/components/student/form_elements/form_result.dart';

class StudentRangeFormElement extends StatefulWidget {
  const StudentRangeFormElement({
    super.key,
    required this.questionIndex,
    required this.definition,
    required this.onResult,
    this.value,
  });

  final int questionIndex;
  final dynamic definition;
  /*
    definition example:
    {
        "type": "range",
        "label": "Taktik",
        "id": "tactics_eval",
        "min": 0,
        "min_color": "#00FF00",
        "max": 10,
        "max_color": "#FF0000",
        "step": 1,
        "initialValue": 0
    },
  */
  final FormResultCallback onResult;
  final String? value;

  @override
  State<StudentRangeFormElement> createState() => _StudentRangeFormElementState();
}

class _StudentRangeFormElementState extends State<StudentRangeFormElement> {
  late double rangeValue;
  late Color minColor;
  late Color maxColor;
  late int divisions;

  @override
  void initState() {
    super.initState();
    rangeValue = double.tryParse(widget.value ?? widget.definition['initialValue'].toString()) ?? 0.0;
    minColor = Color(int.parse(widget.definition['min_color'].replaceFirst('#', '0xFF')));
    maxColor = Color(int.parse(widget.definition['max_color'].replaceFirst('#', '0xFF')));
    divisions = ((widget.definition['max'] - widget.definition['min']) / widget.definition['step']).round();
  }

  /// Takes two colors and a value between 0 and 1, and returns a color that is
  /// a gradient between the two colors at the given position
  Color gradientColorAt(Color A, Color B, double t) {
    // Ensure t is between 0 and 1
    t = t.clamp(0.0, 1.0);

    // Calculate interpolated RGBA components
    int r = (A.r + (B.r - A.r) * t).round();
    int g = (A.g + (B.g - A.g) * t).round();
    int b = (A.b + (B.b - A.b) * t).round();
    int a = (A.a + (B.a - A.a) * t).round();

    // Return new color with interpolated values
    return Color.fromARGB(a, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.definition['label']),
          Slider(
            value: rangeValue,
            min: widget.definition['min'].toDouble(),
            max: widget.definition['max'].toDouble(),
            divisions: divisions,
            activeColor: gradientColorAt(minColor, maxColor, rangeValue/divisions +0.15),
            inactiveColor: gradientColorAt(minColor, maxColor, rangeValue/divisions -0.05),
            label: "${rangeValue.toInt()}/$divisions",
            onChanged: (double newValue) {
              setState(() {
                rangeValue = newValue;
              });
            },
            onChangeEnd: (double newValue) {
              widget.onResult(FormResult(
                questionIndex: widget.questionIndex,
                id: widget.definition['id'],
                value: newValue.toString(),
                hiddenFields: [],
              ));
            },
          ),
        ],
      ),
    );
  }
}