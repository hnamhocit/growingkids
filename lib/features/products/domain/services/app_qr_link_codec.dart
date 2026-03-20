abstract final class AppQrLinkCodec {
  static const _scheme = 'growingkids';
  static const _homeHost = 'home';
  static const _supportedRootPaths = <String>{
    '/',
    '/cart',
    '/banners',
    '/categories',
    '/my-plants',
    '/profile',
    '/notifications',
    '/scan',
    '/auth/enter',
    '/auth/forgot-password',
  };

  static String encodeLocation(String location) {
    final uri = Uri.parse(location);
    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    final host = segments.isEmpty ? _homeHost : segments.first;
    final pathSegments = segments.skip(1).toList(growable: false);
    final queryParameters = uri.queryParameters.isEmpty
        ? null
        : uri.queryParameters;

    return Uri(
      scheme: _scheme,
      host: host,
      pathSegments: pathSegments,
      queryParameters: queryParameters,
    ).toString();
  }

  static String encodeProductDetail(String productId) {
    return encodeLocation('/products/$productId');
  }

  static bool isAppLink(String rawValue) {
    final uri = Uri.tryParse(rawValue.trim());
    return uri != null && uri.scheme.toLowerCase() == _scheme;
  }

  static String? tryParseLocation(String rawValue) {
    final uri = Uri.tryParse(rawValue.trim());
    if (uri == null || uri.scheme.toLowerCase() != _scheme) {
      return null;
    }

    final allSegments = <String>[];
    final host = uri.host.trim().toLowerCase();
    if (host.isNotEmpty && host != _homeHost) {
      allSegments.add(host);
    }
    allSegments.addAll(uri.pathSegments.where((segment) => segment.isNotEmpty));

    final path = allSegments.isEmpty ? '/' : '/${allSegments.join('/')}';
    final normalizedPath = _normalizePath(path);
    if (normalizedPath == null) {
      return null;
    }

    if (uri.queryParameters.isEmpty) {
      return normalizedPath;
    }

    return Uri(
      path: normalizedPath,
      queryParameters: uri.queryParameters,
    ).toString();
  }

  static String? _normalizePath(String path) {
    if (_supportedRootPaths.contains(path)) {
      return path;
    }

    final uri = Uri.parse(path);
    final segments = uri.pathSegments;

    if (segments.length == 2 && segments.first == 'products') {
      return '/products/${segments[1]}';
    }

    return null;
  }
}
