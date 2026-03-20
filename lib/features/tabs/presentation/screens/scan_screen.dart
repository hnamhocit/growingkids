import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/features/products/domain/services/app_qr_link_codec.dart';
import 'package:growingkids/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

part 'scan_screen_actions.dart';
part 'scan_screen_view.dart';

enum ScanMode { qr, photo }

enum _QrLinkSheetAction { dismiss, open }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final MobileScannerController _qrController = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  final ImagePicker _imagePicker = ImagePicker();

  CameraController? _photoController;

  ScanMode _mode = ScanMode.qr;
  bool _isPreparing = true;
  bool _isSwitchingMode = false;
  bool _isTakingPhoto = false;
  bool _isPickingGallery = false;
  bool _isOpeningInternalRoute = false;
  bool _isShowingLinkModal = false;

  String? _cameraError;
  String? _lastQrValue;
  DateTime? _lastQrHandledAt;
  String? _capturedPhotoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activateMode(_mode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _qrController.dispose();
    _photoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_mode != ScanMode.qr || !_qrController.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _scheduleQrStart();
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _stopQrScanner();
        return;
    }
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

        _scheduleQrStart();
        return;
      }

      await _stopQrScanner();
      await _initPhotoController();
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
      throw StateError('Không tìm thấy camera khả dụng');
    }

    var selectedCamera = cameras.first;
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

  void _scheduleQrStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQrScanner();
    });
  }

  Future<void> _startQrScanner() async {
    if (!mounted ||
        _mode != ScanMode.qr ||
        _qrController.value.isRunning ||
        _qrController.value.isStarting) {
      return;
    }

    await _qrController.start();

    if (!mounted) {
      return;
    }

    if (_mode != ScanMode.qr) {
      await _stopQrScanner();
      return;
    }

    final error = _qrController.value.error;
    if (error != null) {
      setState(() {});
    }
  }

  Future<void> _stopQrScanner() async {
    await _qrController.stop();
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_mode != ScanMode.qr ||
        _isOpeningInternalRoute ||
        _isPickingGallery ||
        _isShowingLinkModal) {
      return;
    }

    final rawValue = _firstBarcodeValue(capture);
    if (rawValue == null) {
      return;
    }

    _handleQrValue(rawValue);
  }

  String? _firstBarcodeValue(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  void _updateView(VoidCallback update) {
    if (!mounted) {
      return;
    }

    setState(update);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'Quét',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
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
                    label: Text('Quét QR'),
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
            Expanded(child: _buildScanViewport(context)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNagivationBar(activeTab: AppTab.scan),
    );
  }
}
