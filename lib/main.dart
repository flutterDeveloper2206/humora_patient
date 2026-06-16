import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'routes/app_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/stripe_config.dart';
import 'core/network/app_hub_lifecycle.dart';
import 'core/network/connectivity_service.dart';
import 'core/network/signalr_logging.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'package:flutter/services.dart';
import 'dart:ui';

bool _isBenignDebugAssertion(Object error) {
  if (error is! AssertionError) return false;
  final message = error.toString();
  return message.contains('_pressedKeys.containsKey') ||
      message.contains('_idToSocketStatistic');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.urlScheme = StripeConfig.urlScheme;
  await Stripe.instance.applySettings();

  ConnectivityService.instance.bindNavigatorKey(AppRouter.rootNavigatorKey);
  await ConnectivityService.instance.init();

  SignalRLogging.init(enabled: kDebugMode);

  // Intercept the low-level keyevent message channel to catch and suppress the framework desync assertion error
  SystemChannels.keyEvent.setMessageHandler((dynamic message) async {
    try {
      return await ServicesBinding.instance.keyEventManager.handleRawKeyMessage(message);
    } catch (e) {
      if (_isBenignDebugAssertion(e)) {
        // Suppress this transient framework assertion crash gracefully during debugging
        return {'handled': true};
      }
      rethrow;
    }
  });

  // Suppress Flutter framework's keyboard state desync assertion bug globally
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    if (_isBenignDebugAssertion(exception)) {
      return;
    }
    originalOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isBenignDebugAssertion(error)) {
      return true;
    }
    return false;
  };

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AuthBloc())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Based on standard iPhone design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AutoSkeletonConfig(
          data: const AutoSkeletonConfigData(
            baseColor: Color(0xFFE0E0E0),
            highlightColor: Color(0xFFF5F5F5),
          ),
          child: AppHubLifecycle(
            child: MaterialApp.router(
              title: 'Humora Patient',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: AppColors.primary,
                scaffoldBackgroundColor: AppColors.background,
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
                useMaterial3: true,
                fontFamily: 'GeneralSans',
              ),
              routerConfig: AppRouter.router,
            ),
          ),
        );
      },
    );
  }
}
