import 'package:flutter/material.dart';

import 'forms_controller.dart';
import 'forms_style.dart';
import 'forms_types.dart';
import 'smart_form_builder.dart';

/// Multi-step form wizard widget with animated step progress indicators,
/// per-step validation gates, and customizable navigation controls.
class ModernFormStepper extends StatefulWidget {
  /// Creates a [ModernFormStepper].
  const ModernFormStepper({
    super.key,
    this.controller,
    this.steps,
    this.title = 'Multi-Step Onboarding Wizard',
    this.subtitle = 'Validated step-by-step workflow powered by Humanize AI',
    this.nextLabel = 'Continue',
    this.backLabel = 'Back',
    this.submitLabel = 'Complete Setup',
    this.style = const FormsStyle(),
    this.onStepChanged,
    this.onSubmitted,
  });

  /// Optional external [FormsController]. If omitted, an internal controller
  /// is created and managed automatically.
  final FormsController? controller;

  /// List of [FormStepConfig] steps. Defaults to
  /// [FormsController.buildDefaultWizardSteps] if omitted.
  final List<FormStepConfig>? steps;

  /// Wizard card title.
  final String title;

  /// Wizard card subtitle.
  final String subtitle;

  /// Label for the button that advances to the next step.
  final String nextLabel;

  /// Label for the button that returns to the previous step.
  final String backLabel;

  /// Label for the final submission button on the last step.
  final String submitLabel;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked whenever the active step index changes.
  final ValueChanged<int>? onStepChanged;

  /// Callback invoked when the final step is submitted.
  final ValueChanged<FormSubmissionResult>? onSubmitted;

  @override
  State<ModernFormStepper> createState() => _ModernFormStepperState();
}

class _ModernFormStepperState extends State<ModernFormStepper> {
  FormsController? _internalController;
  late List<FormStepConfig> _steps;

  FormsController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _steps = widget.steps ?? FormsController.buildDefaultWizardSteps();
    if (widget.controller == null) {
      _internalController = FormsController()
        ..registerSteps(_steps, notify: false);
    } else {
      widget.controller!.registerSteps(_steps, notify: false);
    }
  }

  @override
  void didUpdateWidget(covariant ModernFormStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps != null && widget.steps != oldWidget.steps) {
      _steps = widget.steps!;
      _controller.registerSteps(_steps);
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  void _handleNext() {
    final advanced = _controller.nextStep(validateCurrentStep: true);
    if (advanced) {
      widget.onStepChanged?.call(_controller.currentStep);
    }
  }

  void _handleBack() {
    final moved = _controller.previousStep();
    if (moved) {
      widget.onStepChanged?.call(_controller.currentStep);
    }
  }

  Future<void> _handleFinalSubmit() async {
    final stepValid = _controller.validateStep(_controller.currentStep);
    if (!stepValid) return;
    final result = await _controller.submit();
    widget.onSubmitted?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentIndex =
            _controller.currentStep.clamp(0, _steps.length - 1);
        final activeStep = _steps[currentIndex];
        final isLastStep = currentIndex == _steps.length - 1;
        final stepFields = _controller.fields
            .where((f) => f.stepIndex == currentIndex)
            .toList();

        return AnimatedContainer(
          duration: style.animationDuration,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: style.cardColor,
            borderRadius: BorderRadius.circular(style.cardBorderRadius),
            border: Border.all(
              color: style.borderColor,
              width: style.borderWidth,
            ),
            boxShadow: style.boxShadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildWizardTitle(style, currentIndex),
              const SizedBox(height: 18),
              _buildStepProgressHeader(style, currentIndex),
              const SizedBox(height: 18),
              _buildCurrentStepBanner(style, activeStep, currentIndex),
              const SizedBox(height: 16),
              ...stepFields.map((config) {
                return Padding(
                  padding: EdgeInsets.only(bottom: style.fieldSpacing),
                  child: SmartFormBuilder.buildFieldWidget(
                    config: config,
                    controller: _controller,
                    style: style,
                  ),
                );
              }),
              if (_controller.lastSubmission != null) ...<Widget>[
                _buildResultBanner(style, _controller.lastSubmission!),
                const SizedBox(height: 14),
              ],
              _buildNavigationFooter(style, currentIndex, isLastStep),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWizardTitle(FormsStyle style, int currentIndex) {
    return Row(
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: style.accentGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.route_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: style.subtitleColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: style.primaryColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Step ${currentIndex + 1} of ${_steps.length}',
            style: TextStyle(
              color: style.primaryColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepProgressHeader(FormsStyle style, int currentIndex) {
    return Row(
      children: List<Widget>.generate(_steps.length * 2 - 1, (idx) {
        if (idx.isOdd) {
          final leftStep = idx ~/ 2;
          final passed = leftStep < currentIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: style.animationDuration,
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: passed ? style.successColor : style.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }

        final stepIdx = idx ~/ 2;
        final step = _steps[stepIdx];
        final isCompleted = stepIdx < currentIndex;
        final isCurrent = stepIdx == currentIndex;

        final Color nodeColor;
        if (isCompleted) {
          nodeColor = style.successColor;
        } else if (isCurrent) {
          nodeColor = style.primaryColor;
        } else {
          nodeColor = style.borderColor;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (stepIdx <= currentIndex) {
              _controller.goToStep(stepIdx);
              widget.onStepChanged?.call(stepIdx);
            }
          },
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                duration: style.animationDuration,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isCompleted || isCurrent)
                      ? nodeColor
                      : style.fieldFillColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: nodeColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : step.icon,
                  size: 18,
                  color: (isCompleted || isCurrent)
                      ? Colors.white
                      : style.subtitleColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                step.title,
                style: TextStyle(
                  color: isCurrent ? style.textColor : style.subtitleColor,
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStepBanner(
    FormsStyle style,
    FormStepConfig step,
    int currentIndex,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: style.fieldFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            step.icon,
            color: style.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${step.badgeText ?? 'Step ${currentIndex + 1}'} • ${step.title}',
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (step.subtitle != null)
                  Text(
                    step.subtitle!,
                    style: TextStyle(
                      color: style.subtitleColor,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBanner(FormsStyle style, FormSubmissionResult result) {
    final color = result.isSuccess ? style.successColor : style.errorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            result.isSuccess
                ? Icons.verified_rounded
                : Icons.error_outline_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.message ?? 'Wizard completed!',
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter(
    FormsStyle style,
    int currentIndex,
    bool isLastStep,
  ) {
    return Row(
      children: <Widget>[
        if (currentIndex > 0) ...<Widget>[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: style.textColor,
              side: BorderSide(color: style.borderColor),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(style.borderRadius),
              ),
            ),
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 17),
            label: Text(
              widget.backLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(style.borderRadius),
            onTap: isLastStep ? _handleFinalSubmit : _handleNext,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: style.accentGradient,
                borderRadius: BorderRadius.circular(style.borderRadius),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: style.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    isLastStep ? widget.submitLabel : widget.nextLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastStep
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
