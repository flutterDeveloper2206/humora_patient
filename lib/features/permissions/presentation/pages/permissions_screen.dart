import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/permission_bloc.dart';
import '../bloc/permission_event.dart';
import '../bloc/permission_state.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => PermissionBloc()..add(StartPermissionFlow()),
        child: BlocListener<PermissionBloc, PermissionState>(
          listener: (context, state) {
            if (state is PermissionFlowFinished) {
              context.push('/home');
            }
          },
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
