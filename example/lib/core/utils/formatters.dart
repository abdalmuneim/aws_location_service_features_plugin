import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

/// Display formatting in the current UI language: numbers and dates through
/// intl with [AppLocalizations.localeName], unit names from the ARB files.
abstract final class Formatters {
  /// [value] with [decimals] fraction digits and locale grouping.
  static String number(AppLocalizations l10n, num value, [int decimals = 0]) =>
      NumberFormat.decimalPatternDigits(
        locale: l10n.localeName,
        decimalDigits: decimals,
      ).format(value);

  static String distance(
    AppLocalizations l10n,
    num? meters, [
    MeasurementUnits units = MeasurementUnits.metric,
  ]) {
    if (meters == null) return '—';
    if (units == MeasurementUnits.imperial) {
      final miles = meters / 1609.344;
      if (miles < 0.1) return l10n.unitFeet(number(l10n, meters * 3.28084));
      return l10n.unitMiles(number(l10n, miles, miles < 10 ? 1 : 0));
    }
    if (meters < 1000) return l10n.unitMeters(number(l10n, meters));
    final km = meters / 1000;
    return l10n.unitKilometers(number(l10n, km, km < 10 ? 1 : 0));
  }

  static String duration(AppLocalizations l10n, num? seconds) {
    if (seconds == null) return '—';
    final total = seconds.round();
    if (total < 60) return l10n.unitSeconds(total);
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    if (h == 0) return l10n.unitMinutes(m);
    return m == 0
        ? l10n.unitHours(h)
        : l10n.unitHoursMinutes(l10n.unitHours(h), l10n.unitMinutes(m));
  }

  static String speed(
    AppLocalizations l10n,
    double? metersPerSecond, [
    MeasurementUnits units = MeasurementUnits.metric,
  ]) {
    if (metersPerSecond == null || metersPerSecond.isNaN) return '—';
    return units == MeasurementUnits.imperial
        ? l10n.unitMph(number(l10n, metersPerSecond * 2.23694, 1))
        : l10n.unitKmh(number(l10n, metersPerSecond * 3.6, 1));
  }

  static String time(AppLocalizations l10n, DateTime? value) => value == null
      ? '—'
      : DateFormat.Hms(l10n.localeName).format(value.toLocal());

  static String dateTime(AppLocalizations l10n, DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return l10n.dateTimeShort(
      DateFormat.MMMd(l10n.localeName).format(local),
      DateFormat.Hm(l10n.localeName).format(local),
    );
  }

  /// [amount] in [currency] (ISO 4217), e.g. "E£10.00".
  static String money(AppLocalizations l10n, num amount, String currency) =>
      NumberFormat.simpleCurrency(
        locale: l10n.localeName,
        name: currency.isEmpty ? null : currency,
      ).format(amount);

  /// "lat, lng" kept left-to-right inside right-to-left text (wrapped in a
  /// Unicode LTR isolate, which is invisible in left-to-right text).
  static String point(GeoPoint? p, [int fractionDigits = 5]) =>
      p == null ? '—' : '\u2066${p.format(fractionDigits)}\u2069';

  /// "Car" -> "Car", "PointOfInterest" -> "Point of interest".
  static String humanize(String? value) {
    if (value == null || value.isEmpty) return '';
    final spaced = value
        .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
        .replaceAll('_', ' ')
        .toLowerCase();
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
