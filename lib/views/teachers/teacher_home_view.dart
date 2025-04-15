import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sportslogger/components/logout_icon_button.dart';
import 'package:sportslogger/views/teachers/teacher_add_course_view.dart';

import '../../api/pocketbase.dart';
import '../../components/teacher/course_list_tile.dart';
import '../../utils/logger.dart';

class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({super.key});

  @override
  State<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  List<RecordModel> courses = [];
  List<RecordModel>? sports;

  Future<void> loadCourses() async {
    try {
      final records = await pb
          .collection('courses')
          .getFullList(sort: 'courseTitle');
      setState(() {
        courses = records;
      });
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fehler beim Laden der Kurse, versuche es in 10 Sekunden erneut',
          ),
        ),
      );
    }
  }

  Future<void> loadSports() async {
    try {
      final records = await pb.collection('sports').getFullList();
      setState(() {
        sports = records;
      });
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (!mounted) return;
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
    loadCourses();
    loadSports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SportsLogger'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [LogoutIconButton()],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 8,
              children: [
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pb.authStore.record?.data['secondName']}, ${pb.authStore.record?.data['firstName']} (${pb.authStore.record?.data['krz']})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      pb.authStore.record?.data['email'],
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_search),
            trailing: Icon(Icons.arrow_forward),
            title: Text('Schüler suchen'),
            subtitle: Text('Schüler suchen und analysieren'),
            onTap: () {},
          ),
          Divider(height: 4, thickness: 2),
          Expanded(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: loadCourses,
              child:
                  courses.isNotEmpty
                      ? ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (BuildContext context, int i) {
                          final course = courses[i];
                          return CourseListTile(
                            courseData: course,
                            sportsList: sports,
                          );
                        },
                      )
                      : CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  Text(
                                    'Keine Kurse gefunden',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Neuen Kurs erstellen'),
        icon: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TeacherAddCourseView()),
          );
          _refreshKey.currentState?.show();
        },
      ),
    );
  }
}
