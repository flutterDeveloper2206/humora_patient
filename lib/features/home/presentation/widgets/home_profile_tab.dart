import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/layout/app_layout.dart';
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
      CommonFlushbar.error(context, e.toString().replaceAll('Exception: ', ''));
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

  Future<void> _openEditProfile() async {
    final updated = await context.push('/edit-profile', extra: _profile);
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
  }

  void _openLegal({required String title, required String body}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LegalContentScreen(title: title, body: body),
      ),
    );
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: AppLayout.homeBottomNavPadding),
          children: [
            _buildCoverHeader(
              coverImage,
              profileImage,
              profile?.displayName ?? 'Patient',
              profile?.email ?? '',
            ),
            // SizedBox(height: 20.h),
            // _buildPersonalDetailsCard(profile),
            SizedBox(height: 20.h),
            _buildMenuSection(
              title: 'Account',
              tiles: [
                _MenuTileData(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: _openEditProfile,
                ),
                _MenuTileData(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  onTap: () => context.push('/wallet'),
                ),
                _MenuTileData(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildMenuSection(
              title: 'More',
              tiles: [
                _MenuTileData(
                  icon: Icons.shield_outlined,
                  label: 'Privacy Policy',
                  onTap: () => _openLegal(
                    title: 'Privacy Policy',
                    body: _privacyPolicyText,
                  ),
                ),
                _MenuTileData(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () =>
                      _openLegal(title: 'Terms & Conditions', body: _termsText),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CommonButton(
                text: 'Log out',
                backgroundColor: Colors.white,
                textColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                borderRadius: 12.r,
                onPressed: _confirmAndLogout,
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuTileData> tiles,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
            child: Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  _menuTile(tiles[i]),
                  if (i != tiles.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 56.w,
                      color: AppColors.divider,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(_MenuTileData data) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLite,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLiteChip),
                ),
                child: Icon(data.icon, size: 18.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  data.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: AppColors.textHint,
              ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 26.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFFB0123A)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CommonImage(
                      path: profileImage,
                      width: 84.w,
                      height: 84.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _openEditProfile,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryLiteChip),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 14.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    email.isEmpty ? '--' : email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsCard(UserProfileModel? profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Row(
                children: [
                  Text(
                    'Personal details',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openEditProfile,
                    child: Text(
                      'Edit',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: AppColors.divider),
            _detailTile(Icons.badge_outlined, 'First name', profile?.firstName),
            _detailDivider(),
            _detailTile(Icons.badge_outlined, 'Last name', profile?.lastName),
            _detailDivider(),
            _detailTile(Icons.phone_outlined, 'Mobile', profile?.mobile),
            _detailDivider(),
            _detailTile(Icons.email_outlined, 'Email', profile?.email),
            _detailDivider(),
            _detailTile(
              Icons.location_on_outlined,
              'Address line 1',
              profile?.address1,
            ),
            _detailDivider(),
            _detailTile(
              Icons.location_on_outlined,
              'Address line 2',
              profile?.address2,
            ),
            _detailDivider(),
            _detailTile(
              Icons.wc_outlined,
              'Gender',
              _genderLabel(profile?.gender),
            ),
            _detailDivider(),
            _detailTile(
              Icons.cake_outlined,
              'Date of birth',
              profile?.dob?.split('T').first,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailDivider() =>
      Divider(height: 1, thickness: 1, indent: 56.w, color: AppColors.divider);

  Widget _detailTile(IconData icon, String label, String? value) {
    final display = (value == null || value.trim().isEmpty) ? '--' : value;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.primaryLite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLiteChip),
            ),
            child: Icon(icon, size: 16.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  display,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
}

class _MenuTileData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTileData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _LegalContentScreen extends StatelessWidget {
  final String title;
  final String body;

  const _LegalContentScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: 28.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18.sp),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        children: [
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

const String _privacyPolicyText =
    'Your privacy matters to us. This Privacy Policy explains how Humora '
    'collects, uses, and protects your personal information when you use the '
    'app.\n\n'
    '1. Information We Collect\n'
    'We collect details you provide during sign up and profile setup, such as '
    'your name, contact details, and preferences, as well as session and '
    'payment activity needed to deliver our services.\n\n'
    '2. How We Use Your Information\n'
    'We use your information to connect you with healers, manage bookings and '
    'wallet payments, send important notifications, and improve your '
    'experience.\n\n'
    '3. Data Security\n'
    'We apply reasonable technical and organisational measures to safeguard '
    'your data. Your sessions and messages are handled with strict '
    'confidentiality.\n\n'
    '4. Sharing\n'
    'We only share information necessary to provide the service (for example '
    'with your chosen healer) and never sell your personal data.\n\n'
    '5. Your Choices\n'
    'You can review and update your profile at any time, and contact our '
    'support team for any privacy-related requests.\n\n'
    'For any questions about this policy, please reach out to our support '
    'team within the app.';

const String _termsText =
    'Welcome to Humora. By using this app you agree to the following Terms & '
    'Conditions. Please read them carefully.\n\n'
    '1. Use of Service\n'
    'Humora connects patients with verified healers for consultations, '
    'sessions, and chat. You agree to use the platform only for lawful '
    'purposes.\n\n'
    '2. Bookings & Payments\n'
    'Session fees and live consultation charges are shown before you confirm. '
    'Wallet top-ups and deductions are processed securely. Charges for live '
    'sessions may apply per minute as displayed.\n\n'
    '3. Cancellations\n'
    'Cancellation and refund eligibility depends on the session type and '
    'timing. Please review the details shown at the time of booking.\n\n'
    '4. Conduct\n'
    'You agree to interact respectfully with healers and other users. Misuse '
    'of the platform may lead to suspension of your account.\n\n'
    '5. Medical Disclaimer\n'
    'Humora supports wellbeing and healing guidance and is not a substitute '
    'for emergency medical care. In an emergency, contact local services '
    'immediately.\n\n'
    '6. Changes\n'
    'We may update these terms from time to time. Continued use of the app '
    'means you accept the updated terms.';
