import 'package:log_calico/log_calico.dart';

class MyLogOutput extends BufferedOutput {
  MyLogOutput({
    required super.tagPattern,
    super.flushInterval = 100,
    super.retryLimit = 3,
    super.logCountLimit = 5,
    LogStorage? logStorage,
  }) : super(logStorage: logStorage ?? LocalLogStorage());

  @override
  Future<bool> write(List<Log> logs) async {
    // TODO: send logs to your server.
    return Future<bool>.delayed(Duration(milliseconds: 50), () {
      logs.forEach((log) {
        final eventName = log.payload['event_name'];
        final properties = log.payload['properties'];
        print('🥝[MyLog] ${log.loggedAt}:[$eventName] $properties');
      });

      /// if return false, retrying.
      return true;
    });
  }
}
