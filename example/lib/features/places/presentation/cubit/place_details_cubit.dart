import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

class PlaceDetailsState extends Equatable {
  const PlaceDetailsState({
    required this.place,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final Place place;
  final LoadStatus status;
  final Failure? failure;

  @override
  List<Object?> get props => [place, status, failure];
}

/// Loads full GetPlace details for a place returned by a search.
class PlaceDetailsCubit extends Cubit<PlaceDetailsState> {
  PlaceDetailsCubit(this._getPlace, Place place)
    : super(PlaceDetailsState(place: place));

  final GetPlace _getPlace;

  Future<void> load() async {
    if (state.place.placeId.isEmpty) {
      emit(PlaceDetailsState(place: state.place, status: LoadStatus.success));
      return;
    }
    emit(PlaceDetailsState(place: state.place, status: LoadStatus.loading));
    final result = await _getPlace(
      GetPlaceParams(placeId: state.place.placeId),
    );
    emit(
      result.fold(
        (f) => PlaceDetailsState(
          place: state.place,
          status: LoadStatus.failure,
          failure: f,
        ),
        (p) => PlaceDetailsState(
          // GetPlace omits the distance from the original query.
          place: p.withDistance(p.distance ?? state.place.distance),
          status: LoadStatus.success,
        ),
      ),
    );
  }
}
