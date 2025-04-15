import 'dart:convert';
import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/logger.dart';

Future<void> showStudentLoginQrCode(
  BuildContext context,
  StudentQrModel student,
) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => StudentLoginQrCode(student: student),
    ),
  );
}

class StudentLoginQrCode extends StatelessWidget {
  const StudentLoginQrCode({super.key, required this.student});
  final StudentQrModel student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student.secondName}, ${student.firstName}'),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.info),
            title: Text(
              'Der Schüler muss diesen QR-Code scannen, um sich einzuloggen',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Theme.of(context).colorScheme.secondary,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.school, size: 32),
                        Text(
                          ' ${student.secondName}, ${student.firstName}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Center(
                    child: QrImageView(
                      data: student.createLoginToken(),
                      version: QrVersions.auto,
                      gapless: true,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                      left: 16,
                      bottom: 12,
                      top: 0,
                    ),
                    child: Text(
                      student.id,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Schließen'),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentQrModel {
  const StudentQrModel({
    required this.secondName,
    required this.firstName,
    required this.id,
    required this.teacherCreatedId,
    required this.courseId,
    required this.password,
    required this.email,
  });

  final String secondName;

  final String firstName;

  final String id;
  final String teacherCreatedId;
  final String courseId;
  final String password;
  final String email;

  // not ment for encryption, just to make sure, no one scans the qr code and puts it into cyberchef or something
  static en.Encrypter get encrypt => en.Encrypter(
    en.AES(
      en.Key.fromUtf8('12345678901dD456L8f01w34W6789012'),
      mode: en.AESMode.cbc,
      padding: 'PKCS7',
    ),
  );

  String createLoginToken() {
    final data = {
      'id': id,
      'courseId': courseId,
      'teacherCreatedId': teacherCreatedId,
      'secret': password,
      'firstName': firstName,
      'secondName': secondName,
      'email': email,
    };
    final jsonString = jsonEncode(data);

    final iv = en.IV.fromSecureRandom(16);

    final encrypted = encrypt.encrypt(jsonString, iv: iv);
    final e = '${iv.base64}:${encrypted.base64}';
    logger.d(e);
    return e;
  }

  factory StudentQrModel.fromLoginToken(String token) {
    final split = token.split(':');
    final iv = en.IV.fromBase64(split[0]);
    final encrypted = en.Encrypted.fromBase64(split[1]);
    final decrypted = encrypt.decrypt(encrypted, iv: iv);
    final data = jsonDecode(decrypted);

    return StudentQrModel(
      secondName: data['secondName'],
      firstName: data['firstName'],
      id: data['id'],
      teacherCreatedId: data['teacherCreatedId'],
      courseId: data['courseId'],
      password: data['secret'],
      email: data['email'],
    );
  }

  factory StudentQrModel.fromRecordModel(RecordModel record) {
    return StudentQrModel(
      secondName: record.data['secondName'],
      firstName: record.data['firstName'],
      id: record.id,
      teacherCreatedId: record.data['createdByTeacher'],
      courseId: record.data['course'],
      password: record.data['clearTextPassword'],
      email: record.data['email'],
    );
  }
}
