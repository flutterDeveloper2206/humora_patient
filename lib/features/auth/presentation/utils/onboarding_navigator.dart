import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/session_manager.dart';
import '../../data/models/otp_models.dart';

/// Routes users based on server [onboardingStep] and persists session fields.
class OnboardingNavigator {
  OnboardingNavigator._();

  static String routeForStep(int step) {
    switch (step) {
      case 1:
        return '/finish-signup';
      case 2:
        return '/healing-focus';
      case 3:
        return '/home';
      default:
        return '/home';
    }
  }

  static void go(BuildContext context, int step) {
    context.go(routeForStep(step));
  }

  static Future<void> persistUserData(VerifyTokenUserData data) async {
    if (data.patientId.isNotEmpty) {
      await SessionManager.savePatientId(data.patientId);
    }
    if (data.currencyId.isNotEmpty) {
      await SessionManager.saveCurrencyId(data.currencyId);
    }
  }
}
