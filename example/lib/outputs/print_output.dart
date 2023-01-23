import 'package:log_calico/log_calico.dart';

class PrintOutput extends Output {
  PrintOutput({required super.tagPattern, super.shouldEmit});

  @override
  Future<void> emit(Log log) async {
    print('${log.loggedAt}:[${log.tag}] ${log.payload}');
  }
}
