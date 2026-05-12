import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImagemApp {
  static Widget carregar(
    String? url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double placeholderIconSize = 60,
  }) {
    final fallback = _placeholder(
      width: width,
      height: height,
      iconSize: placeholderIconSize,
    );

    if (url == null || url.isEmpty) {
      return fallback;
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    if (kIsWeb) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.file(
      File(url),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  static DecorationImage? decoration(String? url, {BoxFit fit = BoxFit.cover}) {
    if (url == null || url.isEmpty) {
      return null;
    }

    if (url.startsWith('assets/')) {
      return DecorationImage(image: AssetImage(url), fit: fit);
    }

    if (kIsWeb) {
      return DecorationImage(image: NetworkImage(url), fit: fit);
    }

    return DecorationImage(image: FileImage(File(url)), fit: fit);
  }

  static Widget _placeholder({
    double? width,
    double? height,
    required double iconSize,
  }) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(Icons.pets, size: iconSize, color: Colors.grey),
    );
  }
}
