import 'package:localstorage/localstorage.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import 'log.dart';
import 'log_storage.dart';

class LocalLogStorage extends LogStorage {
  static const itemName = 'logs';
  final _storedLogs = <Log>[];
  final _lock = Lock();
  final _storageMap = <String, LocalStorage>{};

  @override
  void dispose() {
    _storageMap.values.forEach((storage) => storage.dispose());
  }

  @visibleForTesting
  Future<LocalStorage> localStorage(String storageHash) async {
    if (_storageMap.containsKey(storageHash)) {
      return _storageMap[storageHash]!;
    }
    final storage = LocalStorage(storageHash);
    try {
      await storage.ready;
    } catch (_) {
      /// If the file is corrupted, delete it.
      await storage.clear();
    }
    _storageMap[storageHash] = storage;
    return storage;
  }

  @override
  Future<List<Log>> retrieveLogs(String storageHash) async {
    final storedLogs = <Log>[];
    final storage = await localStorage(storageHash);
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

  @override
  Future<void> add(List<Log> logs, String storageHash) async {
    final storedLogs = <Log>[];

    await _lock.synchronized(() async {
      _storedLogs.addAll(logs);
      storedLogs.addAll(_storedLogs);
      await _save(storedLogs, storageHash);
    });
  }

  @override
  Future<void> remove(List<Log> logs, String storageHash) async {
    final storedLogs = <Log>[];
    await _lock.synchronized(() async {
      _storedLogs.removeWhere(logs.contains);
      storedLogs.addAll(_storedLogs);
      await _save(storedLogs, storageHash);
    });
  }

  Future<void> _save(List<Log> logs, String storageHash) async {
    final storage = await localStorage(storageHash);
    await storage.setItem(itemName, logs.toJsonString);
  }
}
