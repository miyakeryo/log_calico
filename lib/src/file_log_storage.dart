import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import 'log.dart';
import 'log_storage.dart';

class FileLogStorage extends LogStorage {
  final _storedLogs = <Log>[];
  final _lock = Lock();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String storageHash) async {
    final path = await _localPath;
    return File('$path/$storageHash');
  }

  Future<List<Log>> retrieveLogs(String storageHash) async {
    final storedLogs = <Log>[];
    final file = await _localFile(storageHash);
    if (await file.exists()) {
      final contents = await file.readAsString();
      await _lock.synchronized(() async {
        _storedLogs.clear();
        try {
          final logs = LogList.fromJsonString(contents);
          _storedLogs.addAll(logs);
        } catch (_) {}
        storedLogs.addAll(_storedLogs);
      });
    } else {
      storedLogs.addAll(_storedLogs);
    }
    return storedLogs;
  }

  Future<void> add(List<Log> logs, String storageHash) async {
    final storedLogs = <Log>[];
    await _lock.synchronized(() async {
      _storedLogs.addAll(logs);
      storedLogs.addAll(_storedLogs);
      await _save(storedLogs, storageHash);
    });
  }

  Future<void> remove(List<Log> logs, String storageHash) async {
    final storedLogs = <Log>[];
    await _lock.synchronized(() async {
      _storedLogs.removeWhere(logs.contains);
      storedLogs.addAll(_storedLogs);
      await _save(storedLogs, storageHash);
    });
  }

  Future<void> _save(List<Log> logs, String storageHash) async {
    final file = await _localFile(storageHash);
    await file.writeAsString(logs.toJsonString);
  }
}
