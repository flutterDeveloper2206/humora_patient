import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/utils/common_flushbar.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class FinishSignupScreen extends StatefulWidget {
  const FinishSignupScreen({super.key});

  @override
  State<FinishSignupScreen> createState() => _FinishSignupScreenState();
}

class _FinishSignupScreenState extends State<FinishSignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedGender = 'Male';
  String? _selectedTimeZone;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18.sp,
          ),
        ),
        title: Text("Finish signing up", style: AppTextStyles.titleMedium),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5.h),
          child: Container(color: AppColors.divider, height: 0.5.h),
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              CommonFlushbar.success(
                context,
                state.message ?? "Signup Completed!",
              );
              context.push('/permissions');
            } else if (state is AuthError) {
              CommonFlushbar.error(context, state.message);
            }
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 18),

                          // Name Section
                          _buildSectionTitle("Enter your name"),
                          SizedBox(height: 10.h),
                          _buildNameCard(),

                          SizedBox(height: 18),

                          // Gender Section
                          _buildSectionTitle("Gender"),
                          SizedBox(height: 10.h),
                          _buildGenderSelection(),

                          SizedBox(height: 18),

                          // About Section

                          // Email Section
                          _buildSectionTitle("Email Address"),
                          SizedBox(height: 10.h),
                          _buildEmailField(),

                          SizedBox(height: 18),

                          // Date of birth Section (from image)
                          _buildSectionTitle("Date of birth"),
                          SizedBox(height: 10.h),
                          _buildDatePickerField(),

                          SizedBox(height: 18),

                          // Time zone Section (from image)
                          _buildSectionTitle("Time zone"),
                          SizedBox(height: 10.h),
                          _buildDropdownField(
                            hint: "Select time zone",
                            value: _selectedTimeZone,
                            items: const [
                              "(GMT-08:00) Pacific Time",
                              "(GMT+05:30) India Standard Time",
                              "(GMT+00:00) UTC",
                            ],
                            onChanged: (val) {
                              setState(() => _selectedTimeZone = val);
                            },
                          ),

                          SizedBox(height: 10.h),
                          _buildFooterText(),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Action Button
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 52.h,
                      child: CommonButton(
                        text: 'Confirm',
                        isLoading: state is AuthLoading,
                        backgroundColor: AppColors.primary,
                        borderRadius: 10.r,
                        textStyle: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: _onConfirmTapped,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConfirmTapped() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        _selectedTimeZone == null) {
      CommonFlushbar.error(context, "Please fill all fields");
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      CommonFlushbar.error(context, "Please enter a valid email");
      return;
    }

    int genderValue = 0;
    if (_selectedGender == 'Female') genderValue = 1;
    if (_selectedGender == 'Other') genderValue = 2;

    // Formatting date to match "2026-05-25" assuming MM/DD/YYYY from picker
    // Let's actually parse and format properly or just use the picker's logic
    String formattedDate = _birthdateController.text;
    try {
      final parts = _birthdateController.text.split('/');
      if (parts.length == 3) {
        final month = parts[0].padLeft(2, '0');
        final day = parts[1].padLeft(2, '0');
        final year = parts[2];
        formattedDate = "$year-$month-$day";
      }
    } catch (_) {}

    context.read<AuthBloc>().add(
      FinishSignupRequested(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        gender: genderValue,
        birthDate: formattedDate,
        timeZone: _selectedTimeZone,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _buildNameCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: "First name",
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          TextField(
            controller: _lastNameController,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: "Last name",
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TextField(
        controller: _emailController,
        style: AppTextStyles.bodyMedium,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: "Email address",
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      height: 52.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGenderOption("Male"),
          _buildGenderOption("Female"),
          _buildGenderOption("Other"),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final bool isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.black : AppColors.divider,
                width: 1.5,
              ),
            ),
            padding: EdgeInsets.all(1.w),
            child: isSelected
                ? Container(
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Text(
            gender,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: _birthdateController,
        readOnly: true,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null) {
            setState(() {
              _birthdateController.text =
                  "${date.month}/${date.day}/${date.year}";
            });
          }
        },
        decoration: InputDecoration(
          hintText: "Birthdate",
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    String? label,
    String? hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InkWell(
      onTap: () => _showSelectionSheet(
        title: label ?? hint ?? "Select",
        items: items,
        selectedValue: value,
        onSelected: onChanged,
      ),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: label != null ? 7.h : 12.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  Text(
                    value ?? hint ?? "",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 15.sp,
                      color: value == null
                          ? AppColors.textHint
                          : AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.black),
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
              SizedBox(height: 10.h),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;
                    return ListTile(
                      title: Text(
                        item,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooterText() {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        children: [
          const TextSpan(
            text: "By selecting Agree and continue, I agree to Humora’s ",
          ),
          _linkSpan("Terms of Service", () {}),
          const TextSpan(text: ", "),
          _linkSpan("Payment Terms of Service", () {}),
          const TextSpan(text: " and "),
          _linkSpan("Notification Policy", () {}),
          const TextSpan(text: " and acknowledge the "),
          _linkSpan("Privacy Policy", () {}),
          const TextSpan(text: "."),
        ],
      ),
    );
  }

  TextSpan _linkSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }
}
