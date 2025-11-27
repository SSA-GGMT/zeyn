import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/api/pocketbase.dart';
import 'package:zeyn/components/shared/course_book_history_list_tile.dart';
import 'package:zeyn/views/shared/create_book_history_event_view.dart';

import '../../utils/logger.dart';

class CourseBookHistoryView extends StatefulWidget {
  final RecordModel course;

  const CourseBookHistoryView({super.key, required this.course});

  @override
  State<CourseBookHistoryView> createState() => _CourseBookHistoryViewState();
}

class _CourseBookHistoryViewState extends State<CourseBookHistoryView> {
  List<RecordModel> history = [];
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> fetchHistory() async {
    try {
      // you can also fetch all records at once via getFullList
      final records = await pb
          .collection('courseHistoryRecords')
          .getFullList(
            filter:
                'course = "${widget.course.id}" && created > "${DateTime.now().subtract(Duration(days: 380)).toIso8601String()}"',
            sort: "-created",
            expand: 'createdBy',
          );

      if (mounted) {
        setState(() {
          history = records;
        });
      }
    } catch (e, stack) {
      logger.e(e, stackTrace: stack);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Historie')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 4,
          children: [
            const Icon(Icons.history),
            Expanded(
              child: Text(
                widget.course.getStringValue('courseTitle'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: fetchHistory,
        child: history.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height - kToolbarHeight - 24,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        Text(
                          'Keine Historie vorhanden',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  return CourseBookHistoryListTile(
                    historyRecord: record,
                    onDelete: () => fetchHistory(),
                  );
                },
              ),
      ),
      floatingActionButton: pb.authStore.record!.collectionName == 'teachers'
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateBookHistoryEventView(courseId: widget.course.id),
                  ),
                );
                await fetchHistory();
              },
              icon: const Icon(Icons.add),
              label: const Text('Eintrag erstellen'),
            )
          : null,
    );
  }
}
