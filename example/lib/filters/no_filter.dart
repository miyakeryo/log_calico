import 'package:log_calico/log_calico.dart';

class NoFilter extends Filter {
  const NoFilter() : super.tag(const TagPattern('**'));

  @override
  List<Log> transform(Log log) => [log];
}
