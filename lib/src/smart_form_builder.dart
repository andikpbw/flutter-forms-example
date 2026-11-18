import 'package:flutter/material.dart';

import 'forms_controller.dart';
import 'forms_style.dart';
import 'forms_types.dart';
import 'modern_choice_selector.dart';
import 'modern_text_field.dart';

/// Declarative, schema-driven modern form renderer with live completion
/// progress, template switching, JSON payload inspector, and validation feedback.
class SmartFormBuilder extends StatefulWidget {
  /// Creates a [SmartFormBuilder].
  const SmartFormBuilder({
    super.key,
    this.controller,
    this.fields,
    this.preset = FormTemplatePreset.authSignup,
    this.title,
    this.subtitle,
    this.submitLabel = 'Submit Form',
    this.resetLabel = 'Reset',
    this.showHeader = true,
    this.showProgress = true,
    this.showPresetSelector = false,
    this.showResetButton = true,
    this.showJsonPreview = false,
    this.style = const FormsStyle(),
    this.onSubmitted,
    this.onFieldChanged,
  });

  /// External [FormsController] instance. If omitted, an internal controller
  /// is created automatically.
  final FormsController? controller;

  /// Explicit list of [FormFieldConfig] fields. If omitted, [preset] is loaded.
  final List<FormFieldConfig>? fields;

  /// Default [FormTemplatePreset] used when [fields] is not provided.
  final FormTemplatePreset preset;

  /// Optional custom header title (defaults to the active preset's title).
  final String? title;

  /// Optional custom header subtitle (defaults to the active preset's subtitle).
  final String? subtitle;

  /// Label displayed on the primary submit button.
  final String submitLabel;

  /// Label displayed on the secondary reset button.
  final String resetLabel;

  /// Whether the form title and subtitle header block is rendered.
  final bool showHeader;

  /// Whether the live completion progress bar is rendered.
  final bool showProgress;

  /// Whether a pill bar for switching between the 4 built-in [FormTemplatePreset]s
  /// is rendered at the top of the card.
  final bool showPresetSelector;

  /// Whether the secondary reset button is shown next to the submit CTA.
  final bool showResetButton;

  /// Whether the live JSON payload inspector is initially expanded.
  final bool showJsonPreview;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked when the user triggers a form submission.
  final ValueChanged<FormSubmissionResult>? onSubmitted;

  /// Callback invoked whenever an individual field's value changes.
  final void Function(String key, dynamic value)? onFieldChanged;

  /// Renders a single [FormFieldConfig] bound to [controller] using [style].
  static Widget buildFieldWidget({
    required FormFieldConfig config,
    required FormsController controller,
    required FormsStyle style,
    void Function(String key, dynamic value)? onFieldChanged,
  }) {
    final currentValue = controller.getValue<dynamic>(config.key);
    final currentError = controller.getError(config.key);

    void updateVal(dynamic newValue) {
      controller.setValue(config.key, newValue);
      onFieldChanged?.call(config.key, newValue);
    }

    switch (config.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.password:
      case FormFieldType.number:
      case FormFieldType.multiline:
      case FormFieldType.creditCard:
      case FormFieldType.datePicker:
        return ModernTextField(
          key: ValueKey<String>('field_${config.key}'),
          fieldKey: config.key,
          label: config.label,
          type: config.type,
          initialValue: currentValue,
          hint: config.hint,
          helperText: config.helperText,
          errorText: currentError,
          required: config.required,
          enabled: config.enabled,
          prefixIcon: config.prefixIcon,
          suffixIcon: config.suffixIcon,
          maxLength: config.maxLength,
          maxLines: config.maxLines,
          min: config.min,
          max: config.max,
          step: config.step,
          emailDomains: config.emailDomains,
          showPasswordMeter: config.showPasswordMeter,
          style: style,
          onChanged: updateVal,
        );

      case FormFieldType.choiceChips:
        return ModernChoiceSelector(
          key: ValueKey<String>('field_${config.key}'),
          label: config.label,
          options: config.options,
          value: currentValue,
          multiSelect: config.multiSelect,
          required: config.required,
          enabled: config.enabled,
          helperText: config.helperText,
          errorText: currentError,
          style: style,
          onChanged: updateVal,
        );

      case FormFieldType.dropdown:
        return ModernDropdownField(
          key: ValueKey<String>('field_${config.key}'),
          label: config.label,
          options: config.options,
          value: currentValue,
          required: config.required,
          enabled: config.enabled,
          helperText: config.helperText,
          errorText: currentError,
          style: style,
          onChanged: updateVal,
        );

      case FormFieldType.switchToggle:
        return ModernSwitchCard(
          key: ValueKey<String>('field_${config.key}'),
          label: config.label,
          subtitle: config.helperText,
          value: currentValue is bool ? currentValue : false,
          enabled: config.enabled,
          style: style,
          onChanged: updateVal,
        );

      case FormFieldType.slider:
        final numericVal =
            currentValue is num ? currentValue.toDouble() : config.min;
        return ModernSliderField(
          key: ValueKey<String>('field_${config.key}'),
          label: config.label,
          value: numericVal,
          min: config.min,
          max: config.max,
          divisions: config.divisions,
          helperText: config.helperText,
          enabled: config.enabled,
          style: style,
          onChanged: updateVal,
        );

      case FormFieldType.rating:
        final ratingVal = currentValue is num ? currentValue.toDouble() : 5.0;
        return ModernRatingField(
          key: ValueKey<String>('field_${config.key}'),
          label: config.label,
          value: ratingVal,
          maxStars: config.max.round().clamp(1, 10),
          required: config.required,
          enabled: config.enabled,
          style: style,
          onChanged: updateVal,
        );

      case FormFieldType.otp:
        return ModernOtpField(
          key: ValueKey<String>('field_${config.key}'),
          label: config.label,
          value: currentValue?.toString() ?? '',
          length: config.otpLength,
          required: config.required,
          enabled: config.enabled,
          errorText: currentError,
          style: style,
          onChanged: updateVal,
        );
    }
  }

  @override
  State<SmartFormBuilder> createState() => _SmartFormBuilderState();
}

class _SmartFormBuilderState extends State<SmartFormBuilder> {
  FormsController? _internalController;
  late bool _jsonExpanded;

  FormsController get _controller => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _jsonExpanded = widget.showJsonPreview;
    if (widget.controller == null) {
      _internalController = FormsController(
        fields: widget.fields,
        preset: widget.fields == null ? widget.preset : null,
      );
    } else if (widget.fields != null) {
      widget.controller!.registerFields(widget.fields!, notify: false);
    } else if (widget.controller!.fields.isEmpty) {
      widget.controller!.applyPreset(widget.preset, notify: false);
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final result = await _controller.submit();
    widget.onSubmitted?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final activePreset = _controller.activePreset ?? widget.preset;
        final displayTitle = widget.title ?? activePreset.title;
        final displaySubtitle = widget.subtitle ?? activePreset.subtitle;
        final fields = _controller.fields;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.showPresetSelector) ...<Widget>[
                _buildPresetSelectorBar(style, activePreset),
                const SizedBox(height: 16),
              ],
              if (widget.showHeader) ...<Widget>[
                _buildHeader(
                    style, activePreset, displayTitle, displaySubtitle),
                const SizedBox(height: 16),
              ],
              if (widget.showProgress) ...<Widget>[
                _buildProgressBanner(style),
                const SizedBox(height: 18),
              ],
              ...fields.map((config) {
                return Padding(
                  padding: EdgeInsets.only(bottom: style.fieldSpacing),
                  child: SmartFormBuilder.buildFieldWidget(
                    config: config,
                    controller: _controller,
                    style: style,
                    onFieldChanged: widget.onFieldChanged,
                  ),
                );
              }),
              if (_controller.lastSubmission != null) ...<Widget>[
                _buildSubmissionFeedbackBanner(
                  style,
                  _controller.lastSubmission!,
                ),
                const SizedBox(height: 14),
              ],
              _buildActionButtons(style),
              const SizedBox(height: 12),
              _buildJsonInspectorSection(style),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetSelectorBar(
    FormsStyle style,
    FormTemplatePreset activePreset,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FormTemplatePreset.values.map((preset) {
          final isSelected = preset == activePreset;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _controller.applyPreset(preset),
              child: AnimatedContainer(
                duration: style.animationDuration,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? style.accentGradient : null,
                  color: isSelected ? null : style.fieldFillColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? style.primaryColor : style.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      preset.icon,
                      size: 15,
                      color: isSelected ? Colors.white : style.subtitleColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      preset.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : style.textColor,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader(
    FormsStyle style,
    FormTemplatePreset preset,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: style.accentGradient,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            preset.icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: style.subtitleColor,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBanner(FormsStyle style) {
    final pct = _controller.completionPercentage;
    final completed = _controller.completedFieldsCount;
    final total = _controller.totalFieldsCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: style.fieldFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.borderColor),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Form Readiness ($completed/$total fields valid)',
                style: TextStyle(
                  color: style.subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: pct == 100 ? style.successColor : style.primaryColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _controller.completionProgress,
              minHeight: 6,
              backgroundColor: style.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct == 100 ? style.successColor : style.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionFeedbackBanner(
    FormsStyle style,
    FormSubmissionResult result,
  ) {
    final color = result.isSuccess ? style.successColor : style.errorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            result.isSuccess
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.message ??
                  (result.isSuccess
                      ? 'Form submitted successfully!'
                      : 'Validation failed.'),
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

  Widget _buildActionButtons(FormsStyle style) {
    return Row(
      children: <Widget>[
        if (widget.showResetButton) ...<Widget>[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: style.subtitleColor,
              side: BorderSide(color: style.borderColor),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(style.borderRadius),
              ),
            ),
            onPressed: _controller.reset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              widget.resetLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(style.borderRadius),
            onTap: _controller.isSubmitting ? null : _handleSubmit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: style.accentGradient,
                borderRadius: BorderRadius.circular(style.borderRadius),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: style.primaryColor.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.submitLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJsonInspectorSection(FormsStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _jsonExpanded = !_jsonExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.data_object_rounded,
                  size: 16,
                  color: style.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  _jsonExpanded
                      ? 'Hide Live Form Payload (JSON)'
                      : 'Inspect Live Form Payload (JSON)',
                  style: TextStyle(
                    color: style.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  _jsonExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: style.primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (_jsonExpanded) ...<Widget>[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: style.fieldFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: style.borderColor),
            ),
            child: Text(
              _controller.toFormattedJson(),
              style: TextStyle(
                color: style.textColor,
                fontFamily: 'monospace',
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
