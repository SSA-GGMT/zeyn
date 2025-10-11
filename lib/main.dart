import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:zeyn/api/pocketbase.dart';
import 'package:zeyn/views/admin/admin_home_view.dart';
import 'package:zeyn/views/login_route_screen.dart';
import 'package:zeyn/views/login_screen.dart';
import 'package:zeyn/views/students/student_home_view.dart';
import 'package:zeyn/views/teachers/teacher_home_view.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder:
          (context, state) => Scaffold(
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
    ),
    GoRoute(
      path: ('/login'),
      builder:
          (context, state) =>
              LoginRouteScreen(queryParams: state.uri.queryParameters),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPocketbase();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zeyn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[900]!),
        useMaterial3: true,
        sliderTheme: const SliderThemeData(year2023: false),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue[900]!,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        sliderTheme: const SliderThemeData(year2023: false),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
