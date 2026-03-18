import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/features/categories/domain/entities/category.dart';
import 'package:growingkids/features/categories/domain/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;
  int? _currentLimit;

  CategoryBloc({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const CategoryInitial()) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<CategoryCreatedRequested>(_onCategoryCreatedRequested);
    on<CategoryUpdatedRequested>(_onCategoryUpdatedRequested);
    on<CategoryDeletedRequested>(_onCategoryDeletedRequested);
  }

  Future<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<CategoryState> emit,
  ) async {
    _currentLimit = event.limit;
    emit(const CategoryLoading());
    try {
      final categories = await _categoryRepository.getCategories(
        limit: event.limit,
      );
      emit(CategoryLoaded(categories, isShowingAll: event.limit == null));
    } catch (_) {
      emit(const CategoryFailure('Không thể tải danh mục lúc này.'));
    }
  }

  Future<void> _onCategoryCreatedRequested(
    CategoryCreatedRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearFeedbackMessage: true));
    try {
      await _categoryRepository.createCategory(
        name: event.name,
        description: event.description,
        imageBytes: event.imageBytes,
        imageFileName: event.imageFileName,
      );
      final categories = await _categoryRepository.getCategories(
        limit: _currentLimit,
      );
      emit(
        currentState.copyWith(
          categories: categories,
          isSubmitting: false,
          feedbackMessage: 'Đã thêm danh mục mới.',
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          feedbackMessage: 'Không thể thêm danh mục lúc này.',
        ),
      );
    }
  }

  Future<void> _onCategoryUpdatedRequested(
    CategoryUpdatedRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearFeedbackMessage: true));
    try {
      await _categoryRepository.updateCategory(
        id: event.id,
        name: event.name,
        description: event.description,
        currentThumbnailUrl: event.currentThumbnailUrl,
        imageBytes: event.imageBytes,
        imageFileName: event.imageFileName,
      );
      final categories = await _categoryRepository.getCategories(
        limit: _currentLimit,
      );
      emit(
        currentState.copyWith(
          categories: categories,
          isSubmitting: false,
          feedbackMessage: 'Đã cập nhật danh mục.',
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          feedbackMessage: 'Không thể cập nhật danh mục lúc này.',
        ),
      );
    }
  }

  Future<void> _onCategoryDeletedRequested(
    CategoryDeletedRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) {
      return;
    }

    emit(currentState.copyWith(isSubmitting: true, clearFeedbackMessage: true));
    try {
      await _categoryRepository.deleteCategory(event.id);
      final categories = await _categoryRepository.getCategories(
        limit: _currentLimit,
      );
      emit(
        currentState.copyWith(
          categories: categories,
          isSubmitting: false,
          feedbackMessage: 'Đã xoá danh mục.',
        ),
      );
    } catch (_) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          feedbackMessage: 'Không thể xoá danh mục lúc này.',
        ),
      );
    }
  }
}
