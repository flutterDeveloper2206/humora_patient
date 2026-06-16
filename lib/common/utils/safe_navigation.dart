import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pops the current route when possible; otherwise navigates to [fallbackLocation].
void safePop(BuildContext context, {String fallbackLocation = '/home'}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackLocation);
  }
}
