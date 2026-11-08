import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/usecases/get_service_detail.dart';
import '../../domain/usecases/get_service_images.dart';

enum ServiceProfileStatus { initial, loading, ready, failure }

enum ServiceGalleryStatus { initial, loading, ready, failure }

class ServiceProfileState extends Equatable {
  const ServiceProfileState({
    this.status = ServiceProfileStatus.initial,
    this.detail,
    this.failure,
    this.galleryStatus = ServiceGalleryStatus.initial,
    this.images = const [],
    this.galleryFailure,
  });

  final ServiceProfileStatus status;
  final ServiceDetail? detail;
  final Failure? failure;
  final ServiceGalleryStatus galleryStatus;
  final List<String> images;
  final Failure? galleryFailure;

  ServiceProfileState copyWith({
    ServiceProfileStatus? status,
    ServiceDetail? detail,
    ServiceGalleryStatus? galleryStatus,
    List<String>? images,
  }) => ServiceProfileState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    failure: null,
    galleryStatus: galleryStatus ?? this.galleryStatus,
    images: images ?? this.images,
    galleryFailure: null,
  );

  @override
  List<Object?> get props => [
    status,
    detail,
    failure,
    galleryStatus,
    images,
    galleryFailure,
  ];
}

/// One service's record and its picture set. The two arrive together but fail
/// apart: a gallery that did not answer never hides the profile itself.
class ServiceProfileCubit extends Cubit<ServiceProfileState> {
  ServiceProfileCubit(this._getDetail, this._getImages)
    : super(const ServiceProfileState());

  final GetServiceDetail _getDetail;
  final GetServiceImages _getImages;

  ServiceDetailParams? _params;
  int _requestId = 0;

  Future<void> load({
    required String slug,
    required String locale,
    bool authenticated = false,
    double? userLat,
    double? userLng,
  }) async {
    final params = ServiceDetailParams(
      slug: slug,
      locale: locale,
      authenticated: authenticated,
      userLat: userLat,
      userLng: userLng,
    );
    _params = params;
    final requestId = ++_requestId;
    emit(
      const ServiceProfileState(
        status: ServiceProfileStatus.loading,
        galleryStatus: ServiceGalleryStatus.loading,
      ),
    );

    final detailFuture = _getDetail(params);
    final imagesFuture = _getImages(ServiceImagesParams(slug: slug));
    final detail = await detailFuture;
    final images = await imagesFuture;
    if (isClosed || requestId != _requestId) return;

    detail.fold(
      (Failure failure) => emit(
        ServiceProfileState(
          status: ServiceProfileStatus.failure,
          failure: failure,
          galleryStatus: state.galleryStatus,
          images: state.images,
        ),
      ),
      (ServiceDetail value) => emit(
        state.copyWith(status: ServiceProfileStatus.ready, detail: value),
      ),
    );
    images.fold(
      (Failure failure) => emit(
        ServiceProfileState(
          status: state.status,
          detail: state.detail,
          failure: state.failure,
          galleryStatus: ServiceGalleryStatus.failure,
          galleryFailure: failure,
        ),
      ),
      (List<String> value) => emit(
        state.copyWith(
          galleryStatus: ServiceGalleryStatus.ready,
          images: value,
        ),
      ),
    );
  }

  Future<void> refresh() async {
    final params = _params;
    if (params == null) return;
    await load(
      slug: params.slug,
      locale: params.locale,
      authenticated: params.authenticated,
      userLat: params.userLat,
      userLng: params.userLng,
    );
  }

  /// Asks for the pictures again without touching the record on screen.
  Future<void> retryImages() async {
    final params = _params;
    if (params == null) return;
    final requestId = _requestId;
    emit(state.copyWith(galleryStatus: ServiceGalleryStatus.loading));
    final result = await _getImages(ServiceImagesParams(slug: params.slug));
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) => emit(
        ServiceProfileState(
          status: state.status,
          detail: state.detail,
          failure: state.failure,
          galleryStatus: ServiceGalleryStatus.failure,
          galleryFailure: failure,
        ),
      ),
      (images) => emit(
        state.copyWith(
          galleryStatus: ServiceGalleryStatus.ready,
          images: images,
        ),
      ),
    );
  }
}