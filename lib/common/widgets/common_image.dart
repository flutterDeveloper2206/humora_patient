import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageType { network, asset, file, svg }

class CommonImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final double borderRadius;
  final FilterQuality filterQuality;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CommonImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.color,
    this.borderRadius = 0,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildImage(context),
      ),
    );
  }

  int? _cacheDimension(BuildContext context, double? logicalSize) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    // Skip cache hints for unbounded or extreme layout sizes (e.g. double.maxFinite).
    if (logicalSize > 8192) return null;

    final pixels = logicalSize * MediaQuery.devicePixelRatioOf(context);
    if (!pixels.isFinite || pixels <= 0) return null;

    return pixels.round().clamp(1, 4096);
  }

  Widget _buildImage(BuildContext context) {
    final type = _getImageType(path);
    final cacheWidth = _cacheDimension(context, width);
    final cacheHeight = _cacheDimension(context, height);

    switch (type) {
      case ImageType.network:
        return CachedNetworkImage(
          imageUrl: path,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          color: color,
          filterQuality: filterQuality,
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          fadeInDuration: const Duration(milliseconds: 180),
          placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
          errorWidget: (context, url, error) =>
              errorWidget ?? _defaultErrorWidget(),
        );
      case ImageType.asset:
        return Image.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          color: color,
          filterQuality: filterQuality,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _defaultErrorWidget(),
        );
      case ImageType.file:
        return Image.file(
          File(path),
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          color: color,
          filterQuality: filterQuality,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _defaultErrorWidget(),
        );
      case ImageType.svg:
        return SvgPicture.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          placeholderBuilder: (context) => placeholder ?? _defaultPlaceholder(),
        );
    }
  }

  ImageType _getImageType(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return ImageType.network;
    } else if (path.endsWith('.svg')) {
      return ImageType.svg;
    } else if (path.startsWith('/') || path.contains('Users/')) {
      return ImageType.file;
    } else {
      return ImageType.asset;
    }
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: Colors.grey[200],
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    final w = width;
    final h = height;
    final iconSize = (w != null &&
            h != null &&
            w.isFinite &&
            h.isFinite &&
            w > 0 &&
            h > 0)
        ? ((w < h ? w : h) * 0.35).clamp(16.0, 48.0)
        : 24.0;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[600],
        size: iconSize,
      ),
    );
  }
}
