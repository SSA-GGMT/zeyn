import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../utils/logger.dart';
import '../../api/pocketbase.dart';

typedef OnSelected = void Function(RecordModel selectedSports);

class SportsSelector extends StatefulWidget {
  const SportsSelector({super.key, required this.onSelected});
  final OnSelected onSelected;

  @override
  State<SportsSelector> createState() => _SportsSelectorState();
}

class _SportsSelectorState extends State<SportsSelector> {
  List<RecordModel>? sports;

  void loadSports() async {
    try {
      final records = await pb.collection('sports').getFullList();
      setState(() {
        sports = records;
      });
      if (sports != null && sports!.isNotEmpty) {
        widget.onSelected(sports!.first);
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fehler beim Laden der Sportarten, versuche es in 10 Sekunden erneut',
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 10));
      loadSports();
    }
  }

  @override
  void initState() {
    super.initState();
    loadSports();
  }

  @override
  Widget build(BuildContext context) {
    return sports == null
        ? LinearProgressIndicator()
        : DropdownMenu<RecordModel>(
          width: double.infinity,
          dropdownMenuEntries:
              sports
                  ?.map(
                    (e) => DropdownMenuEntry(
                      label: e.data['name'],
                      labelWidget: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.data['name']),
                          if (e.data['description'] != null)
                            Text(
                              e.data['description'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      value: e,
                    ),
                  )
                  .toList() ??
              [],
          onSelected: (value) {
            if (value != null) {
              widget.onSelected(value);
            }
          },
          label: const Text('Sportart auswählen'),
          initialSelection: sports?.first,
        );
  }
}
