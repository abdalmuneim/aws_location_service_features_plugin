import '../entities/geo_point.dart';

/// Helpers for reading and writing Amazon Location JSON payloads.
abstract final class JsonUtils {
  /// Removes nulls, empty strings, empty lists and empty maps recursively so
  /// optional fields are omitted from request bodies.
  static Map<String, Object?> compact(Map<String, Object?> input) {
    final out = <String, Object?>{};
    input.forEach((key, value) {
      final cleaned = _compactValue(value);
      if (cleaned != null) out[key] = cleaned;
    });
    return out;
  }

  static Object? _compactValue(Object? value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is Map<String, Object?>) {
      final map = compact(value);
      return map.isEmpty ? null : map;
    }
    if (value is Map) {
      final map = compact(value.cast<String, Object?>());
      return map.isEmpty ? null : map;
    }
    if (value is Iterable) {
      final list = value.map(_compactValue).where((e) => e != null).toList();
      return list.isEmpty ? null : list;
    }
    return value;
  }

  /// `[lng, lat]` as sent to Amazon Location.
  static List<double> position(GeoPoint p) => [p.longitude, p.latitude];

  /// Parses an Amazon Location `[lng, lat]` array.
  static GeoPoint? parsePosition(Object? value) {
    if (value is List && value.length >= 2) {
      final lng = value[0], lat = value[1];
      if (lng is num && lat is num) {
        return GeoPoint(lat.toDouble(), lng.toDouble());
      }
    }
    return null;
  }

  static List<GeoPoint> parseLineString(Object? value) {
    if (value is! List) return const [];
    return value.map(parsePosition).whereType<GeoPoint>().toList();
  }

  static double? toDouble(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('${value ?? ''}');

  static int? toInt(Object? value) =>
      value is num ? value.toInt() : int.tryParse('${value ?? ''}');

  static String? string(Object? value) => value?.toString();

  static Map<String, dynamic> map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static List<Map<String, dynamic>> mapList(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];

  static List<String> stringList(Object? value) =>
      value is List ? value.map((e) => '$e').toList() : const [];
}
