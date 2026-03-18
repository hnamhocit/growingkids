import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:growingkids/features/banners/domain/entities/app_banner.dart';
import 'package:growingkids/features/banners/presentation/bloc/banner_bloc.dart';

class BannerFormScreen extends StatefulWidget {
  final AppBanner? banner;

  const BannerFormScreen({super.key, this.banner});

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _linkController;
  late final TextEditingController _priorityController;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _showImageValidationError = false;
  late bool _isActive;

  bool get _isEditing => widget.banner != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _subtitleController = TextEditingController(
      text: widget.banner?.subtitle ?? '',
    );
    _linkController = TextEditingController(text: widget.banner?.linkUrl ?? '');
    _priorityController = TextEditingController(
      text: (widget.banner?.priority ?? 0).toString(),
    );
    _isActive = widget.banner?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _linkController.dispose();
    _priorityController.dispose();
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

    final hasExistingImage = widget.banner?.imageUrl.trim().isNotEmpty ?? false;
    final hasSelectedImage = _selectedImageBytes != null;

    if (!hasExistingImage && !hasSelectedImage) {
      setState(() {
        _showImageValidationError = true;
      });
      return;
    }

    final priority = int.tryParse(_priorityController.text.trim()) ?? 0;

    if (_isEditing) {
      context.read<BannerBloc>().add(
        BannerUpdatedRequested(
          id: widget.banner!.id,
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          linkUrl: _linkController.text.trim(),
          isActive: _isActive,
          priority: priority,
          currentImageUrl: widget.banner!.imageUrl,
          imageBytes: _selectedImageBytes,
          imageFileName: _selectedImageName,
        ),
      );
    } else {
      context.read<BannerBloc>().add(
        BannerCreatedRequested(
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          linkUrl: _linkController.text.trim(),
          isActive: _isActive,
          priority: priority,
          imageBytes: _selectedImageBytes!,
          imageFileName: _selectedImageName!,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          _isEditing ? 'Sửa banner' : 'Thêm banner',
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
              _BannerImagePickerCard(
                imageBytes: _selectedImageBytes,
                existingImageUrl: widget.banner?.imageUrl,
                onPickImage: _pickImage,
                showValidationError: _showImageValidationError,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề banner',
                  hintText: 'Ví dụ: Mùa tăng trưởng',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề banner.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subtitleController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Phụ đề',
                  hintText: 'Ví dụ: Giảm giá 30% cho phân bón nước',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Liên kết',
                  hintText: 'Ví dụ: /categories hoặc https://...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priorityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Độ ưu tiên',
                  hintText: 'Số càng cao càng hiện trước',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập độ ưu tiên.';
                  }

                  if (int.tryParse(value.trim()) == null) {
                    return 'Độ ưu tiên phải là số nguyên.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                title: const Text(
                  'Hiển thị banner',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Chỉ banner đang bật mới xuất hiện ở trang chủ.',
                ),
              ),
              const SizedBox(height: 24),
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
                  _isEditing ? 'Lưu thay đổi' : 'Thêm banner',
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

class _BannerImagePickerCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final bool showValidationError;

  const _BannerImagePickerCard({
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
            'Ảnh banner',
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
                  aspectRatio: 16 / 9,
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
                            color: Colors.black.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            imageBytes != null || existingImageUrl != null
                                ? 'Đổi ảnh'
                                : 'Chọn ảnh',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showValidationError) ...[
            const SizedBox(height: 12),
            Text(
              'Vui lòng chọn ảnh cho banner.',
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
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 40),
          SizedBox(height: 12),
          Text(
            'Chạm để chọn ảnh banner',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
