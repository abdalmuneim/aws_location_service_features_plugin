import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationPickerState extends Equatable {
  const LocationPickerState({
    this.selected,
    this.loading = false,
    this.failure,
  });

  final NamedLocation? selected;
  final bool loading;
  final Failure? failure;

  @override
  List<Object?> get props => [selected, loading, failure];
}

/// Picks a location by tapping the map, searching, or using the device
/// position. Tapped points are labelled with ReverseGeocode.
class LocationPickerCubit extends Cubit<LocationPickerState> {
  LocationPickerCubit(
    this._reverseGeocode,
    this._currentLocation, {
    NamedLocation? initial,
  }) : super(LocationPickerState(selected: initial));

  final ReverseGeocode _reverseGeocode;
  final GetCurrentLocation _currentLocation;

  Future<void> selectPoint(GeoPoint point) async {
    final fallback = NamedLocation(point: point, label: point.format());
    emit(LocationPickerState(selected: fallback, loading: true));
    final result = await _reverseGeocode(ReverseGeocodeParams(position: point));
    if (isClosed) return;
    final place = result.valueOrNull?.firstOrNull;
    emit(
      LocationPickerState(
        selected: place == null
            ? fallback
            : NamedLocation(
                point: point,
                label: place.address?.label ?? place.title,
              ),
      ),
    );
  }

  void selectPlace(Place place) {
    if (place.position == null) return;
    emit(
      LocationPickerState(
        selected: NamedLocation(point: place.position!, label: place.title),
      ),
    );
  }

  /// Returns the device position, or null on failure.
  Future<GeoPoint?> useMyLocation() async {
    emit(LocationPickerState(selected: state.selected, loading: true));
    final result = await _currentLocation(const NoParams());
    if (isClosed) return null;
    return result.fold(
      (f) {
        emit(LocationPickerState(selected: state.selected, failure: f));
        return null;
      },
      (pos) {
        selectPoint(pos.point);
        return pos.point;
      },
    );
  }
}
