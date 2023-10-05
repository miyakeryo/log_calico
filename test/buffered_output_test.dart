import 'package:flutter_test/flutter_test.dart';
import 'package:log_calico/log_calico.dart';

class _TestLogOutput extends BufferedOutput {
  _TestLogOutput(LocalLogStorage storage)
      : super(
          tagPattern: '**',
          logStorage: storage,
          flushInterval: 0,
          retryLimit: 1,
        );

  final errorLogsList = <List<Log>>[];
  final wroteLogsList = <List<Log>>[];
  var willCauseError = false;

  @override
  Future<bool> write(List<Log> logs) async {
    if (willCauseError) {
      errorLogsList.add(logs);
      return false;
    } else {
      wroteLogsList.add(logs);
      return true;
    }
  }
}

void main() {
  late Logger logger;
  late _TestLogOutput output;

  setUp(() async {
    final storage = LocalLogStorage();
    output = _TestLogOutput(storage);

    final localStorage = await storage.localStorage(output.storageHash);
    await localStorage.clear();

    logger = Logger(outputs: [output]);
    logger.start();
  });

  Future<void> wait([int milliseconds = 100]) {
    return Future<void>.delayed(Duration(milliseconds: 100));
  }

  group('Logger#post', () {
    test('success', () async {
      final payload = {'foo': 'bar', 'baz': 123};
      logger.post(payload);
      await wait();
      expect(output.errorLogsList, isEmpty);
      expect(output.wroteLogsList.length, 1);
      expect(output.wroteLogsList[0].length, 1);
      expect(output.wroteLogsList[0][0].payload, payload);
    });

    test('failed', () async {
      output.willCauseError = true;
      final payload = {'foo': 'bar', 'baz': 123};
      logger.post(payload);
      await wait();
      expect(output.errorLogsList.length, output.retryLimit + 1);
      expect(output.wroteLogsList, isEmpty);
    });
  });

  group('Logger#resume', () {
    test('success', () async {
      output.willCauseError = true;
      final payload = {'foo': 'bar', 'baz': 123};
      logger.post(payload);
      await wait();
      expect(output.errorLogsList.length, output.retryLimit + 1);
      expect(output.wroteLogsList, isEmpty);

      logger.suspend();
      output.errorLogsList.clear();
      output.willCauseError = false;

      await logger.resume();
      await wait();
      expect(output.errorLogsList, isEmpty);
      expect(output.wroteLogsList.length, 1);
      expect(output.wroteLogsList[0].length, 1);
      expect(output.wroteLogsList[0][0].payload, payload);
    });

    test('failed and resume', () async {
      output.willCauseError = true;
      final payload = {'foo': 'bar', 'baz': 123};
      logger.post(payload);
      await wait();

      logger.suspend();
      output.errorLogsList.clear();

      await logger.resume();
      await wait();
      expect(output.errorLogsList.length, output.retryLimit + 1);
      expect(output.wroteLogsList, isEmpty);

      logger.suspend();
      output.errorLogsList.clear();
      output.willCauseError = false;

      await logger.resume();
      await wait();
      expect(output.errorLogsList, isEmpty);
      expect(output.wroteLogsList.length, 1);
      expect(output.wroteLogsList[0].length, 1);
      expect(output.wroteLogsList[0][0].payload, payload);
    });
  });
}
