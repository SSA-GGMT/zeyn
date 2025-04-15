import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../views/admin/admin_edit_teacher_view.dart';

class TeacherListTile extends StatelessWidget {
  const TeacherListTile({
    super.key,
    required this.teacherData,
    required this.afterTap,
  });

  final Function() afterTap;

  final RecordModel teacherData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person),
      trailing: Text(
        teacherData.data['krz'],
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      title: Text(
        '${teacherData.data['secondName']}, ${teacherData.data['firstName']}',
      ),
      subtitle: Text(
        teacherData.data['email'],
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => AdminEditTeacherView(initialData: teacherData),
          ),
        );
        afterTap();
      },
    );
  }
}
