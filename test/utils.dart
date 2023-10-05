import 'dart:math' as math;

String randomString({int length = 24}) {
  final rand = math.Random.secure();
  final charCodes = List.generate(
    length,
    (_) => rand.nextInt(0x7E - 0x21) + 0x21,
  );
  return String.fromCharCodes(charCodes);
}
