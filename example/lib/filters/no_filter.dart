import 'package:log_calico/log_calico.dart';

class NoFilter extends Filter {
  NoFilter() : super(tagPattern: '**');

  @override
  List<Log> transform(Log log) => [log];
}
