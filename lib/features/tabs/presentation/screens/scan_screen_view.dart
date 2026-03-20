part of 'scan_screen.dart';

extension _ScanScreenView on _ScanScreenState {
  Widget _buildScanViewport(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCameraBody(context),
        if (_mode == ScanMode.qr)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Center(
                child: _OverlayActionButton(
                  icon: Icons.photo_library_outlined,
                  label: _isPickingGallery ? 'Đang đọc ảnh' : 'Chọn ảnh',
                  onPressed: _isPickingGallery ? null : _pickFromGallery,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraBody(BuildContext context) {
    if (_isPreparing || _isSwitchingMode) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mode == ScanMode.qr) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _qrController,
              onDetect: _onQrDetected,
              errorBuilder: (context, error) {
                return _buildErrorCard(_scannerErrorMessage(error));
              },
            ),
            const _ScannerOverlay(),
          ],
        ),
      );
    }

    if (_cameraError != null) {
      return _buildErrorCard(_cameraError!);
    }

    final controller = _photoController;
    if (controller == null || !controller.value.isInitialized) {
      return _buildErrorCard('Camera chưa sẵn sàng. Vui lòng thử lại.');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final previewSize = controller.value.previewSize;
              if (previewSize == null) {
                return const ColoredBox(color: Colors.black);
              }

              return FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: previewSize.height,
                  height: previewSize.width,
                  child: CameraPreview(controller),
                ),
              );
            },
          ),
          if (_capturedPhotoPath != null)
            Positioned(
              right: 12,
              top: 12,
              child: _CapturedPreview(path: _capturedPhotoPath!),
            ),
          Positioned(
            left: 16,
            bottom: 16,
            child: _OverlayIconButton(
              icon: Icons.photo_library_outlined,
              onPressed: _isPickingGallery ? null : _pickFromGallery,
              isBusy: _isPickingGallery,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(child: _buildCaptureButton()),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = _isTakingPhoto || _isPickingGallery;

    return GestureDetector(
      onTap: isDisabled ? null : _takePhoto,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: isDisabled ? Colors.grey : cs.primary,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: _isTakingPhoto
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 54, color: cs.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
        ],
      ),
    );
  }

  String _scannerErrorMessage(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'QR không được cấp quyền camera. Hãy mở Settings và cấp quyền camera cho app.';
      case MobileScannerErrorCode.unsupported:
        return 'Thiết bị này không hỗ trợ quét QR.';
      case MobileScannerErrorCode.controllerAlreadyInitialized:
      case MobileScannerErrorCode.controllerInitializing:
        return 'Camera QR đang khởi động. Vui lòng đợi trong giây lát.';
      case MobileScannerErrorCode.controllerDisposed:
      case MobileScannerErrorCode.controllerNotAttached:
      case MobileScannerErrorCode.controllerUninitialized:
      case MobileScannerErrorCode.genericError:
        final details = error.errorDetails?.message;
        if (details != null && details.isNotEmpty) {
          return 'QR không thể mở camera: $details';
        }
        return 'QR không thể mở camera. Vui lòng thử lại.';
    }
  }
}

class _QrLinkResultSheet extends StatelessWidget {
  final String value;
  final VoidCallback onDismiss;
  final VoidCallback onOpen;

  const _QrLinkResultSheet({
    required this.value,
    required this.onDismiss,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Liên kết vừa quét',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Mở liên kết'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverlayActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _OverlayActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isBusy;

  const _OverlayIconButton({
    required this.icon,
    required this.onPressed,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isBusy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _CapturedPreview extends StatelessWidget {
  final String path;

  const _CapturedPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72,
        height: 96,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: kIsWeb
            ? const ColoredBox(
                color: Colors.black12,
                child: Center(child: Icon(Icons.image, color: Colors.white)),
              )
            : Image.file(File(path), fit: BoxFit.cover),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    const frameSize = 230.0;
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSize,
      height: frameSize,
    );

    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(18)));

    final maskPath = Path.combine(PathOperation.difference, fullPath, cutout);
    canvas.drawPath(maskPath, overlayPaint);

    final framePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(18)),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
