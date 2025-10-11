import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/pocketbase.dart';
import '../../utils/logger.dart';

class AsyncTeacherChip extends StatefulWidget {
  const AsyncTeacherChip({super.key, required this.teacherId, this.actions});
  final String teacherId;
  final List<Widget>? actions;

  @override
  State<AsyncTeacherChip> createState() => _AsyncTeacherChipState();
}

class _AsyncTeacherChipState extends State<AsyncTeacherChip> {
  String? teacherName;
  RecordModel? teacherRecord;

  @override
  void initState() {
    super.initState();
    loadTeacherName();
  }

  void loadTeacherName() async {
    try {
      final record = await pb.collection('teachers').getOne(widget.teacherId);
      teacherRecord = record;
      setState(() {
        teacherName = record.data['krz'] ?? 'Err';
      });
    } catch (e, s) {
      logger.e(e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: 6,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
        child: Row(children: [Icon(Icons.person), Text(teacherName ?? '...')]),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => SimpleDialog(
                title: Row(
                  children: [
                    Icon(Icons.person),
                    Text(
                      "${teacherRecord?.data['firstName']} ${teacherRecord?.data['secondName']} (${teacherRecord?.data['krz']})",
                    ),
                  ],
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8.0,
                    children: [
                      Icon(Icons.email),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        onPressed:
                            () =>
                                teacherRecord?.data['email'] != null
                                    ? launchUrl(
                                      Uri.parse(
                                        'mailto:${teacherRecord!.data['email']}',
                                      ),
                                    )
                                    : null,
                        child: Text(teacherRecord?.data['email'] ?? ''),
                      ),
                    ],
                  ),
                  if (widget.actions != null) ...widget.actions!,
                ],
              ),
        );
      },
    );
  }
}

class SyncTeacherChip extends StatelessWidget {
  const SyncTeacherChip({
    super.key,
    required this.teacherRecordData,
    this.actions,
  });
  final Map<String, dynamic> teacherRecordData;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final krz = teacherRecordData['krz'] ?? 'Err';
    final firstName = teacherRecordData['firstName'] ?? '';
    final secondName = teacherRecordData['secondName'] ?? '';
    final email = teacherRecordData['email'] ?? '';

    return InkWell(
      radius: 6,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
        child: Row(children: [Icon(Icons.person), Text(krz)]),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => SimpleDialog(
                title: Row(
                  children: [
                    Icon(Icons.person),
                    Text("$firstName $secondName ($krz)"),
                  ],
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        onPressed:
                            email.isNotEmpty
                                ? () => launchUrl(Uri.parse('mailto:$email'))
                                : null,
                        child: Text(email),
                      ),
                    ],
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
        );
      },
    );
  }
}
