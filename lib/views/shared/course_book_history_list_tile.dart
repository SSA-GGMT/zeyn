import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/api/pocketbase.dart';
import 'package:zeyn/components/teacher/teacher_chip.dart';
import 'package:zeyn/utils/dialogs/show_confirm_dialog.dart';
import 'package:zeyn/utils/logger.dart';

class CourseBookHistoryListTile extends StatelessWidget {
  final RecordModel historyRecord;
  final Function onDelete;
  const CourseBookHistoryListTile({super.key, required this.historyRecord, required this.onDelete});

  void deleteHistoryRecord(BuildContext context) async {
    if (await showConfirmDialog(context,
        message: 'Möchten Sie diesen Eintrag wirklich löschen?')) {
      try {
        await pb.collection('courseHistoryRecords').delete(historyRecord.id);
        if (onDelete != null) {
          onDelete!();
        }
      } catch (e, stack) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Löschen des Eintrags')),
          );
        }
        logger.e(e, stackTrace: stack);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat(
                    'EE dd.MM.yyyy hh:mm',
                  ).format(DateTime.parse(historyRecord.data['created'])),
                ),
              ),
              SyncTeacherChip(
                teacherRecordData: historyRecord.get('expand')['createdBy'],
              ),
            ],
          ),
          subtitle:
              historyRecord.get('notes').isNotEmpty
                  ? Text(historyRecord.get('notes'))
                  : null,
          trailing:
              pb.authStore.record?.collectionName == 'teachers'
                  ? IconButton.filledTonal(
                    onPressed: () => deleteHistoryRecord(context),
                    icon: Icon(Icons.delete),
                  )
                  : null,
        ),
      ],
    );
  }
}
