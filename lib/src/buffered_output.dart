import 'dart:async';
import 'dart:math' show pow;

import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import 'log.dart';
import 'log_storage.dart';
import 'output.dart';

int _defaultRetryMillisecondsDelay(int retryCount) {
  return 2 * pow(2, retryCount - 1).round();
}

class BufferedOutput extends Output {
  final LogStorage _logStorage;
  final int flushInterval;
  final int retryLimit;
  final int logCountLimit;
  final int Function(int) retryMillisecondsDelay;
  Timer? _timer;
  final _buffer = <Log>[];
  final _chunks = <BufferChunk>[];
  final _lock = Lock();

  BufferedOutput({
    required super.tagPattern,
    required LogStorage logStorage,
    this.flushInterval = 100,
    this.retryLimit = 3,
    this.logCountLimit = 5,
    this.retryMillisecondsDelay = _defaultRetryMillisecondsDelay,
  }) : this._logStorage = logStorage {
    _logStorage.prepare();
  }

  @override
  @mustCallSuper
  void dispose() {
    _stopTimer();
    _logStorage.dispose();
  }

  @override
  Future<void> start() {
    return resume();
  }

  @override
  @mustCallSuper
  Future<void> resume() async {
    await _reloadLogStorage();
    await _flush();
    _startTimer();
  }

  @override
  @mustCallSuper
  Future<void> suspend() async {
    _stopTimer();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(Duration(milliseconds: flushInterval), (timer) {
      _flush();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> emit(Log log) async {
    await _lock.synchronized(() {
      _buffer.add(log);
    });
    unawaited(_logStorage.add([log], storageHash));
    if (_buffer.length >= logCountLimit) {
      await _flush();
    }
  }

  Future<void> _flush() async {
    if (_buffer.length == 0) {
      return;
    }

    final chunk = await _lock.synchronized(() {
      final List<Log> logs;
      if (logCountLimit < _buffer.length) {
        logs = _buffer.sublist(0, logCountLimit);
        _buffer.removeRange(0, logCountLimit);
      } else {
        logs = List<Log>.of(_buffer);
        _buffer.clear();
      }
      final chunk = BufferChunk(logs);
      _chunks.add(chunk);
      return chunk;
    });

    await _writeChunk(chunk);
  }

  Future<void> _writeChunk(BufferChunk chunk) async {
    if (await write(chunk.logs)) {
      await _lock.synchronized(() {
        _chunks.remove(chunk);
      });
      unawaited(_logStorage.remove(chunk.logs, storageHash));
    } else {
      chunk.retryCount++;
      if (chunk.retryCount <= retryLimit) {
        final delay = retryMillisecondsDelay(chunk.retryCount);
        unawaited(Future<void>.delayed(Duration(milliseconds: delay), () {
          _writeChunk(chunk);
        }));
      } else {
        await _lock.synchronized(() {
          _chunks.remove(chunk);
        });
      }
    }
  }

  String get storageHash =>
      '${this.runtimeType.hashCode}_${tagPattern.pattern.hashCode}';

  Future<void> _reloadLogStorage() async {
    final logs = await _logStorage.retrieveLogs(storageHash);
    final filteredLogs = logs.where((log) {
      return _chunks.indexWhere((chunk) => chunk.logs.contains(log)) < 0;
    });
    await _lock.synchronized(() {
      _buffer.clear();
      _buffer.addAll(filteredLogs);
    });
  }

  @override
  Future<bool> write(List<Log> logs) async {
    /// if return false, retrying.
    return false;
  }
}

class BufferChunk {
  final List<Log> logs;
  int retryCount = 0;

  BufferChunk(this.logs);

  @override
  bool operator ==(Object other) =>
      other is BufferChunk &&
      logs.length == other.logs.length &&
      hashCode == other.hashCode;

  String get toJsonString => logs.toJsonString;

  @override
  int get hashCode => toJsonString.hashCode;
}
