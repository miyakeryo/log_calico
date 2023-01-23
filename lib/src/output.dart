import 'log.dart';
import 'tag_pattern.dart';

abstract class Output {
  final TagPattern tagPattern;
  final bool Function(Log)? shouldEmit;

  Output({required String tagPattern, this.shouldEmit})
      : this.tagPattern = TagPattern(tagPattern);

  bool where(Log log) {
    return tagPattern.match(log.tag) && shouldEmit?.call(log) != false;
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
