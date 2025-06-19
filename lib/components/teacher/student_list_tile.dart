import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/utils/dialogs/show_confirm_dialog.dart';
import 'package:zeyn/utils/dialogs/show_error_dialog.dart';
import 'package:zeyn/utils/dialogs/show_loading_dialog.dart';

import '../../api/pocketbase.dart';
import '../../utils/condition_generator.dart';
import '../../utils/logger.dart';
import '../student_qr_login_screen.dart';

class StudentListTile extends StatefulWidget {
  const StudentListTile({super.key, required this.initStudentData, required this.form, required this.evalFields, required this.refreshCallback});
  final RecordModel initStudentData;
  final List<dynamic> form;
  final List<String> evalFields;
  final Function refreshCallback;

  @override
  State<StudentListTile> createState() => _StudentListTileState();
}

class _StudentListTileState extends State<StudentListTile> {
  late final List<StudentListTileAction> _actions;
  late List<RecordModel> studentRecords;
  late List<ConditionColor> conditionColors;
  bool loadingRecords = true;

  @override
  void initState() {
    _actions = [
      StudentListTileAction(
        icon: Icon(Icons.qr_code),
        label: 'QR-Login',
        onTap: () {
          showStudentLoginQrCode(
            context,
            StudentQrModel.fromRecordModel(widget.initStudentData),
          );
        },
      ),
      StudentListTileAction(
        icon: Icon(Icons.delete),
        label: 'Löschen',
        onTap: () async {
          final shouldDelete = await showConfirmDialog(context);
          if (!shouldDelete) return;
          if (mounted) showLoadingDialog(context);
          try {
            final records = await pb.collection('studentRecords').getFullList(
              filter: 'student = "${widget.initStudentData.id}"',
              fields: 'id',
            );
            final batch = pb.createBatch();
            for (final record in records) {
              batch.collection('studentRecords').delete(record.id);
            }
            batch.collection('students').delete(widget.initStudentData.id);
            await batch.send();
            widget.refreshCallback();
            if (mounted) Navigator.of(context).pop();
          } catch (e, s) {
            logger.e(e, stackTrace: s);
            if (mounted) {
              Navigator.of(context).pop();
              showErrorDialog(context);
            }
            return;
          }
        },
      ),
    ];
    super.initState();
    _loadStudentRecords();
  }

  Future<void> _loadStudentRecords() async {
    // you can also fetch all records at once via getFullList
      final records = await pb.collection('studentRecords').getFullList(
        // not older than 7 days
        filter: 'student = "${widget.initStudentData.id}" && created > "${DateTime.now().subtract(const Duration(days: 7)).toIso8601String()}"',
      );

      studentRecords = records;
      List<Map> studentRecordsMap = studentRecords.map((e) =>
      {
        ...e.data['questionAnswer'],
        'created': e.data['created'],
      }).toList(growable: false);
      conditionColors = ConditionGenerator.generateConditionColors(studentRecords: studentRecordsMap, evalFields: widget.evalFields);

      setState(() {
      loadingRecords = false;
    });
  }
  
  String getConditionLabel(String id) {
    final condition = widget.form.firstWhere(
      (element) => element['id'] == id,
      orElse: () => {'label': 'Unbekannt'},
    );
    return condition['label'] ?? 'Unbekannt';
  }
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${widget.initStudentData.data['firstName']} ${widget.initStudentData.data['secondName']} (${widget.initStudentData.data['kaderStatus']})",
      ),
      subtitle: loadingRecords ? LinearProgressIndicator() : Wrap(
        spacing: 2,
        children: conditionColors.map(
              (conditionColor) => Container(
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                margin: EdgeInsets.symmetric(vertical: 1.0),
                decoration: BoxDecoration(
                  color: conditionColor.color,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Text(getConditionLabel(conditionColor.id),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
              )
          ).toList(),
      ),
      leading: const Icon(Icons.school),
      trailing: PopupMenuButton<StudentListTileAction>(
        onSelected: (StudentListTileAction choice) {
          choice.onTap();
        },
        itemBuilder: (BuildContext context) {
          return _actions.map((StudentListTileAction choice) {
            return PopupMenuItem<StudentListTileAction>(
              value: choice,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [choice.icon, Text(choice.label)],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}

class StudentListTileAction {
  const StudentListTileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Icon icon;
  final String label;
  final VoidCallback onTap;
}
