import 'package:collection/collection.dart';

class TagPattern implements Pattern {
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

  @override
  String toString() => 'TagPattern:$pattern';

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) {
    return [if (match(string)) _TagPatternMatch(this, string)];
  }

  @override
  Match? matchAsPrefix(String string, [int start = 0]) {
    return match(string) ? _TagPatternMatch(this, string) : null;
  }
}

class _TagPatternMatch implements Match {
  @override
  final TagPattern pattern;
  @override
  final String input;

  const _TagPatternMatch(this.pattern, this.input);

  @override
  int get start => 0;
  @override
  int get end => input.length;

  @override
  int get groupCount => 1;
  @override
  String? operator [](int group) => group == 0 ? input : null;
  @override
  String? group(int group) => this[group];
  @override
  List<String?> groups(List<int> groupIndices) => [input];
}
