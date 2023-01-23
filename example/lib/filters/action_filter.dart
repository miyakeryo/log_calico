import 'package:log_calico/log_calico.dart';

class ActionFilter extends Filter {
  ActionFilter({required super.tagPattern});

  @override
  List<Log> transform(Log log) {
    final target = log.payload['target'];
    final type = log.payload['type'];
    if (target is! String || type is! String) {
      return [];
    } else {
      final properties = Map.of(log.payload)..remove('type');
      return [
        log.copyWith(
          tag: 'ga.action',
          payload: {
            'event_name': type,
            'properties': properties,
          },
        ),
        log.copyWith(
          tag: 'my.action',
          payload: {
            'event_name': '${type}_$target',
            'properties': Map.of(properties)..remove('target'),
          },
        ),
      ];
    }
  }
}
