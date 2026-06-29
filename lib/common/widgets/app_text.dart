import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';

/// Overflow-safe text aligned with [AppTextStyles].
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  factory AppText.h1(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int maxLines = 2,
  }) =>
      AppText(
        data,
        key: key,
        style: AppTextStyles.h1,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  factory AppText.h2(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int maxLines = 2,
  }) =>
      AppText(
        data,
        key: key,
        style: AppTextStyles.h2,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  factory AppText.h3(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int maxLines = 2,
  }) =>
      AppText(
        data,
        key: key,
        style: AppTextStyles.h3,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  factory AppText.body(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int maxLines = 3,
    Color? color,
  }) =>
      AppText(
        data,
        key: key,
        style: AppTextStyles.bodyMedium.copyWith(color: color),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  factory AppText.caption(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int maxLines = 2,
  }) =>
      AppText(
        data,
        key: key,
        style: AppTextStyles.caption,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  factory AppText.label(
    String data, {
    Key? key,
    TextAlign? textAlign,
    int maxLines = 1,
  }) =>
      AppText(
        data,
        key: key,
        style: AppTextStyles.label,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
    );
  }
}
