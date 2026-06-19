import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../data/datasource/user_profile_api_service.dart';
import '../../data/models/user_profile_model.dart';

class HomeProfileTab extends StatefulWidget {
  const HomeProfileTab({super.key});

  @override
  State<HomeProfileTab> createState() => _HomeProfileTabState();
}

class _HomeProfileTabState extends State<HomeProfileTab> {
  final _api = UserProfileApiService();

  UserProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    await _loadCachedProfile();
    try {
      final fresh = await _api.getProfile();
      await _cacheProfile(fresh);
      if (!mounted) return;
      _applyProfile(fresh);
    } catch (e) {
      if (!mounted) return;
      CommonFlushbar.error(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCachedProfile() async {
    try {
      final raw = await SessionManager.getUserProfileJson();
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        _applyProfile(UserProfileModel.fromJson(map));
      }
    } catch (_) {}
  }

  Future<void> _cacheProfile(UserProfileModel profile) async {
    await SessionManager.saveUserProfileJson(jsonEncode(profile.toJson()));
  }

  void _applyProfile(UserProfileModel profile) {
    _profile = profile;
    setState(() {});
  }

  Future<void> _confirmAndLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Log out?',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'You will need to sign in again to access your sessions and wallet.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 24.h),
                CommonButton(
                  text: 'Log out',
                  backgroundColor: AppColors.darkButton,
                  borderRadius: 12.r,
                  height: 52.h,
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    context.read<AuthBloc>().add(LogoutRequested());
    if (!mounted) return;
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _profile == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final profile = _profile;
    final profileImage = (profile?.profilePic.isNotEmpty ?? false)
        ? profile!.profilePic
        : 'assets/image/doctorprofile.png';
    final coverImage = (profile?.coverImage.isNotEmpty ?? false)
        ? profile!.coverImage
        : 'assets/image/vediocallbackground.png';

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildCoverHeader(
                coverImage,
                profileImage,
                profile?.displayName ?? 'Patient',
                profile?.email ?? '',
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _buildSectionCard(
                  title: 'Personal details',
                  child: Column(
                    children: [
                      _infoRow('First name', profile?.firstName ?? '--'),
                      SizedBox(height: 12.h),
                      _infoRow('Last name', profile?.lastName ?? '--'),
                      SizedBox(height: 12.h),
                      _infoRow('Mobile', profile?.mobile ?? '--'),
                      SizedBox(height: 12.h),
                      _infoRow('Email', profile?.email ?? '--'),
                      SizedBox(height: 12.h),
                      _infoRow('Address line 1', profile?.address1 ?? '--'),
                      SizedBox(height: 12.h),
                      _infoRow('Address line 2', profile?.address2 ?? '--'),
                      SizedBox(height: 12.h),
                      _infoRow('Gender', _genderLabel(profile?.gender)),
                      SizedBox(height: 16.h),
                      _infoRow('DOB', profile?.dob?.split('T').first ?? '--'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CommonButton(
                  text: 'Edit Profile',
                  onPressed: () async {
                    final updated = await context.push(
                      '/edit-profile',
                      extra: _profile,
                    );
                    if (updated is Map) {
                      final profile = updated['profile'];
                      final message = updated['message']?.toString();
                      if (profile is UserProfileModel) {
                        await _cacheProfile(profile);
                        if (!mounted) return;
                        _applyProfile(profile);
                      } else {
                        await _loadProfile();
                      }
                      if (message != null && message.isNotEmpty && mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          CommonFlushbar.success(context, message);
                        });
                      }
                    } else if (updated is UserProfileModel) {
                      await _cacheProfile(updated);
                      if (!mounted) return;
                      _applyProfile(updated);
                    } else {
                      await _loadProfile();
                    }
                  },
                  borderRadius: 12.r,
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CommonButton(
                  text: 'Log out',
                  backgroundColor: Colors.white,
                  textColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  borderRadius: 12.r,
                  onPressed: _confirmAndLogout,
                ),
              ),
              SizedBox(height: 180.h),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverHeader(
    String coverImage,
    String profileImage,
    String name,
    String email,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CommonImage(
                path: coverImage,
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -34.h),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: ClipOval(
                        child: CommonImage(
                          path: profileImage,
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final updated = await context.push(
                            '/edit-profile',
                            extra: _profile,
                          );
                          if (updated is Map) {
                            final profile = updated['profile'];
                            final message = updated['message']?.toString();
                            if (profile is UserProfileModel) {
                              await _cacheProfile(profile);
                              if (!mounted) return;
                              _applyProfile(profile);
                            } else {
                              await _loadProfile();
                            }
                            if (message != null && message.isNotEmpty && mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                CommonFlushbar.success(context, message);
                              });
                            }
                          } else if (updated is UserProfileModel) {
                            await _cacheProfile(updated);
                            if (!mounted) return;
                            _applyProfile(updated);
                          } else {
                            await _loadProfile();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit, size: 14.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  name,
                  style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  email.isEmpty ? '--' : email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value.trim().isEmpty ? '--' : value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _genderLabel(int? gender) {
    switch (gender) {
      case 0:
        return 'Male';
      case 1:
        return 'Female';
      case 2:
        return 'Other';
      default:
        return '--';
    }
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}
