import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:localstorage/localstorage.dart';
import 'package:log_calico/log_calico.dart';

String randomString({int length = 24}) {
  final rand = math.Random.secure();
  final charCodes = List.generate(
    length,
    (_) => rand.nextInt(0x7E - 0x21) + 0x21,
  );
  return String.fromCharCodes(charCodes);
}

void main() {
  late LocalLogStorage storage;
  late String storageHash;
  late LocalStorage localStorage;

  setUp(() async {
    storage = LocalLogStorage();
    storageHash = randomString();
    localStorage = await storage.localStorage(storageHash);
    await localStorage.clear();
  });

  group('LocalLogStorage#prepare', () {
    test('prepare', () {
      expect(() => storage.prepare(), returnsNormally);
    });
  });

  group('LocalLogStorage#dispose', () {
    test('dispose', () {
      expect(() => storage.dispose(), returnsNormally);
    });
  });

  group('LocalLogStorage#localStorage', () {
    test('localStorage', () async {
      final localStorage = await storage.localStorage(randomString());
      expectLater(localStorage.ready, completion(isTrue));
    });
  });

  group('LocalLogStorage#retrieveLogs', () {
    test('retrieve no logs', () async {
      final logs = await storage.retrieveLogs(storageHash);
      expect(logs, isEmpty);
    });

    test('retrieve 1 log', () async {
      final logs = [
        Log(payload: {'foo': 'bar', 'baz': 123}, tag: 'tag1'),
      ];
      await storage.add(logs, storageHash);

      final logs2 = await storage.retrieveLogs(storageHash);
      expect(logs2.length, logs.length);
    });

    test('retrieve 100 log2', () async {
      final logs = List.generate(
        100,
        (i) => Log(payload: {'foo': randomString(), 'baz': i}, tag: 'tag1'),
      );

      await storage.add(logs, storageHash);

      final logs2 = await storage.retrieveLogs(storageHash);
      expect(logs2.length, logs.length);
      logs2.asMap().entries.forEach((e) {
        expect(e.value, logs[e.key]);
      });
    });
  });

  group('LocalLogStorage#add', () {
    test('add 1 log', () async {
      final logs = [
        Log(payload: {'foo': 'bar', 'baz': 123}, tag: 'tag1'),
      ];
      await storage.add(logs, storageHash);

      final contents = await localStorage.getItem(LocalLogStorage.itemName);
      final logs2 = LogList.fromJsonString(contents);
      expect(logs2.length, logs.length);
      expect(logs2[0], logs[0]);
    });

    test('add 2 logs', () async {
      final logs = [
        Log(payload: {'foo': 'bar', 'baz': 123}, tag: 'tag1'),
        Log(payload: {'goo': 'nar', 'naz': 456}, tag: 'tag2'),
      ];
      await storage.add(logs, storageHash);

      final contents = await localStorage.getItem(LocalLogStorage.itemName);
      final logs2 = LogList.fromJsonString(contents);
      expect(logs2.length, logs.length);
      expect(logs2[0], logs[0]);
      expect(logs2[1], logs[1]);
    });
  });

  group('LocalLogStorage#remove', () {
    test('remove', () async {
      final logs = [
        Log(payload: {'foo': 'bar', 'baz': 123}, tag: 'tag1'),
      ];
      await storage.add(logs, storageHash);
      await storage.remove(logs, storageHash);

      final contents = await localStorage.getItem(LocalLogStorage.itemName);
      final logs2 = LogList.fromJsonString(contents);
      expect(logs2, isEmpty);
    });
  });
}
