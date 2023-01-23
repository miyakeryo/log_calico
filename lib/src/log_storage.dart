import 'log.dart';

abstract class LogStorage {
  void prepare() {}
  void dispose() {}
  Future<List<Log>> retrieveLogs(String storageHash);
  Future<void> add(List<Log> logs, String storageHash);
  Future<void> remove(List<Log> logs, String storageHash);
}
