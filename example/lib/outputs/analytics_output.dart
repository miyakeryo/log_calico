import 'package:log_calico/log_calico.dart';

class AnalyticsOutput extends BufferedOutput {
  AnalyticsOutput({
    required super.tagPattern,
    super.flushInterval = 100,
    super.retryLimit = 3,
    super.logCountLimit = 5,
    LogStorage? logStorage,
  }) : super(logStorage: logStorage ?? LocalLogStorage());

  @override
  Future<bool> write(List<Log> logs) async {
    // TODO: send logs to analytics service
    return Future<bool>.delayed(Duration(milliseconds: 50), () {
      logs.forEach((log) {
        final eventName = log.payload['event_name'];
        final properties = log.payload['properties'];
        print('🍉[Analytics] ${log.loggedAt}:[$eventName] $properties');
      });

      /// if return false, retrying.
      return true;
    });
  }
}
