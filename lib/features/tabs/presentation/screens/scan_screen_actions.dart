part of 'scan_screen.dart';

extension _ScanScreenActions on _ScanScreenState {
  Future<void> _handleQrValue(String rawValue) async {
    final scannedValue = rawValue.trim();
    if (scannedValue.isEmpty || _shouldIgnoreRepeatedScan(scannedValue)) {
      return;
    }

    _rememberHandledQr(scannedValue);

    final internalLocation = AppQrLinkCodec.tryParseLocation(scannedValue);
    if (internalLocation != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Đang mở trang trong app.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      await _openInternalRoute(internalLocation);
      return;
    }

    if (AppQrLinkCodec.isAppLink(scannedValue)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('QR nội bộ này chưa được hỗ trợ.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final webLink = _tryParseWebUrl(scannedValue);
    if (webLink != null) {
      await _showLinkResultModal(value: scannedValue, link: webLink);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('QR này chưa được hỗ trợ.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  bool _shouldIgnoreRepeatedScan(String scannedValue) {
    final lastHandledAt = _lastQrHandledAt;
    return scannedValue == _lastQrValue &&
        lastHandledAt != null &&
        DateTime.now().difference(lastHandledAt) < const Duration(seconds: 2);
  }

  void _rememberHandledQr(String scannedValue) {
    _lastQrValue = scannedValue;
    _lastQrHandledAt = DateTime.now();
  }

  Future<void> _showLinkResultModal({
    required String value,
    required Uri link,
  }) async {
    if (_isShowingLinkModal) {
      return;
    }

    _updateView(() {
      _isShowingLinkModal = true;
    });

    await _stopQrScanner();

    if (!mounted) {
      return;
    }

    final action = await showModalBottomSheet<_QrLinkSheetAction>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _QrLinkResultSheet(
          value: value,
          onDismiss: () {
            Navigator.of(sheetContext).pop(_QrLinkSheetAction.dismiss);
          },
          onOpen: () {
            Navigator.of(sheetContext).pop(_QrLinkSheetAction.open);
          },
        );
      },
    );

    if (action == _QrLinkSheetAction.open) {
      await _launchLink(link);
    }

    if (!mounted) {
      return;
    }

    _updateView(() {
      _isShowingLinkModal = false;
    });

    if (_mode == ScanMode.qr &&
        !_isPickingGallery &&
        !_isOpeningInternalRoute) {
      _scheduleQrStart();
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isPickingGallery) {
      return;
    }

    if (_mode == ScanMode.qr) {
      await _pickQrFromGallery();
      return;
    }

    await _pickPhotoFromGallery();
  }

  Future<void> _pickQrFromGallery() async {
    _updateView(() {
      _isPickingGallery = true;
    });

    await _stopQrScanner();

    if (!mounted) {
      return;
    }

    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Quét QR từ thư viện chưa hỗ trợ trên web.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }

      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }

      final capture = await _qrController.analyzeImage(
        image.path,
        formats: const [BarcodeFormat.qrCode],
      );

      if (!mounted) {
        return;
      }

      if (capture == null || capture.barcodes.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy QR trong ảnh đã chọn.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }

      final rawValue = _firstBarcodeValue(capture);
      if (rawValue == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Ảnh đã chọn không chứa QR hợp lệ.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }

      await _handleQrValue(rawValue);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Không thể đọc QR từ ảnh trong thư viện.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        _updateView(() {
          _isPickingGallery = false;
        });

        if (_mode == ScanMode.qr &&
            !_isOpeningInternalRoute &&
            !_isShowingLinkModal) {
          _scheduleQrStart();
        }
      }
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    _updateView(() {
      _isPickingGallery = true;
    });

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) {
        return;
      }

      _updateView(() {
        _capturedPhotoPath = image.path;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Không thể mở ảnh từ thư viện.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        _updateView(() {
          _isPickingGallery = false;
        });
      }
    }
  }

  Future<void> _openInternalRoute(String location) async {
    if (_isOpeningInternalRoute) {
      return;
    }

    _updateView(() {
      _isOpeningInternalRoute = true;
    });

    await _stopQrScanner();

    if (!mounted) {
      return;
    }

    try {
      await context.push(location);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Không mở được trang từ QR này.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        _updateView(() {
          _isOpeningInternalRoute = false;
        });

        if (_mode == ScanMode.qr) {
          _scheduleQrStart();
        }
      }
    }
  }

  Uri? _tryParseWebUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) {
      return null;
    }

    final scheme = uri.scheme.toLowerCase();
    if ((scheme == 'http' || scheme == 'https') && uri.hasAuthority) {
      return uri;
    }

    return null;
  }

  Future<void> _launchLink(Uri uri) async {
    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) {
        return;
      }

      if (!didLaunch) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Không mở được liên kết này.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Có lỗi khi mở liên kết. Vui lòng thử lại.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _takePhoto() async {
    final controller = _photoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPhoto ||
        _isPickingGallery) {
      return;
    }

    _updateView(() {
      _isTakingPhoto = true;
    });

    try {
      final photo = await controller.takePicture();

      if (!mounted) {
        return;
      }

      _updateView(() {
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
        _updateView(() {
          _isTakingPhoto = false;
        });
      }
    }
  }
}
