import 'dart:math';

String passwordGenerator({length = 12}) {
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';
  final Random random = Random();
  String password = '';
  for (int i = 0; i < length; i++) {
    password += chars[random.nextInt(chars.length)];
  }
  return password;
}
