import 'package:collection/collection.dart';

class TagPattern {
  final String pattern;

  const TagPattern(this.pattern);

  bool match(String tag) {
    if (tag == pattern) {
      return true;
    }

    final tagElements = tag.split('.');
    final patternElements = pattern.split('.');

    final tagLast = tagElements.lastOrNull;
    final patternLast = patternElements.lastOrNull;

    if (tagLast == null || patternLast == null) {
      return false;
    }

    if ((patternLast == '**' && tagElements.length >= patternElements.length) ||
        (patternLast == '*' && tagElements.length == patternElements.length)) {
      for (int i = 0; i < patternElements.length - 1; i++) {
        if (tagElements[i] != patternElements[i]) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }
}
