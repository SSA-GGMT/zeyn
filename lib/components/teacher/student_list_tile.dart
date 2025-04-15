import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../utils/logger.dart';
import '../student_qr_login_screen.dart';

class StudentListTile extends StatefulWidget {
  const StudentListTile({super.key, required this.initStudentData});
  final RecordModel initStudentData;

  @override
  State<StudentListTile> createState() => _StudentListTileState();
}

class _StudentListTileState extends State<StudentListTile> {
  late final List<StudentListTileAction> _actions;
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
        icon: Icon(Icons.edit),
        label: 'Bearbeiten',
        onTap: () {},
      ),
      StudentListTileAction(
        icon: Icon(Icons.delete),
        label: 'Löschen',
        onTap: () {},
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${widget.initStudentData.data['firstName']} ${widget.initStudentData.data['secondName']}",
      ),
      subtitle: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              color: {
                'TSP': Colors.green,
                'LK': Colors.yellow,
                'NK': Colors.red,
              }[widget.initStudentData.data['kaderStatus']] ?? Colors.grey,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Text(widget.initStudentData.data['kaderStatus'],),
          )
        ],
      ),
      leading: const Icon(Icons.school),
      onTap: () {},
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
