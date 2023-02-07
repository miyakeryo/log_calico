import 'package:log_calico/log_calico.dart';

class PrintOutput extends Output {
  PrintOutput(super.pattern, {super.shouldEmit});

  @override
  Future<void> emit(Log log) async {
    print('${log.loggedAt}:[${log.tag}] ${log.payload}');
  }
}
