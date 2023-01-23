import 'package:log_calico/log_calico.dart';

class PageViewFilter extends Filter {
  PageViewFilter({required super.tagPattern});

  @override
  List<Log> transform(Log log) {
    final name = log.payload['name'];
    if (name is! String) {
      return [];
    } else {
      return [
        log.copyWith(
          tag: 'ga.pageview',
          payload: {
            'event_name': 'pageview',
            'properties': log.payload,
          },
        ),
        log.copyWith(
          tag: 'my.pageview',
          payload: {
            'event_name': 'pageview_$name',
            'properties': Map.of(log.payload)..remove('name'),
          },
        ),
      ];
    }
  }
}
