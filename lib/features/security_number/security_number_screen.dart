import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'bloc/security_number_bloc.dart';
import 'bloc/security_number_event.dart';
import 'bloc/security_number_state.dart';

class SecurityNumberScreen extends StatelessWidget {
  const SecurityNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SecurityNumberBloc(),
      child: const SecurityNumberView(),
    );
  }
}

class SecurityNumberView extends StatefulWidget {
  const SecurityNumberView({super.key});

  @override
  State<SecurityNumberView> createState() => _SecurityNumberViewState();
}

class _SecurityNumberViewState extends State<SecurityNumberView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 25,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text("Security Number", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: BlocConsumer<SecurityNumberBloc, SecurityNumberState>(
        listener: (context, state) {
          if (state.status == SecurityNumberStatus.success) {
            context.push(
              '/success',
              extra: {
                'imagePath': 'assets/images/bankb.png',
                'icon': 'assets/images/right.png',
                'title': "Congratulations!",
                'subtitle': "Your bank details have been added\nsuccessfully.",
                'onButtonPressed': () =>
                    context.go('/experience-qualifications'),
              },
            );
          } else if (state.status == SecurityNumberStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "An error occurred"),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 32.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter your Social Security Number (SSN)",
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "9-digit identification number",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildPinInput(context, state),
                      SizedBox(height: 32.h),
                      Text(
                        "Your SSN is securely collected only for weekly payment processing and government compliance. We never share your information.",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPinInput(BuildContext context, SecurityNumberState state) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.surface1.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(9, (index) {
              return Container(
                width: 20.w,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index >= state.ssn.length) ...{
                      Container(
                        height: 2.h,
                        width: 12.w,
                        color: AppColors.black,
                        margin: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    } else ...{
                      Text(
                        index < state.ssn.length ? state.ssn[index] : "",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    },
                  ],
                ),
              );
            }),
          ),
        ),
        Positioned.fill(
          child: TextField(
            controller: _controller,
            onChanged: (val) {
              context.read<SecurityNumberBloc>().add(UpdateSSN(val));
            },
            keyboardType: TextInputType.number,
            maxLength: 9,
            cursorColor: Colors.transparent,
            style: const TextStyle(color: Colors.transparent),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, SecurityNumberState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: CommonButton(
        text: "Confirm",
        isLoading: state.status == SecurityNumberStatus.loading,
        isDisabled: !state.isValid,
        onPressed: () {
          context.read<SecurityNumberBloc>().add(SubmitSSN());
        },
        borderRadius: 12.r,
      ),
    );
  }
}
