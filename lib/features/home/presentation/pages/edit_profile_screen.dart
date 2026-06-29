import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../common/widgets/common_textfield.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/layout/app_layout.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/datasource/user_profile_api_service.dart';
import '../../data/models/user_profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileModel? initialProfile;

  const EditProfileScreen({super.key, this.initialProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _api = UserProfileApiService();
  final _picker = ImagePicker();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _dob = TextEditingController();

  UserProfileModel? _profile;
  int _gender = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobile.dispose();
    _email.dispose();
    _address1.dispose();
    _address2.dispose();
    _dob.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (widget.initialProfile != null) {
      _applyProfile(widget.initialProfile!);
    }
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _api.getProfile();
      await SessionManager.saveUserProfileJson(jsonEncode(profile.toJson()));
      if (!mounted) return;
      _applyProfile(profile);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyProfile(UserProfileModel profile) {
    _profile = profile;
    _firstName.text = profile.firstName;
    _lastName.text = profile.lastName;
    _mobile.text = profile.mobile;
    _email.text = profile.email;
    _address1.text = profile.address1;
    _address2.text = profile.address2;
    _dob.text = profile.dob?.split('T').first ?? '';
    _gender = profile.gender ?? 0;
    setState(() {});
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: AppLayout.datePickerBuilder,
    );
    if (selected == null) return;
    _dob.text = selected.toIso8601String().split('T').first;
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    if (_mobile.text.trim().isEmpty || _mobile.text.trim().length < 10) {
      _showError('Enter a valid mobile number');
      return;
    }
    if (_dob.text.trim().isEmpty) {
      _showError('Please select DOB');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final req = UpdateUserProfileRequest(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        mobile: _mobile.text.trim(),
        address1: _address1.text.trim(),
        address2: _address2.text.trim(),
        gender: _gender,
        dob: _dob.text.trim(),
      );
      await _api.updateProfile(req);
      final fresh = await _api.getProfile();
      await SessionManager.saveUserProfileJson(jsonEncode(fresh.toJson()));
      if (!mounted) return;
      context.pop({
        'profile': fresh,
        'message': 'Profile updated successfully.',
      });
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _updateImage({required bool profileImage}) async {
    if (_isUploadingImage) return;
    final userId = _profile?.id ?? '';
    if (userId.isEmpty) {
      _showError('Profile ID not found. Refresh and retry.');
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);
    try {
      await _api.updateProfileImages(
        userId: userId,
        profilePic: profileImage ? File(picked.path) : null,
        coverImage: profileImage ? null : File(picked.path),
      );
      final fresh = await _api.getProfile();
      await SessionManager.saveUserProfileJson(jsonEncode(fresh.toJson()));
      if (!mounted) return;
      _applyProfile(fresh);
      _showSuccess(
        profileImage ? 'Profile image updated.' : 'Cover image updated.',
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final profileImage = (profile?.profilePic.isNotEmpty ?? false)
        ? profile!.profilePic
        : 'assets/image/doctorprofile.png';
    final coverImage = (profile?.coverImage.isNotEmpty ?? false)
        ? profile!.coverImage
        : 'assets/image/vediocallbackground.png';

    final isBusy = _isLoading || _isSaving || _isUploadingImage;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18.sp),
        ),
      ),
      body: Stack(
        children: [
          _isLoading && _profile == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SafeArea(
                  child: AbsorbPointer(
                    absorbing: isBusy,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
                      children: [
                        _buildHeader(coverImage, profileImage),
                        SizedBox(height: 16.h),
                        _buildFormCard(),
                        SizedBox(height: 20.h),
                        CommonButton(
                          text: _isSaving ? 'Saving...' : 'Save Changes',
                          onPressed: _saveProfile,
                          isDisabled: _isSaving,
                          borderRadius: 12.r,
                        ),
                      ],
                    ),
                  ),
                ),
          if (isBusy && !(_isLoading && _profile == null))
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.08),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(String coverImage, String profileImage) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: CommonImage(
                  path: coverImage,
                  height: 130.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 10.w,
                top: 10.h,
                child: TextButton(
                  onPressed: () => _updateImage(profileImage: false),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  ),
                  child: Text(
                    'Edit cover',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -28.h),
            child: Stack(
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
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _updateImage(profileImage: true),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          CommonTextField(
            controller: _firstName,
            labelText: 'First name',
            hintText: 'Enter first name',
          ),
          SizedBox(height: 12.h),
          CommonTextField(
            controller: _lastName,
            labelText: 'Last name',
            hintText: 'Enter last name',
          ),
          SizedBox(height: 12.h),
          CommonTextField(
            controller: _mobile,
            labelText: 'Mobile',
            hintText: 'Enter mobile',
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 12.h),
          CommonTextField(
            controller: _email,
            labelText: 'Email',
            hintText: 'Email',
            readOnly: true,
          ),
          SizedBox(height: 12.h),
          CommonTextField(
            controller: _address1,
            labelText: 'Address line 1',
            hintText: 'Address line 1',
          ),
          SizedBox(height: 12.h),
          CommonTextField(
            controller: _address2,
            labelText: 'Address line 2',
            hintText: 'Address line 2',
          ),
          SizedBox(height: 12.h),
          _buildGenderPicker(),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _pickDob,
            child: AbsorbPointer(
              child: CommonTextField(
                controller: _dob,
                labelText: 'DOB',
                hintText: 'YYYY-MM-DD',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.label),
        SizedBox(height: 8.h),
        DropdownButtonFormField<int>(
          key: ValueKey('gender_$_gender'),
          initialValue: _gender,
          items: const [
            DropdownMenuItem(value: 0, child: Text('Male')),
            DropdownMenuItem(value: 1, child: Text('Female')),
            DropdownMenuItem(value: 2, child: Text('Other')),
          ],
          onChanged: (v) => setState(() => _gender = v ?? 0),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ],
    );
  }
}
