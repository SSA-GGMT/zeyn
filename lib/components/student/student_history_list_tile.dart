import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class StudentHistoryListTile extends StatelessWidget {
  const StudentHistoryListTile({super.key, required this.historyEntry, required this.questionsDefinition, required this.onDelete});
  final RecordModel historyEntry;
  final List<dynamic> questionsDefinition;
  final VoidCallback onDelete;

  String agoString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? "Vor 1 Tag"
          : "Vor ${difference.inDays} Tagen";
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? "Vor 1 Stunde"
          : "Vor ${difference.inHours} Stunden";
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? "Vor 1 Minute"
          : "Vor ${difference.inMinutes} Minuten";
    } else {
      return "Jetzt";
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryJson = historyEntry.data['questionAnswer'];
    final DateTime? createdDate = DateTime.tryParse(historyEntry.data["created"]);
    return Column(
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${entryJson[questionsDefinition[0]['id']]}"),
              Text(agoString(createdDate!),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 1; i < questionsDefinition.length; i++)
                if (entryJson[questionsDefinition[i]['id']] != null) Text(
                  "${questionsDefinition[i]['label']}: ${entryJson[questionsDefinition[i]['id']]}",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
          trailing: IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.black12,
        ),
      ],
    );
  }
}
