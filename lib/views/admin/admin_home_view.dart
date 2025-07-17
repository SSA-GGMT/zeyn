import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/components/admin/teacher_list_tile.dart';
import 'package:zeyn/components/logout_icon_button.dart';

import '../../api/pocketbase.dart';
import '../../utils/logger.dart';
import 'admin_add_teacher_view.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  List<RecordModel> data = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    data =
        (await pb.collection('teachers').getList(sort: 'krz,secondName')).items;
    setState(() {
      data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text('Schuladministration'),
        actions: [LogoutIconButton()],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
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
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pb.authStore.record?.data['name']} (${pb.authStore.record?.data['schoolID']})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      pb.authStore.record?.data['city'],
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: refreshKey,
              onRefresh: () async {
                data =
                    (await pb
                        .collection('teachers')
                        .getList(sort: 'krz,secondName')).items;
                setState(() {
                  data = data;
                });
                logger.d('Teachers: $data');
              },
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int i) {
                  return TeacherListTile(
                    teacherData: data[i],
                    afterTap: () => refreshKey.currentState?.show(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddTeacherView(),
            ),
          );
          refreshKey.currentState?.show();
        },
        label: Text('Lehrer Hinzufügen'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
