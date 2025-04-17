import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sportslogger/api/pocketbase.dart';
import 'package:sportslogger/views/admin/admin_home_view.dart';
import 'package:sportslogger/views/login_screen.dart';
import 'package:sportslogger/views/students/student_home_view.dart';
import 'package:sportslogger/views/teachers/teacher_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPocketbase();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportsLogger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[900]!),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: StreamBuilder(
          stream: pb.authStore.onChange,
          builder: (
            BuildContext context,
            AsyncSnapshot<AuthStoreEvent> snapshot,
          ) {
            final accountType = pb.authStore.record?.collectionName;
            if (accountType == 'teachers') {
              return TeacherHomeView();
            } else if (accountType == 'students') {
              return StudentHomeView();
            } else if (accountType == 'schools') {
              return AdminHomeView();
            }

            return LoginScreen();
          },
        ),
      ),
    );
  }
}
