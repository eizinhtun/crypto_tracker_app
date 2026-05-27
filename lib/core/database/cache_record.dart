import 'package:hive/hive.dart';

class CacheRecord {
  const CacheRecord({
    required this.payload,
    required this.cachedAt,
    required this.ttl,
  });

  final Object payload;
  final DateTime cachedAt;
  final Duration ttl;

  DateTime get expiresAt => cachedAt.add(ttl);

  bool isExpired(DateTime now) {
    return !expiresAt.isAfter(now.toUtc());
  }
}

class CacheRecordAdapter extends TypeAdapter<CacheRecord> {
  static const adapterTypeId = 42;

  @override
  int get typeId => adapterTypeId;

  @override
  CacheRecord read(BinaryReader reader) {
    final values = reader.read();
    if (values is! List || values.length < 3) {
      return CacheRecord(
        payload: const <String, Object?>{},
        cachedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        ttl: Duration.zero,
      );
    }

    final cachedAt = DateTime.tryParse(values[1].toString())?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final ttlMilliseconds = values[2] is int
        ? values[2] as int
        : int.tryParse(values[2].toString()) ?? 0;

    return CacheRecord(
      payload: values[0] as Object? ?? const <String, Object?>{},
      cachedAt: cachedAt,
      ttl: Duration(milliseconds: ttlMilliseconds),
    );
  }

  @override
  void write(BinaryWriter writer, CacheRecord obj) {
    writer.write([
      obj.payload,
      obj.cachedAt.toUtc().toIso8601String(),
      obj.ttl.inMilliseconds,
    ]);
  }
}
