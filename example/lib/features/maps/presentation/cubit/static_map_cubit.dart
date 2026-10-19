import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/aws_config.dart';
import '../../../../core/presentation/load_status.dart';

class StaticMapState extends Equatable {
  const StaticMapState({
    required this.request,
    this.image,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final StaticMapRequest request;
  final StaticMapImage? image;
  final LoadStatus status;
  final Failure? failure;

  StaticMapState copyWith({
    StaticMapRequest? request,
    StaticMapImage? image,
    LoadStatus? status,
    Failure? failure,
  }) => StaticMapState(
    request: request ?? this.request,
    image: image ?? this.image,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [request, image, status, failure];
}

class StaticMapCubit extends Cubit<StaticMapState> {
  StaticMapCubit(this._getStaticMap, {String? language})
    : super(
        StaticMapState(
          request: StaticMapRequest(
            center: AwsConfig.defaultCenter,
            language: language,
          ),
        ),
      );

  final GetStaticMap _getStaticMap;

  void update(StaticMapRequest request) =>
      emit(state.copyWith(request: request));

  Future<void> render() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final request = state.request;
    final result = await _getStaticMap(request);
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (img) => emit(state.copyWith(image: img, status: LoadStatus.success)),
    );
  }
}
