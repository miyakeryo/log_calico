import 'package:log_calico/log_calico.dart';

class PageViewFilter extends Filter {
  PageViewFilter(super.pattern);

  @override
  List<Log> transform(Log log) {
    final name = log.payload['name'];
    if (name is! String) {
      return [];
    } else {
      return [
        log.copyWith(
          tag: 'ga.page_view',
          payload: {
            'event_name': 'page_view',
            'properties': log.payload,
          },
        ),
        log.copyWith(
          tag: 'my.page_view',
          payload: {
            'event_name': 'page_view_$name',
            'properties': Map.of(log.payload)..remove('name'),
          },
        ),
      ];
    }
  }
}
