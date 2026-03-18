import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/features/banners/domain/entities/app_banner.dart';
import 'package:growingkids/features/banners/domain/repositories/banner_repository.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final BannerRepository _bannerRepository;

  BannerBloc({required BannerRepository bannerRepository})
    : _bannerRepository = bannerRepository,
      super(const BannerInitial()) {
    on<BannersRequested>(_onBannersRequested);
    on<BannerCreatedRequested>(_onBannerCreatedRequested);
    on<BannerUpdatedRequested>(_onBannerUpdatedRequested);
    on<BannerDeletedRequested>(_onBannerDeletedRequested);
  }

  Future<void> _onBannersRequested(
    BannersRequested event,
    Emitter<BannerState> emit,
  ) async {
    emit(const BannerLoading());
    try {
      final banners = await _bannerRepository.getBanners();
      emit(BannerLoaded(banners));
    } catch (_) {
      emit(const BannerFailure('Không thể tải banner lúc này.'));
    }
  }

  Future<void> _onBannerCreatedRequested(
    BannerCreatedRequested event,
    Emitter<BannerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BannerLoaded) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearFeedbackMessage: true));
    try {
      await _bannerRepository.createBanner(
        title: event.title,
        subtitle: event.subtitle,
        linkUrl: event.linkUrl,
        isActive: event.isActive,
        priority: event.priority,
        imageBytes: event.imageBytes,
        imageFileName: event.imageFileName,
      );
      final banners = await _bannerRepository.getBanners();
      emit(
        currentState.copyWith(
          banners: banners,
          isSubmitting: false,
          feedbackMessage: 'Đã thêm banner mới.',
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          feedbackMessage: 'Không thể thêm banner lúc này.',
        ),
      );
    }
  }

  Future<void> _onBannerUpdatedRequested(
    BannerUpdatedRequested event,
    Emitter<BannerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BannerLoaded) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearFeedbackMessage: true));
    try {
      await _bannerRepository.updateBanner(
        id: event.id,
        title: event.title,
        subtitle: event.subtitle,
        linkUrl: event.linkUrl,
        isActive: event.isActive,
        priority: event.priority,
        currentImageUrl: event.currentImageUrl,
        imageBytes: event.imageBytes,
        imageFileName: event.imageFileName,
      );
      final banners = await _bannerRepository.getBanners();
      emit(
        currentState.copyWith(
          banners: banners,
          isSubmitting: false,
          feedbackMessage: 'Đã cập nhật banner.',
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          feedbackMessage: 'Không thể cập nhật banner lúc này.',
        ),
      );
    }
  }

  Future<void> _onBannerDeletedRequested(
    BannerDeletedRequested event,
    Emitter<BannerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BannerLoaded) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearFeedbackMessage: true));
    try {
      await _bannerRepository.deleteBanner(event.id);
      final banners = await _bannerRepository.getBanners();
      emit(
        currentState.copyWith(
          banners: banners,
          isSubmitting: false,
          feedbackMessage: 'Đã xoá banner.',
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          feedbackMessage: 'Không thể xoá banner lúc này.',
        ),
      );
    }
  }
}
