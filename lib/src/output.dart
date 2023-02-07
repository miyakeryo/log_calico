import 'log.dart';
import 'tag_pattern.dart';

abstract class Output {
  final Pattern pattern;
  final bool Function(Log)? shouldEmit;

  Output(Pattern pattern, {this.shouldEmit})
      : pattern = pattern is String ? TagPattern(pattern) : pattern;

  const Output.tag(TagPattern tagPattern, {this.shouldEmit})
      : pattern = tagPattern;

  bool where(Log log) {
    return (Pattern pattern) {
          if (pattern is TagPattern) {
            return pattern.match(log.tag);
          } else {
            return pattern.allMatches(log.tag).isNotEmpty;
          }
        }(this.pattern) &&
        shouldEmit?.call(log) != false;
  }

  void dispose() async {}
  Future<void> start() async {}
  Future<void> resume() async {}
  Future<void> suspend() async {}

  Future<void> emit(Log log);

  Future<bool> write(List<Log> logs) async {
    /// if return false, retrying.
    return true;
  }
}
