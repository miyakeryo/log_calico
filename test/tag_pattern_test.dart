import 'package:flutter_test/flutter_test.dart';

import '../lib/src/tag_pattern.dart';

void main() {
  group('TagPattern#match', () {
    test('use no wildcard', () {
      expect(TagPattern('aa.bb.cc').match('aa.bb.cc'), true);
      expect(TagPattern('aa.bb.cc').match('aa.bb.dd'), false);
      expect(TagPattern('aa.bb.cc').match('aa.bb'), false);
      expect(TagPattern('aa.bb.cc').match('aa.bb.cc.dd'), false);
    });

    test('use one wildcard with tag', () {
      expect(TagPattern('aa.bb.*').match('aa.bb.cc'), true);
      expect(TagPattern('aa.bb.*').match('aa.bb.dd'), true);
      expect(TagPattern('aa.bb.*').match('aa.bb'), false);
      expect(TagPattern('aa.bb.*').match('aa.bb.cc.dd'), false);
      expect(TagPattern('aa.bb.*').match('aa.ee.ff'), false);
    });

    test('use double wildcard with tag', () {
      expect(TagPattern('aa.**').match('aa.bb.cc'), true);
      expect(TagPattern('aa.**').match('aa.bb.dd'), true);
      expect(TagPattern('aa.**').match('aa.bb'), true);
      expect(TagPattern('aa.**').match('aa.bb.cc.dd'), true);
      expect(TagPattern('aa.**').match('aa.ee.ff'), true);
      expect(TagPattern('aa.**').match('aa'), false);
      expect(TagPattern('aa.**').match('gg'), false);
      expect(TagPattern('aa.**').match('gg.hh'), false);
    });

    test('use only one wildcard', () {
      expect(TagPattern('*').match('aa.bb.cc'), false);
      expect(TagPattern('*').match('aa.bb.dd'), false);
      expect(TagPattern('*').match('aa.bb'), false);
      expect(TagPattern('*').match('aa.bb.cc.dd'), false);
      expect(TagPattern('*').match('aa.ee.ff'), false);
      expect(TagPattern('*').match('aa'), true);
      expect(TagPattern('*').match('gg'), true);
      expect(TagPattern('*').match('gg.hh'), false);
    });

    test('use only double wildcard', () {
      expect(TagPattern('**').match('aa.bb.cc'), true);
      expect(TagPattern('**').match('aa.bb.dd'), true);
      expect(TagPattern('**').match('aa.bb'), true);
      expect(TagPattern('**').match('aa.bb.cc.dd'), true);
      expect(TagPattern('**').match('aa.ee.ff'), true);
      expect(TagPattern('**').match('aa'), true);
      expect(TagPattern('**').match('gg'), true);
      expect(TagPattern('**').match('gg.hh'), true);
    });
  });
}
