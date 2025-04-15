import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sportslogger/components/student_qr_login_screen.dart';
import 'package:sportslogger/components/teacher/student_list_tile.dart';
import 'package:sportslogger/utils/dialogs/show_loading_dialog.dart';
import 'package:sportslogger/views/teachers/teacher_add_student_to_course_view.dart';
import 'package:printing/printing.dart';

import '../../api/pocketbase.dart';
import '../../components/teacher/async_teacher_chip.dart';
import '../../components/teacher/teacher_selector.dart';
import '../../utils/logger.dart';
import '../../utils/pdf/create_qr_logins_pdf.dart';

class TeacherCourseDetailView extends StatefulWidget {
  const TeacherCourseDetailView({super.key, required this.initCourseData});
  final RecordModel initCourseData;

  @override
  State<TeacherCourseDetailView> createState() =>
      _TeacherCourseDetailViewState();
}

class _TeacherCourseDetailViewState extends State<TeacherCourseDetailView> {
  late RecordModel courseData;
  List<RecordModel>? students;

  @override
  void initState() {
    courseData = widget.initCourseData;
    super.initState();
    refreshCourseData(showLoading: false);
  }

  bool get isOwnCourse => courseData.data['manager'] == pb.authStore.record?.id;

  Future<void> refreshCourseData({bool showLoading = true}) async {
    if (showLoading) showLoadingDialog(context);
    try {
      final updatedCourseData = await pb
          .collection('courses')
          .getOne(courseData.id);
      final studentsData = await pb.collection('students').getList();
      students = studentsData.items;
      setState(() {
        courseData = updatedCourseData;
      });
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren der Kursdaten')),
        );
      }
    }
    if (mounted && showLoading) {
      Navigator.of(context).pop();
    }
  }

  void removeGuestManager(String teacherId) async {
    showLoadingDialog(context);
    try {
      await pb
          .collection('courses')
          .update(
            courseData.id,
            body: {
              'guestManagers':
                  courseData.data['guestManagers']..remove(teacherId),
            },
          );
      await refreshCourseData();
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Entfernen des Gastmanagers')),
        );
      }
    }
  }

  void addGuestManager(String teacherId) async {
    showLoadingDialog(context);
    try {
      await pb
          .collection('courses')
          .update(
            courseData.id,
            body: {
              'guestManagers': [...courseData.data['guestManagers'], teacherId],
            },
          );
      await refreshCourseData();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen des Gastmanagers')),
        );
      }
    }
  }

  Future<Uint8List> getPdfData() async {
    showLoadingDialog(context);
    final pdfData = await createPDF(students!.map((student) => StudentQrModel.fromRecordModel(student)).toList(),
      'Logins für >${courseData.data['courseTitle']}<',
      courseData.id,
    );
    if (mounted) Navigator.of(context).pop();
    return pdfData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kursdetails'),
        backgroundColor: Theme.of(context).primaryColorLight,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  final data = await getPdfData();
                  Printing.layoutPdf(
                    onLayout: (format) => data,
                  );
                },
                child: Row(
                  spacing: 4.0,
                  children: [
                    Icon(Icons.print),
                    Text('Logins Drucken'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () async {
                  final data = await getPdfData();
                  await Printing.sharePdf(
                    bytes: data,
                    filename: 'Logins_${courseData.data['courseTitle']}.pdf',
                  );
                },
                child: Row(
                  spacing: 4.0,
                  children: [
                    Icon(Icons.picture_as_pdf),
                    Text('Logins Druck teilen'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshCourseData,
        child: CustomScrollView(
          slivers: [
            SliverFloatingHeader(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.0),
                  ),
                  color: Theme.of(context).secondaryHeaderColor,
                  border: Border.all(
                    color: Theme.of(context).primaryColorLight,
                    width: 2,
                  ),
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Badge(
                        isLabelVisible:
                            (students?.length ??
                                courseData.data['students']?.length ??
                                0) ==
                            0,
                        label: Text(
                          '${students?.length ?? courseData.data['students']?.length ?? 0}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        child: Icon(Icons.group, size: 40),
                      ),
                      SizedBox(width: 8.0),
                      Text(courseData.data['courseTitle'], style: Theme.of(context).textTheme.titleMedium,),
                      Spacer(),
                      Wrap(
                        spacing: 4.0,
                        children: [
                          AsyncTeacherChip(
                            teacherId: courseData.data['manager'],
                          ),
                          ...courseData.data['guestManagers'].map(
                            (teacherId) => AsyncTeacherChip(
                              teacherId: teacherId,
                              actions:
                                  isOwnCourse
                                      ? [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: ElevatedButton(
                                            onPressed:
                                                () => removeGuestManager(
                                                  teacherId,
                                                ),
                                            child: Row(
                                              spacing: 4.0,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.person_remove),
                                                Text('Zugang entziehen'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                      : null,
                            ),
                          ),
                          if (isOwnCourse)
                            InkWell(
                              radius: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 1.0,
                                ),
                                child: Icon(Icons.add),
                              ),
                              onTap: () async {
                                final result = await showTeacherSelector(
                                  context,
                                  excludeIds: [
                                    courseData.data['manager'],
                                    ...courseData.data['guestManagers'],
                                  ],
                                );
                                if (result != null) addGuestManager(result.id);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (students == null || students!.isEmpty)
              SliverFillRemaining(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12.0,
                  children: [
                    Icon(Icons.group, size: 40),
                    Text('Keine Teilnehmer gefunden'),
                  ],
                ),
              )
            else
              SliverToBoxAdapter(
                child: Column(
                  children:
                      students!
                          .map((e) => StudentListTile(initStudentData: e))
                          .toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final RecordModel? newStudentData = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return TeacherAddStudentToCourseView(courseData: courseData);
              },
            ),
          );
          await refreshCourseData(showLoading: true);
          if (newStudentData == null || !context.mounted) return;
          showStudentLoginQrCode(
            context,
            StudentQrModel.fromRecordModel(newStudentData),
          );
        },
        label: Text('Schüler erstellen'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
