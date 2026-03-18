part of 'category_bloc.dart';

sealed class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final bool isShowingAll;
  final bool isSubmitting;
  final String? feedbackMessage;

  const CategoryLoaded(
    this.categories, {
    required this.isShowingAll,
    this.isSubmitting = false,
    this.feedbackMessage,
  });

  CategoryLoaded copyWith({
    List<Category>? categories,
    bool? isShowingAll,
    bool? isSubmitting,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
  }) {
    return CategoryLoaded(
      categories ?? this.categories,
      isShowingAll: isShowingAll ?? this.isShowingAll,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedbackMessage: clearFeedbackMessage
          ? null
          : feedbackMessage ?? this.feedbackMessage,
    );
  }
}

class CategoryFailure extends CategoryState {
  final String message;

  const CategoryFailure(this.message);
}
