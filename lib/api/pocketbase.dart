import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

late final FlutterSecureStorage secureStorage;

late final PocketBase pb;

Future<void> initPocketbase() async {
  secureStorage = const FlutterSecureStorage();
  final store = AsyncAuthStore(
    save: (String data) async =>
        await secureStorage.write(key: 'pb_auth', value: data),
    initial: await secureStorage.read(key: 'pb_auth'),
  );
  pb = PocketBase(
    'https://app.zeyn.meinschulamt-ruesselsheim.de/',
    authStore: store,
  );
}
