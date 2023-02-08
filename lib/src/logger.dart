import 'dart:async';

import 'filter.dart';
import 'log.dart';
import 'output.dart';

class Logger {
  final _streamController = StreamController<Log>.broadcast();
  final List<Output> _outputs;
  var globalParams = <String, Object?>{};

  Logger({
    List<Filter>? filters,
    required List<Output> outputs,
  }) : _outputs = outputs {
    if (filters != null && filters.length > 0) {
      filters.forEach((filter) {
        _streamController.stream
            .where(filter.where)
            .transform(filter.streamTransformer)
            .where((logs) => logs.isNotEmpty)
            .listen(
          (logs) {
            logs.forEach((log) {
              outputs
                  .where((output) => output.where(log))
                  .forEach((output) => output.emit(log));
            });
          },
        );
      });
    } else {
      _streamController.stream.listen((log) {
        outputs
            .where((output) => output.where(log))
            .forEach((output) => output.emit(log));
      });
    }
  }

  void dispose() async {
    await _streamController.close();
    final outputs = _outputs;
    _outputs.clear();
    Future.microtask(() {
      outputs.forEach((output) => output.dispose());
    });
  }

  void post(Map<String, Object?> payload, {String tag = ''}) {
    final params = Map<String, Object?>.from(globalParams);
    params.addAll(payload);
    _streamController.sink.add(
      Log(
        payload: params,
        tag: tag,
        loggedAt: DateTime.now(),
      ),
    );
  }

  Future<void> start() {
    return Future.forEach(_outputs, (output) => output.start());
  }

  Future<void> suspend() {
    return Future.microtask(() {
      return Future.forEach(_outputs, (output) => output.suspend());
    });
  }

  Future<void> resume() {
    return Future.microtask(() {
      return Future.forEach(_outputs, (output) => output.resume());
    });
  }
}
