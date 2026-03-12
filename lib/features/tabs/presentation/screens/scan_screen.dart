import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:growingkids/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';

enum ScanMode { qr, photo }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _qrController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  CameraController? _photoController;

  ScanMode _mode = ScanMode.qr;
  bool _isPreparing = true;
  bool _isSwitchingMode = false;
  bool _isTakingPhoto = false;

  String? _cameraError;
  String? _lastQrValue;
  String? _capturedPhotoPath;

  @override
  void initState() {
    super.initState();
    _activateMode(_mode);
  }

  @override
  void dispose() {
    _qrController.dispose();
    _photoController?.dispose();
    super.dispose();
  }

  Future<void> _switchMode(ScanMode nextMode) async {
    if (nextMode == _mode || _isSwitchingMode) {
      return;
    }

    setState(() {
      _mode = nextMode;
      _isPreparing = true;
      _isSwitchingMode = true;
      _cameraError = null;
    });

    await _activateMode(nextMode);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSwitchingMode = false;
    });
  }

  Future<void> _activateMode(ScanMode mode) async {
    try {
      if (mode == ScanMode.qr) {
        await _disposePhotoController();
        if (!mounted) {
          return;
        }

        setState(() {
          _isPreparing = false;
          _cameraError = null;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted || _mode != ScanMode.qr) {
            return;
          }

          try {
            await _qrController.start();
          } catch (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _cameraError =
                  'QR không thể mở camera. Vui lòng kiểm tra quyền camera.';
            });
          }
        });
        return;
      } else {
        await _qrController.stop();
        await _initPhotoController();
      }
    } catch (_) {
      _cameraError = 'Không thể truy cập camera. Vui lòng cấp quyền camera.';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isPreparing = false;
    });
  }

  Future<void> _initPhotoController() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No camera available');
    }

    CameraDescription selectedCamera = cameras.first;
    for (final camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        selectedCamera = camera;
        break;
      }
    }

    final controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _photoController = controller;
    });
  }

  Future<void> _disposePhotoController() async {
    final controller = _photoController;
    _photoController = null;

    if (controller != null) {
      await controller.dispose();
    }
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_mode != ScanMode.qr) {
      return;
    }

    String? rawValue;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        rawValue = value;
        break;
      }
    }

    if (rawValue == null || rawValue == _lastQrValue) {
      return;
    }

    setState(() {
      _lastQrValue = rawValue;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('QR: $rawValue'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _takePhoto() async {
    final controller = _photoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPhoto) {
      return;
    }

    setState(() {
      _isTakingPhoto = true;
    });

    try {
      final photo = await controller.takePicture();

      if (!mounted) {
        return;
      }

      setState(() {
        _capturedPhotoPath = photo.path;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Chụp ảnh thất bại. Vui lòng thử lại.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Scan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ScanMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<ScanMode>(
                    value: ScanMode.qr,
                    label: Text('QR Scan'),
                    icon: Icon(Icons.qr_code_scanner),
                  ),
                  ButtonSegment<ScanMode>(
                    value: ScanMode.photo,
                    label: Text('Chụp ảnh'),
                    icon: Icon(Icons.photo_camera_outlined),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  _switchMode(selection.first);
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildCameraBody(context)),
            if (_mode == ScanMode.photo) ...[
              const SizedBox(height: 16),
              _buildCaptureButton(),
            ] else if (_lastQrValue != null) ...[
              const SizedBox(height: 14),
              Text(
                'Kết quả gần nhất: $_lastQrValue',
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNagivationBar(activeTab: AppTab.scan),
    );
  }

  Widget _buildCameraBody(BuildContext context) {
    if (_cameraError != null) {
      return _buildErrorCard(_cameraError!);
    }

    if (_isPreparing || _isSwitchingMode) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mode == ScanMode.qr) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(controller: _qrController, onDetect: _onQrDetected),
            const _ScannerOverlay(),
          ],
        ),
      );
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
              bottom: 12,
              child: _CapturedPreview(path: _capturedPhotoPath!),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return SizedBox(
      height: 74,
      child: Center(
        child: GestureDetector(
          onTap: _isTakingPhoto ? null : _takePhoto,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: _isTakingPhoto ? Colors.grey : const Color(0xFF16A34A),
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
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 54, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
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
