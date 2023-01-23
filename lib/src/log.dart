import 'dart:convert';

import 'package:collection/collection.dart';

class Log {
  final Map<String, Object> payload;
  final String tag;
  final DateTime loggedAt;

  Log({
    required this.payload,
    required this.tag,
    DateTime? loggedAt,
  }) : loggedAt = loggedAt ?? DateTime.now();

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other.hashCode == hashCode;
  }

  @override
  int get hashCode => Object.hash(payload, tag, loggedAt, super.hashCode);

  Log copyWith({
    Map<String, Object>? payload,
    String? tag,
    DateTime? loggedAt,
  }) {
    return Log(
      payload: payload ?? this.payload,
      tag: tag ?? this.tag,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  ///
  /// Throws [FormatException] if the input is not valid Map type JSON text.
  factory Log.fromJsonString(String jsonString) {
    final map = json.decode(jsonString);
    if (map is! Map) {
      throw FormatException('jsonString is not Map (${map.runtimeType})');
    }
    return Log.fromMap(map);
  }

  ///
  /// Throws [TypeError] if the input does not have valid parameters.
  factory Log.fromMap(Map map) {
    return Log(
      payload: (map['payload'] as Map).cast<String, Object>(),
      tag: map['tag'] as String,
      loggedAt: DateTime.fromMillisecondsSinceEpoch(map['loggedAt'] as int),
    );
  }

  static Log? tryFromMap(Map map) {
    try {
      return Log.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  String get toJsonString {
    final map = {
      'payload': payload,
      'tag': tag,
      'loggedAt': loggedAt.millisecondsSinceEpoch,
    };
    return json.encode(map);
  }
}

extension LogList on Iterable<Log> {
  String get toJsonString {
    return '[${map((log) => log.toJsonString).join(',')}]';
  }

  ///
  /// Throws [FormatException] if the input is not valid List type JSON text.
  static List<Log> fromJsonString(String jsonString) {
    final list = json.decode(jsonString);
    if (list is! List) {
      throw FormatException('jsonString is not List (${list.runtimeType})');
    }
    return list.cast<Map>().map(Log.tryFromMap).whereNotNull().toList();
  }
}
