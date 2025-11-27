import 'dart:core';

import 'package:flutter/material.dart';

/// Takes two colors and a value between 0 and 1, and returns a color that is
/// a gradient between the two colors at the given position
Color gradientColorAt(Color A, Color B, double t) {
  // Ensure t is between 0 and 1
  t = t.clamp(0.0, 1.0);

  // Calculate interpolated RGBA components
  int r = (A.red + (B.red - A.red) * t).round();
  int g = (A.green + (B.green - A.green) * t).round();
  int b = (A.blue + (B.blue - A.blue) * t).round();
  int a = (A.alpha + (B.alpha - A.alpha) * t).round();

  // Return new color with interpolated values
  return Color.fromARGB(a, r, g, b);
}

enum ConditionGeneratorHistoryType { last5days, lastday }

class ConditionGenerator {
  bool containsAny(Iterable keys, Iterable values) {
    for (var value in values) {
      if (keys.contains(value)) return true;
    }
    return false;
  }

  static List<ConditionColor> generateConditionColors({
    List<Map> studentRecords = const [],
    List<String> evalFields = const [],
    ConditionGeneratorHistoryType historyType =
        ConditionGeneratorHistoryType.last5days,
  }) {
    var result = <ConditionColor>[];

    for (var evalField in evalFields) {
      if (historyType == ConditionGeneratorHistoryType.lastday) {
        // For last day, only consider records from the last 24 hours
        List<dynamic> lastDayRecords = [];

        for (var record in studentRecords) {
          final DateTime createdDate = DateTime.parse(record['created']);
          final hoursDifference = DateTime.now()
              .difference(createdDate)
              .inHours;
          if (hoursDifference <= 24 && record.keys.contains(evalField)) {
            lastDayRecords.add(record);
          }
        }

        // Create a single collection for the last day with maximum weight
        DayCollection lastDayCollection = DayCollection(0, 10, lastDayRecords);

        result.add(
          ConditionColor(lastDayCollection.getAvgColor(evalField), evalField),
        );
      } else {
        // Original last5days logic
        List<DayCollection> evalFiltered = [
          DayCollection(0, 8, []),
          DayCollection(1, 7, []),
          DayCollection(2, 6, []),
          DayCollection(3, 2, []),
          DayCollection(4, 1, []),
        ];

        for (var record in studentRecords) {
          final DateTime createdDate = DateTime.parse(record['created']);
          final daysAgo = DateTime.now().difference(createdDate).inDays;
          if (daysAgo < 5 && record.keys.contains(evalField)) {
            evalFiltered[daysAgo].studentRecords.add(record);
          }
        }

        result.add(
          ConditionColor(
            _mixColor(
              evalFiltered
                  .map(
                    (dayCollection) => ColorPart(
                      dayCollection.getAvgColor(evalField),
                      dayCollection.weight,
                    ),
                  )
                  .toList(),
            ),
            evalField,
          ),
        );
      }
    }

    return result;
  }
}

class ColorPart {
  final Color color;

  final int weight;

  ColorPart(this.color, this.weight);
}

class DayCollection {
  final int daysAgo;
  final int weight;
  List<dynamic> studentRecords;
  int get count => studentRecords.length;
  Color getAvgColor(String evalField) {
    List<Color> colors = [];
    for (var record in studentRecords) {
      if (record.containsKey(evalField)) {
        final colorStr = record[evalField];
        final double? colorValue = double.tryParse(colorStr.toString());
        colors.add(
          gradientColorAt(Colors.green, Colors.red, (colorValue ?? 5) / 10),
        );
      }
    }
    if (colors.isEmpty) return Colors.grey.shade500;
    return _mixColor(colors.map((color) => ColorPart(color, 1)).toList());
  }

  DayCollection(this.daysAgo, this.weight, this.studentRecords);
}

class ConditionColor {
  final Color color;
  final String id;

  ConditionColor(this.color, this.id);

  @override
  String toString() {
    return 'ConditionColor(color: $color, label: $id)';
  }
}

Color _mixColor(List<ColorPart> parts) {
  if (parts.isEmpty) return Colors.transparent;

  int totalWeight = 0;
  int r = 0, g = 0, b = 0;

  for (var part in parts) {
    totalWeight += part.weight;
    r += part.color.red * part.weight;
    g += part.color.green * part.weight;
    b += part.color.blue * part.weight;
  }

  if (totalWeight == 0) return Colors.transparent;

  return Color.fromARGB(
    255,
    (r / totalWeight).round(),
    (g / totalWeight).round(),
    (b / totalWeight).round(),
  );
}
