import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sportslogger/components/logout_icon_button.dart';

import '../../api/pocketbase.dart';
import '../../utils/logger.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  RecordModel? courseModel;

  Future<void> getCourse() async {
    logger.d(pb.authStore.record!.data['course']);
    final course = await pb
        .collection('courses')
        .getOne(pb.authStore.record!.data['course'], expand: 'school,sport');

    logger.d('Course: ${course.toJson()['expand']}');
    setState(() {
      courseModel = course;
    });
  }

  @override
  void initState() {
    super.initState();
    getCourse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${pb.authStore.record!.data['secondName']}, ${pb.authStore.record!.data['firstName']}',
        ),
        actions: [LogoutIconButton()],
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFloatingHeader(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 2.0,
                ),
                borderRadius: BorderRadiusDirectional.vertical(
                  bottom: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  spacing: 8.0,
                  children: [
                    Icon(Icons.school, size: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${courseModel?.data['courseTitle']} (${courseModel?.data['expand']['sport']['name']})",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          courseModel?.data['expand']['school']['name'] ?? '',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              return ListTile(title: Text("${courseModel?.toJson()}"));
            }, childCount: 1),
          ),
        ],
      ),
    );
  }
}
