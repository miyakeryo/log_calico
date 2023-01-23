import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Map#cast', () {
    test('no error', () {
      final dynamic map = {
        'a': 's',
        'b': true,
        'c': 123,
        'd': 4.56,
        'e': null,
        'f': [1, 2, 3],
        'g': ['1', '2'],
        'h': <String, Object>{
          'A': 1,
          'B': '2',
          'C': 3.4,
          'D': false,
        },
      };
      expect(map, isA<Map>());
      final payload = (map as Map).cast<String, Object>();
      expect(payload, isA<Map<String, Object>>());
    });

    test('cast error', () {
      final dynamic map = {
        'a': 's',
        'b': true,
        'c': 123,
        1: 4.56,
      };
      expect(
        (map as Map).cast<String, Object>,
        throwsA(isA<TypeError>()),
      );
    });
  });
}
