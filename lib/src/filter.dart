import 'dart:async';

import 'log.dart';
import 'tag_pattern.dart';

abstract class Filter {
  final Pattern pattern;

  Filter(Pattern pattern)
      : pattern = pattern is String ? TagPattern(pattern) : pattern;

  const Filter.tag(TagPattern tagPattern) : pattern = tagPattern;

  List<Log> transform(Log log);

  bool where(Log log) {
    return (Pattern pattern) {
      if (pattern is TagPattern) {
        return pattern.match(log.tag);
      } else {
        return pattern.allMatches(log.tag).isNotEmpty;
      }
    }(this.pattern);
  }

  StreamTransformer<Log, List<Log>> get streamTransformer {
    return StreamTransformer<Log, List<Log>>.fromHandlers(
        handleData: (log, sink) {
      sink.add(transform(log));
    });
  }
}
