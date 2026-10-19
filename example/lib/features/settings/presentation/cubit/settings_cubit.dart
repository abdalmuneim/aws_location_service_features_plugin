import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecases.dart';

/// App-wide preferences. Provided above [MaterialApp] so every screen
/// (and every map) reacts to changes immediately.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._save, AppSettings initial) : super(initial);

  final SaveSettings _save;

  Future<void> update(AppSettings settings) async {
    if (settings == state) return;
    final result = await _save(settings);
    // The runtime connection is updated even if persisting fails, so the
    // change still applies for this session.
    emit(result.valueOrNull ?? settings);
  }

  Future<void> updateMapStyle(MapStyleOptions options) =>
      update(state.copyWith(mapStyle: options.sanitized()));

  Future<void> reset() => update(AppSettings.defaults());
}
