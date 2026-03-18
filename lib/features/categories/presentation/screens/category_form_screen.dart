import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:growingkids/features/categories/domain/entities/category.dart';
import 'package:growingkids/features/categories/presentation/bloc/category_bloc.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _showImageValidationError = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = file.name;
        _showImageValidationError = false;
      });
    } on PlatformException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể mở thư viện ảnh. Hãy tắt app và chạy lại bản build mới.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hasExistingImage =
        widget.category?.thumbnailUrl != null &&
        widget.category!.thumbnailUrl!.trim().isNotEmpty;
    final hasSelectedImage = _selectedImageBytes != null;

    if (!hasExistingImage && !hasSelectedImage) {
      setState(() {
        _showImageValidationError = true;
      });
      return;
    }

    if (_isEditing) {
      context.read<CategoryBloc>().add(
        CategoryUpdatedRequested(
          id: widget.category!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          currentThumbnailUrl: widget.category!.thumbnailUrl,
          imageBytes: _selectedImageBytes,
          imageFileName: _selectedImageName,
        ),
      );
    } else {
      context.read<CategoryBloc>().add(
        CategoryCreatedRequested(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageBytes: _selectedImageBytes,
          imageFileName: _selectedImageName,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final existingImageUrl = widget.category?.thumbnailUrl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          _isEditing ? 'Sửa danh mục' : 'Thêm danh mục',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePickerCard(
                imageBytes: _selectedImageBytes,
                existingImageUrl: existingImageUrl,
                onPickImage: _pickImage,
                showValidationError: _showImageValidationError,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên danh mục',
                  hintText: 'Ví dụ: Cây văn phòng',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên danh mục.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả ngắn về danh mục',
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Lưu thay đổi' : 'Thêm danh mục',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final bool showValidationError;

  const _ImagePickerCard({
    required this.imageBytes,
    required this.existingImageUrl,
    required this.onPickImage,
    required this.showValidationError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ảnh danh mục',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickImage,
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPreview(),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                imageBytes != null ||
                                        (existingImageUrl != null &&
                                            existingImageUrl!.trim().isNotEmpty)
                                    ? 'Đổi ảnh'
                                    : 'Chọn ảnh',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Chạm vào ảnh để chọn từ thư viện',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showValidationError) ...[
            const SizedBox(height: 8),
            Text(
              'Vui lòng chọn ảnh cho danh mục.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, fit: BoxFit.cover);
    }

    if (existingImageUrl != null && existingImageUrl!.trim().isNotEmpty) {
      return Image.network(
        existingImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8EFEA),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_florist_rounded,
        color: Color(0xFF2F7D4E),
        size: 56,
      ),
    );
  }
}
