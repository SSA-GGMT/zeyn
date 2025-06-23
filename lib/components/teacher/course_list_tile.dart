import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../api/pocketbase.dart';
import '../../views/teachers/teacher_course_detail_view.dart';
import 'async_teacher_chip.dart';

class CourseListTile extends StatelessWidget {
  const CourseListTile({
    super.key,
    required this.courseData,
    required this.popAndRefresh,
    this.sportsList,
  });

  final RecordModel courseData;
  final List<RecordModel>? sportsList;
  final Function popAndRefresh;

  bool get _isOwnCourse {
    return courseData.data['manager'] == pb.authStore.record?.id;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.group),
      trailing: const Icon(Icons.arrow_forward_ios),
      title: Row(
        children: [
          Text(courseData.data['courseTitle']),
          const Spacer(),
          if (!_isOwnCourse)
            AsyncTeacherChip(teacherId: courseData.data['manager']),
        ],
      ),
      subtitle:
          sportsList == null
              ? Row(
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              )
              : Text(
                sportsList
                    ?.firstWhere(
                      (element) => element.id == courseData.data['sport'],
                    )
                    .data['name'],
                style: const TextStyle(fontSize: 12),
              ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) =>
                    TeacherCourseDetailView(initCourseData: courseData, popAndRefresh: popAndRefresh,),
          ),
        );
      },
    );
  }
}
