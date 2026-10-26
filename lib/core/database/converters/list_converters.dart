import 'dart:convert';

import 'package:drift/drift.dart';

/// Drift [TypeConverter] storing a list of strings as a JSON-encoded string.
class StringListConverter extends TypeConverter<List<String>, String> {
  /// Default const constructor.
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    try {
      final decoded = json.decode(fromDb);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return const [];
    } on Object catch (_) {
      return const [];
    }
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

/// Drift [TypeConverter] storing a list of integers as a JSON-encoded string.
class IntListConverter extends TypeConverter<List<int>, String> {
  /// Default const constructor.
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    try {
      final decoded = json.decode(fromDb);
      if (decoded is List) {
        return decoded
            .map((e) => int.tryParse(e.toString()))
            .whereType<int>()
            .toList();
      }
      return const [];
    } on Object catch (_) {
      return const [];
    }
  }

  @override
  String toSql(List<int> value) {
    return json.encode(value);
  }
}
