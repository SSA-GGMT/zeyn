import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeyn/api/pocketbase.dart';
import 'package:zeyn/components/shared/student_qr_login_screen.dart';
import 'package:zeyn/utils/dialogs/show_confirm_dialog.dart';
import 'package:zeyn/utils/dialogs/show_error_dialog.dart';
import 'package:zeyn/utils/dialogs/show_loading_dialog.dart';
import 'package:zeyn/utils/logger.dart';

class LoginRouteScreen extends StatefulWidget {
  final Map<String, String> queryParams;
  const LoginRouteScreen({super.key, required this.queryParams});

  @override
  State<LoginRouteScreen> createState() => _LoginRouteScreenState();
}

class _LoginRouteScreenState extends State<LoginRouteScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLogin();
    });
  }

  void handleLogin() async {
    if (pb.authStore.isValid) {
      final result = await showConfirmDialog(context, message: "Möchtest du dich wirklich abmelden? Du bist bereits angemeldet.");
      if (result == false && mounted) {
        context.go('/');
        return;
      }
    }

    try {
      if (widget.queryParams["token"] == null && mounted) {
        context.go('/');
        return;
      }
      showLoadingDialog(context, message: "Automatische Anmeldung...");
      final loginAuthRecord = StudentQrModel.fromLoginToken(widget.queryParams["token"]!);
      await pb
          .collection('students')
          .authWithPassword(
        loginAuthRecord.email,
        loginAuthRecord.password,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      context.go('/');
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      await showErrorDialog(context, message: "Automatische Anmeldung fehlgeschlagen. Bitte versuche es erneut.");
      if (!mounted) return;
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automatische Anmeldung'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}