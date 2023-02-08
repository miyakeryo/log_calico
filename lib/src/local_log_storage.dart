import 'package:localstorage/localstorage.dart';
import 'package:synchronized/synchronized.dart';

import 'log.dart';
import 'log_storage.dart';

class LocalLogStorage extends LogStorage {
  static const itemName = 'logs';
  final _storedLogs = <Log>[];
  final _lock = Lock();

  Future<LocalStorage> _localStorage(String storageHash) async {
    final storage = LocalStorage(storageHash);
    await storage.ready;
    return storage;
  }

  Future<List<Log>> retrieveLogs(String storageHash) async {
    final storedLogs = <Log>[];
    final storage = await _localStorage(storageHash);
    final contents = await storage.getItem(itemName);
    if (contents is String) {
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
    final storage = await _localStorage(storageHash);
    await storage.setItem(itemName, logs.toJsonString);
  }
}
