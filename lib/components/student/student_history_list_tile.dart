import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

class StudentHistoryListTile extends StatelessWidget {
  const StudentHistoryListTile({
    super.key,
    required this.historyEntry,
    required this.questionsDefinition,
    required this.onDelete,
    this.hideDelete = false,
  });
  final RecordModel historyEntry;
  final List<dynamic> questionsDefinition;
  final VoidCallback onDelete;
  final bool hideDelete;

  String agoString(DateTime dateTime) {
    final format = DateFormat('EEE, dd.MM.yyyy\nHH:mm');
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    String result = "";
    if (difference.inDays > 0) {
      result = difference.inDays == 1
          ? "Vor 1 Tag"
          : "Vor ${difference.inDays} Tagen";
    } else if (difference.inHours > 0) {
      result = difference.inHours == 1
          ? "Vor 1 Stunde"
          : "Vor ${difference.inHours} Stunden";
    } else if (difference.inMinutes > 0) {
      result = difference.inMinutes == 1
          ? "Vor 1 Minute"
          : "Vor ${difference.inMinutes} Minuten";
    } else {
      result = "Jetzt";
    }
    result += "\n${format.format(dateTime)}";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final entryJson = historyEntry.data['questionAnswer'];
    final DateTime? createdDate = DateTime.tryParse(
      historyEntry.data["created"],
    );
    return Column(
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${entryJson[questionsDefinition[0]['id']]}"),
              Text(
                agoString(createdDate!),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 1; i < questionsDefinition.length; i++)
                if (entryJson[questionsDefinition[i]['id']] != null)
                  Text(
                    "${questionsDefinition[i]['label']}: ${entryJson[questionsDefinition[i]['id']]}",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
            ],
          ),
          trailing: hideDelete
              ? null
              : IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }
}
