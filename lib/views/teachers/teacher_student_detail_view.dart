import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/api/pocketbase.dart';
import 'package:zeyn/components/student/student_history_list_tile.dart';
import 'package:zeyn/utils/logger.dart';

class TeacherStudentDetailView extends StatefulWidget {
  final RecordModel initStudentData;
  final List<dynamic> questionsDefinition;
  final List<String> evalFields;
  const TeacherStudentDetailView({
    super.key,
    required this.initStudentData,
    required this.questionsDefinition,
    required this.evalFields,
  });

  @override
  State<TeacherStudentDetailView> createState() =>
      _TeacherStudentDetailViewState();
}

enum SelectedHistoryRange { week, month, threeMonths, sixMonths, year }

class _TeacherStudentDetailViewState extends State<TeacherStudentDetailView>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<RecordModel> _studentRecords = [];
  SelectedHistoryRange _selectedHistoryRange = SelectedHistoryRange.month;
  bool errorLoadingRecords = false;

  Duration get selectedRangeDuration {
    switch (_selectedHistoryRange) {
      case SelectedHistoryRange.week:
        return Duration(days: 7);
      case SelectedHistoryRange.month:
        return Duration(days: 30);
      case SelectedHistoryRange.threeMonths:
        return Duration(days: 90);
      case SelectedHistoryRange.sixMonths:
        return Duration(days: 180);
      case SelectedHistoryRange.year:
        return Duration(days: 365);
    }
  }

  Widget timeSelectorButton() {
    String getShortLabel(range) {
      switch (range) {
        case SelectedHistoryRange.week:
          return '7d';
        case SelectedHistoryRange.month:
          return '30d';
        case SelectedHistoryRange.threeMonths:
          return '3M';
        case SelectedHistoryRange.sixMonths:
          return '6M';
        case SelectedHistoryRange.year:
          return '1Y';
        default:
          return '';
      }
    }

    return PopupMenuButton<SelectedHistoryRange>(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 2.0,
          children: [
            Icon(Icons.history),
            Text(
              getShortLabel(_selectedHistoryRange),
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      onSelected: (SelectedHistoryRange value) {
        setState(() {
          _selectedHistoryRange = value;
          loadRecordsForSelectedRange();
        });
      },
      itemBuilder: (BuildContext context) {
        return SelectedHistoryRange.values.map((SelectedHistoryRange range) {
          String germanLabel;
          switch (range) {
            case SelectedHistoryRange.week:
              germanLabel = 'Woche';
              break;
            case SelectedHistoryRange.month:
              germanLabel = 'Monat';
              break;
            case SelectedHistoryRange.threeMonths:
              germanLabel = '3 Monate';
              break;
            case SelectedHistoryRange.sixMonths:
              germanLabel = '6 Monate';
              break;
            case SelectedHistoryRange.year:
              germanLabel = 'Jahr';
              break;
          }
          return PopupMenuItem<SelectedHistoryRange>(
            value: range,
            child: Text(germanLabel),
          );
        }).toList();
      },
    );
  }

  void loadRecordsForSelectedRange() async {
    setState(() {
      _isLoading = true;
      errorLoadingRecords = false;
    });
    try {
      _studentRecords = await pb
          .collection('studentRecords')
          .getFullList(
            // not older than 7 days
            filter:
                'student = "${widget.initStudentData.id}" && created > "${DateTime.now().subtract(selectedRangeDuration).toIso8601String()}"',
            sort: "created",
          );
    } catch (e) {
      errorLoadingRecords = true;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStudentHistoryList() {
    return ListView.builder(
      itemCount: _studentRecords.length,
      itemBuilder: (context, index) {
        int reverseIndex = _studentRecords.length - 1 - index;
        final record = _studentRecords[reverseIndex];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StudentHistoryListTile(
              historyEntry: record,
              questionsDefinition: widget.questionsDefinition,
              onDelete: () {},
            ),
            Divider(),
          ],
        );
      },
    );
  }

  Widget _buildStudentChartList() {
    return ListView.builder(
      itemCount: widget.evalFields.length,
      itemBuilder: (context, index) {
        String evalField = widget.evalFields[index];
        dynamic definition = widget.questionsDefinition.firstWhere(
          (q) => q['id'] == evalField,
          orElse: () => {'label': 'Unbekannt'},
        );
        return Card(
          margin: EdgeInsets.all(4.0),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Text(definition['label'] ?? 'Unbekannt'),
                lineChartWidget(
                  evalField: evalField,
                  label: definition['label'] ?? 'Unbekannt',
                  definition: definition,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  LineChartBarData _buildLineChartBarData(
    String evalField,
    dynamic definition,
  ) {
    logger.d(definition['max_color']);
    return LineChartBarData(
      spots:
          _studentRecords
              .where((e) => e.data['questionAnswer'].containsKey(evalField))
              .map((record) {
                final dataPoint = double.parse(
                  record.data['questionAnswer'][evalField].toString(),
                );
                final DateTime created = DateTime.parse(record.data['created']);
                return FlSpot(
                  selectedRangeDuration.inDays.toDouble() -
                      DateTime.now().difference(created).inDays.toDouble(),
                  dataPoint,
                );
              })
              .toList(),
      isCurved: true,
      barWidth: 2.0,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          Color color = gradientColorAt(
            Color(int.parse(definition['min_color'].replaceFirst('#', '0xFF'))),
            Color(int.parse(definition['max_color'].replaceFirst('#', '0xFF'))),
            spot.y / definition['max']!.toDouble(),
          );
          return FlDotCirclePainter(
            radius: 1.0,
            color: color,
            strokeWidth: 1,
            strokeColor: color,
          );
        },
      ),
    );
  }

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

  Widget lineChartWidget({
    required String evalField,
    required String label,
    required dynamic definition,
  }) {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 1,
                dashArray: [1, 4],
              );
            },
          ),
          lineBarsData: [_buildLineChartBarData(evalField, definition)],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final DateTime date = DateTime.now().subtract(
                    Duration(days: spot.x.toInt()),
                  );
                  return LineTooltipItem(
                    '${DateFormat('dd.MM.yyyy').format(date)}\n${spot.y.toStringAsFixed(2)}/${definition['max']}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          minY: definition['min']!.toDouble(),
          maxY: definition['max']!.toDouble(),
          minX: 0,
          maxX: selectedRangeDuration.inDays.toDouble(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadRecordsForSelectedRange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.initStudentData.data['firstName']} ${widget.initStudentData.data['secondName']}",
        ),
        actions: [timeSelectorButton()],
      ),
      body: Center(
        child:
            _isLoading
                ? CircularProgressIndicator()
                : errorLoadingRecords
                ? Text("Error loading student records")
                : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(tabs: [Tab(text: 'Grafik'), Tab(text: 'Verlauf')]),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildStudentChartList(),
                            _buildStudentHistoryList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
