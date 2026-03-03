import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../bloc/healing_focus_bloc.dart';
import '../../bloc/healing_focus_event.dart';
import '../../bloc/healing_focus_state.dart';
import '../widgets/healing_dropdown_field.dart';

class HealingFocusScreen extends StatefulWidget {
  const HealingFocusScreen({super.key});

  @override
  State<HealingFocusScreen> createState() => _HealingFocusScreenState();
}

class _HealingFocusScreenState extends State<HealingFocusScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _stepsData = [
    {
      'id': 1,
      'title': 'Physical Well-Being',
      'image': 'assets/image/physical_wellbeing.png',
      'options': [
        {'label': 'Physical', 'default': 'Pain'},
        {'label': 'Emotional', 'default': 'Stress'},
        {'label': 'Spiritual', 'default': 'Energy blocks'},
      ],
    },
    {
      'id': 2,
      'title': 'Emotional & Mental Well-Being',
      'image': 'assets/image/emotional_wellbeing.png',
      'options': [
        {'label': 'Relationships', 'default': 'Family'},
        {'label': 'Career', 'default': 'Work stress'},
      ],
    },
    {
      'id': 3,
      'title': 'Life Energy & Personal Growth',
      'image': 'assets/image/life_energy.png',
      'options': [
        {'label': 'Finance', 'default': 'Money blocks'},
        {'label': 'Other', 'default': 'Something Personal'},
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HealingFocusBloc(),
      child: BlocConsumer<HealingFocusBloc, HealingFocusState>(
        listener: (context, state) {
          if (state is HealingFocusCompleted) {
            context.push(
              '/success',
              extra: {
                'imagePath': 'assets/image/healingsuccess.png',
                'icon': 'assets/images/right.png',
                'title': "Thank You!",
                'subtitle': "Based on your concern, we’ll match you\nwith Certified Healers who specialize\nin similar issues.",
                'buttonText': "Got it!",
                'onButtonPressed': () => context.push('/home'),
              },
            );          } else {
            _pageController.animateToPage(
              state.currentStep - 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.primaryLiteFE,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  if (state.currentStep > 1) {
                    context.read<HealingFocusBloc>().add(PreviousStep());
                  } else {
                    context.pop();
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 18.sp,
                ),
              ),
              title: Text(
                _stepsData[state.currentStep - 1]['title'],
                style: AppTextStyles.titleMedium,
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0.5.h),
                child: Container(color: AppColors.divider, height: 0.5.h),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stepsData.length,
                    itemBuilder: (context, index) {
                      final data = _stepsData[index];
                      return _buildStepContent(context, data, state);
                    },
                  ),
                ),
                _buildBottomNavigation(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    Map<String, dynamic> data,
    HealingFocusState state,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Center(
            child: CommonImage(
              path: data['image'],
              height: data['id']==2?290.h:data['id']==3?305.h:260.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Your healing focus?',
            style: AppTextStyles.h2.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          Padding(
            padding:  EdgeInsets.only(right: 30.w),
            child: Text(
              'Choose the area where you need support today.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          ...(data['options'] as List).map((opt) {
            final label = opt['label'] as String;
            final defaultValue = opt['default'] as String;
            final currentValue =
                state.selections[data['id']]?[label] ?? defaultValue;

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: HealingDropdownField(
                label: label,
                value: currentValue,
                onTap: () {
                  // Show bottom sheet to select (simplified for now as same to same request)
                  _showSelectionSheet(context, data['id'], label, currentValue);
                },
              ),
            );
          }),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, HealingFocusState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress Bars
        Row(
          children: List.generate(3, (index) {
            final isActive = index < state.currentStep;
            return Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsets.only(
                  right: index == 3 - 1 ? 0 : 8.w,
                ),                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.black
                      : AppColors.indicatorInactive,
                  // borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            );
          }),
        ),

        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: Row(
            children: [
              if(state.currentStep>1)
              TextButton(
                onPressed: () {
                  if (state.currentStep > 1) {
                    context.read<HealingFocusBloc>().add(PreviousStep());
                  } else {
                    context.pop();
                  }
                },
                child: Text(
                  'Back',
                  style: AppTextStyles.bodyLarge.copyWith(

                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 140.w,
                height: 48.h,
                child: CommonButton(
                  text: 'Next',
                  backgroundColor: AppColors.primary,
                  borderRadius: 10.r,
                  textStyle: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: () {
                    context.read<HealingFocusBloc>().add(NextStep());
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSelectionSheet(
    BuildContext context,
    int step,
    String category,
    String currentValue,
  ) {
    // This would typically show options. For "same to same" I'll just keep the logic ready.
    final bloc = context.read<HealingFocusBloc>();
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
              Text(
                'Select $category',
                style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
              ),
              const Divider(),
              // Mock items based on category
              ListTile(
                title: Text(currentValue),
                trailing: const Icon(Icons.check, color: AppColors.primary),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Other Option'),
                onTap: () {
                  bloc.add(
                    SelectOption(
                      step: step,
                      category: category,
                      value: 'Other Option',
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
