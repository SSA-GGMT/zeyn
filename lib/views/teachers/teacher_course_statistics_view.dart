import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/api/pocketbase.dart';

class TeacherCourseStatisticsView extends StatefulWidget {
  final List<RecordModel> students;
  final RecordModel course;

  const TeacherCourseStatisticsView({
    super.key,
    required this.students,
    required this.course,
  });

  @override
  State<TeacherCourseStatisticsView> createState() =>
      _TeacherCourseStatisticsViewState();
}

class _TeacherCourseStatisticsViewState
    extends State<TeacherCourseStatisticsView> {
  String get sportsName =>
      widget.course.get("expand")["sport"]["name"].toString();

  String get schoolName =>
      widget.course.get("expand")["school"]["name"].toString();

  String get schoolID =>
      widget.course.get("expand")["school"]["schoolID"].toString();

  Map<String, int> get sexStatistics {
    final Map<String, int> stats = {"Männlich": 0, "Weiblich": 0, "Divers": 0};

    for (var student in widget.students) {
      final sex = student.getStringValue("sex");
      stats[sex] = (stats[sex] ?? 0) + 1;
    }

    return stats;
  }

  Map<String, int> get kaderStatusStatistics {
    final Map<String, int> stats = {};

    for (var student in widget.students) {
      final sex = student.getStringValue("kaderStatus");
      stats[sex] = (stats[sex] ?? 0) + 1;
    }

    return stats;
  }

  bool isLoadingAttendanceHistory = false;
  int courseHistoryRecordCount = -1;
  double courseHistoryAverageAttendance = -1.0;
  DateTime lastCourseHistoryRecordDateStart = DateTime.now().subtract(
    Duration(days: 380),
  );
  DateTime lastCourseHistoryRecordDateEnd = DateTime.now().add(
    Duration(days: 1),
  );

  void loadCourseHistoryRecords() async {
    setState(() {
      isLoadingAttendanceHistory = true;
    });

    final records = await pb
        .collection('courseHistoryRecords')
        .getFullList(
          filter:
              'course = "${widget.course.id}" && created > "${lastCourseHistoryRecordDateStart.toIso8601String()}" && created < "${lastCourseHistoryRecordDateEnd.toIso8601String()}"',
        );

    courseHistoryRecordCount = records.length;

    int totalAttendance = 0;
    for (var record in records) {
      totalAttendance += record.getIntValue('student_count');
    }

    courseHistoryAverageAttendance = records.isNotEmpty
        ? (totalAttendance / widget.students.length) * 100
        : 0.0;

    setState(() {
      isLoadingAttendanceHistory = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCourseHistoryRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kursstatistiken')),
      body: ListView(
        children: [
          Container(
            height: 28.0,
            color: Colors.amberAccent,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text("Beta: Diese Funktion befindet sich noch in der Entwicklung."),
          ),
          Column(
            children: [
              CopyListTile(
                title: Text('Schulname'),
                subtitle: Text("$schoolName ($schoolID)"),
              ),
              CopyListTile(
                title: Text('Kursname'),
                subtitle: Text(widget.course.getStringValue('courseTitle')),
              ),
              CopyListTile(title: Text('Sportart'), subtitle: Text(sportsName)),
              CopyListTile(
                title: Text('Anzahl Kursteilnehmer'),
                subtitle: Text(widget.students.length.toString()),
              ),
              Divider(),
              Column(
                children: [
                  ListTile(title: Text('Geschlechterverteilung')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: sexStatistics.entries
                        .map(
                          (e) => Column(
                            children: [Text(e.key), Text(e.value.toString())],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              Divider(),
              Column(
                children: [
                  ListTile(title: Text('Kaderstatusverteilung')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: kaderStatusStatistics.entries
                        .map(
                          (e) => Column(
                            children: [Text(e.key), Text(e.value.toString())],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              Divider(),
              Column(
                children: [
                  ListTile(
                    title: Text('Kursbesuchsstatistiken'),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Von"),
                        DateSelector(
                          time: lastCourseHistoryRecordDateStart,
                          onDateChanged: (newDate) {
                            setState(() {
                              lastCourseHistoryRecordDateStart = newDate;
                            });
                            loadCourseHistoryRecords();
                          },
                        ),
                        Text("bis"),
                        DateSelector(
                          time: lastCourseHistoryRecordDateEnd,
                          firstDate: lastCourseHistoryRecordDateStart,
                          onDateChanged: (newDate) {
                            setState(() {
                              lastCourseHistoryRecordDateEnd = newDate;
                            });
                            loadCourseHistoryRecords();
                          },
                        ),
                        Text(
                          "(${lastCourseHistoryRecordDateEnd.difference(lastCourseHistoryRecordDateStart).inDays} Tage)",
                        ),
                      ],
                    ),
                  ),
                  isLoadingAttendanceHistory
                      ? LinearProgressIndicator()
                      : Column(
                          children: [
                            CopyListTile(
                              title: Text('Anzahl Kursstunden (letztes Jahr)'),
                              subtitle: Text(
                                courseHistoryRecordCount.toString(),
                              ),
                            ),
                            CopyListTile(
                              title: Text('Durchschnittliche Kursbesuchsraten'),
                              subtitle: Text(
                                '${courseHistoryAverageAttendance.toStringAsFixed(2)} %',
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ],
          ),
          SizedBox(height: kToolbarHeight * 2),
        ],
      ),
    );
  }
}

class CopyListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final bool? dense;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final bool selected;
  final Color? tileColor;

  const CopyListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.dense,
    this.contentPadding,
    this.enabled = true,
    this.selected = false,
    this.tileColor,
  });

  String _subtitleText() {
    if (subtitle == null) return '';
    final s = subtitle;
    if (s is Text) {
      return s.data ?? s.textSpan?.toPlainText() ?? s.toString();
    }
    return s.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      dense: dense,
      contentPadding: contentPadding,
      enabled: enabled,
      selected: selected,
      tileColor: tileColor,
      onTap: () {
        if (subtitle != null) {
          final text = _subtitleText();
          if (text.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: text));
          }
        }
        if (onTap != null) onTap!();
      },
      onLongPress: onLongPress,
    );
  }
}

typedef DateChangedCallback = void Function(DateTime newDate);

class DateSelector extends StatelessWidget {
  final DateTime time;
  final DateTime? firstDate;
  final DateChangedCallback? onDateChanged;

  DateSelector({
    super.key,
    required this.time,
    this.firstDate,
    this.onDateChanged,
  });

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  bool get timeIsBeforeFirstDate =>
      firstDate != null && time.isBefore(firstDate!);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: timeIsBeforeFirstDate
              ? firstDate!.add(Duration(days: 1))
              : time,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null && onDateChanged != null) {
          onDateChanged!(pickedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: timeIsBeforeFirstDate
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _dateFormat.format(time),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}
