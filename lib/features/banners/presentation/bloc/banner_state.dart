part of 'banner_bloc.dart';

sealed class BannerState {
  const BannerState();
}

class BannerInitial extends BannerState {
  const BannerInitial();
}

class BannerLoading extends BannerState {
  const BannerLoading();
}

class BannerLoaded extends BannerState {
  final List<AppBanner> banners;
  final bool isSubmitting;
  final String? feedbackMessage;

  const BannerLoaded(
    this.banners, {
    this.isSubmitting = false,
    this.feedbackMessage,
  });

  BannerLoaded copyWith({
    List<AppBanner>? banners,
    bool? isSubmitting,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
  }) {
    return BannerLoaded(
      banners ?? this.banners,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedbackMessage: clearFeedbackMessage
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}

class BannerFailure extends BannerState {
  final String message;

  const BannerFailure(this.message);
}
