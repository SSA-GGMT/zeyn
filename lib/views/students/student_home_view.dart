import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/components/shared/feedback_button.dart';
import 'package:zeyn/components/shared/logout_icon_button.dart';
import 'package:zeyn/components/student/student_history_list_tile.dart';
import 'package:zeyn/utils/dialogs/show_confirm_dialog.dart';
import 'package:zeyn/views/students/student_create_new_entry_view.dart';

import '../../api/pocketbase.dart';
import '../../utils/dialogs/show_error_dialog.dart';
import '../../utils/dialogs/show_loading_dialog.dart';
import '../../utils/logger.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  RecordModel? courseModel;
  List<RecordModel>? historyEntries;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> getCourse() async {
    final course = await pb
        .collection('courses')
        .getOne(pb.authStore.record!.data['course'], expand: 'school,sport,');

    setState(() {
      courseModel = course;
    });
  }

  Future<void> getHistoryEntries() async {
    final resultList = await pb
        .collection('studentRecords')
        .getList(page: 1, perPage: 34, sort: "created");

    setState(() {
      historyEntries = resultList.items;
    });
  }

  void initialLoad() async {
    try {
      final courseFuture = getCourse();
      final historyFuture = getHistoryEntries();
      await Future.wait([courseFuture, historyFuture]);
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (mounted) {
        showErrorDialog(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initialLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${pb.authStore.record!.data['secondName']}, ${pb.authStore.record!.data['firstName']}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        actions: [
          FeedbackButton(urlSubPath: 'student'),
          LogoutIconButton(iconColor: Theme.of(context).colorScheme.onTertiary),
        ],
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: getHistoryEntries,
        child: CustomScrollView(
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
            if (historyEntries?.isEmpty ?? true)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.face, size: 48),
                      Text("Keine Einträge!"),
                    ],
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: historyEntries!.length,
                itemBuilder:
                    (context, index) => StudentHistoryListTile(
                      historyEntry:
                          historyEntries![historyEntries!.length - index - 1],
                      questionsDefinition: courseModel?.data['questions'],
                      onDelete: () async {
                        final delete = await showConfirmDialog(context);
                        if (delete == false) return;
                        showLoadingDialog(context);
                        pb
                            .collection('studentRecords')
                            .delete(
                              historyEntries![historyEntries!.length -
                                      index -
                                      1]
                                  .id,
                            )
                            .then((_) {
                              if (context.mounted) Navigator.of(context).pop();
                              getHistoryEntries();
                            })
                            .catchError((e, s) {
                              logger.e(e, stackTrace: s);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                showErrorDialog(context);
                              }
                            });
                      },
                    ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => StudentCreateNewEntryView(
                    form: courseModel?.data['questions'],
                  ),
            ),
          );
          await _refreshIndicatorKey.currentState?.show();
        },
        icon: Icon(Icons.add),
        label: Text("Neuer Eintrag"),
      ),
    );
  }
}
