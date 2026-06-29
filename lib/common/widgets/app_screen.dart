import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/app_layout.dart';

/// Standard screen shell — safe area, responsive padding, scroll support.
class AppScreen extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool embedded;
  final bool scrollable;
  final bool resizeToAvoidBottomInset;
  final bool applyHorizontalPadding;
  final bool applyBottomInset;
  final EdgeInsetsGeometry? padding;

  const AppScreen({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.embedded = false,
    this.scrollable = false,
    this.resizeToAvoidBottomInset = true,
    this.applyHorizontalPadding = false,
    this.applyBottomInset = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ??
        (applyHorizontalPadding || applyBottomInset
            ? AppLayout.screenPadding(
                embedded: embedded,
                bottomExtra: applyBottomInset ? 0 : AppLayout.standaloneBottomPadding,
              )
            : EdgeInsets.zero);

    Widget content = body;
    if (applyHorizontalPadding || applyBottomInset || padding != null) {
      content = Padding(padding: resolvedPadding, child: body);
    }
    if (scrollable) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: content,
            ),
          );
        },
      );
    }

    if (embedded) {
      return ColoredBox(
        color: backgroundColor ?? AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (appBar != null) appBar!,
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
