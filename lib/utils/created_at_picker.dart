import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatedAtPicker extends StatefulWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onChanged;

  const CreatedAtPicker({
    super.key,
    required this.initialDateTime,
    required this.onChanged,
  });

  @override
  State<CreatedAtPicker> createState() => _CreatedAtPickerState();
}

class _CreatedAtPickerState extends State<CreatedAtPicker> {
  late DateTime createdAt;

  @override
  void initState() {
    super.initState();
    createdAt = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat day = DateFormat('dd.MM.yyyy');
    final DateFormat time = DateFormat('HH:mm');

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 4.0),
                Text(
                  day.format(createdAt),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Text(
                  time.format(createdAt),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(width: 4.0),
                Icon(Icons.access_time),
              ],
            ),
          ),
        ],
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: createdAt,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null && mounted) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(createdAt),
          );
          if (pickedTime != null && mounted) {
            final newDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            if (newDateTime.isBefore(DateTime.now()) ||
                newDateTime.isAtSameMomentAs(DateTime.now())) {
              setState(() {
                createdAt = newDateTime;
              });
              widget.onChanged(newDateTime);
            }
          }
        }
      },
    );
  }
}
