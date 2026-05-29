import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'routes/app_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/stripe_config.dart';
import 'features/auth/bloc/auth_bloc.dart';

import 'package:flutter/services.dart';
import 'dart:ui';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.urlScheme = StripeConfig.urlScheme;
  await Stripe.instance.applySettings();

  // Intercept the low-level keyevent message channel to catch and suppress the framework desync assertion error
  SystemChannels.keyEvent.setMessageHandler((dynamic message) async {
    try {
      return await ServicesBinding.instance.keyEventManager.handleRawKeyMessage(message);
    } catch (e) {
      if (e is AssertionError &&
          e.toString().contains('_pressedKeys.containsKey')) {
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
    if (exception is AssertionError &&
        exception.toString().contains('_pressedKeys.containsKey(event.physicalKey)')) {
      return;
    }
    originalOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is AssertionError &&
        error.toString().contains('_pressedKeys.containsKey(event.physicalKey)')) {
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
        );
      },
    );
  }
}
