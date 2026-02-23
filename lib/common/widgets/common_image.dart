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
  final Color? color;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CommonImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    final type = _getImageType(path);

    switch (type) {
      case ImageType.network:
        return CachedNetworkImage(
          imageUrl: path,
          width: width,
          height: height,
          fit: fit,
          color: color,
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
          color: color,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _defaultErrorWidget(),
        );
      case ImageType.file:
        return Image.file(
          File(path),
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _defaultErrorWidget(),
        );
      case ImageType.svg:
        return SvgPicture.asset(
          path,
          width: width,
          height: height,
          fit: fit,
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
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.error_outline, color: Colors.grey),
    );
  }
}
