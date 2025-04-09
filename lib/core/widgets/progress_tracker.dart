import 'package:flutter/material.dart';
import 'package:world_bank_loan/core/theme/app_theme.dart';

class StepProgressTracker extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final bool animated;

  const StepProgressTracker({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    this.animated = true,
  }) : assert(stepTitles.length == totalSteps,
            'Step titles must match total steps');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            final isCurrent = index == currentStep - 1;

            return Expanded(
              child: Row(
                children: [
                  // Step number circle
                  _buildStepCircle(context, index, isActive, isCurrent),

                  // Connector line (except for the last item)
                  if (index < totalSteps - 1)
                    Expanded(
                      child: _buildConnector(isActive),
                    ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            totalSteps,
            (index) => _buildStepTitle(context, index),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCircle(
      BuildContext context, int index, bool isActive, bool isCurrent) {
    final stepNumber = index + 1;

    // Dynamic animations for the current step
    if (isCurrent && animated) {
      return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, double value, child) {
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.authorityBlue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.transparent : AppTheme.neutral300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? AppTheme.authorityBlue.withOpacity(0.3)
                        : Colors.transparent,
                    blurRadius: 8 * value,
                    spreadRadius: 2 * value,
                  ),
                ],
              ),
              child: Center(
                child: isActive
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: AppTheme.neutral700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          );
        },
      );
    }

    // Regular step circles
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.authorityBlue : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.transparent : AppTheme.neutral300,
          width: 1.5,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppTheme.authorityBlue.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: isActive
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
            : Text(
                '$stepNumber',
                style: TextStyle(
                  color: AppTheme.neutral700,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.authorityBlue : AppTheme.neutral300,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Widget _buildStepTitle(BuildContext context, int index) {
    final isActive = index < currentStep;
    final isCurrent = index == currentStep - 1;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Text(
            stepTitles[index],
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive || isCurrent
                      ? AppTheme.authorityBlue
                      : AppTheme.neutral600,
                  fontWeight: isCurrent || isActive
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ProgressIndicatorBar extends StatelessWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final String? label;
  final String? valueLabel;

  const ProgressIndicatorBar({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 8.0,
    this.label,
    this.valueLabel,
  }) : assert(
            progress >= 0 && progress <= 1, 'Progress must be between 0 and 1');

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.neutral200;
    final pgColor = progressColor ?? AppTheme.authorityBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || valueLabel != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.neutral700,
                      ),
                ),
              if (valueLabel != null)
                Text(
                  valueLabel!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.authorityBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
        if (label != null || valueLabel != null) SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: MediaQuery.of(context).size.width * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pgColor, AppTheme.trustCyan],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: pgColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
