import 'package:flutter/material.dart';

import 'forms_style.dart';
import 'forms_types.dart';

/// Animated single-select or multi-select choice chips widget.
class ModernChoiceSelector extends StatelessWidget {
  /// Creates a [ModernChoiceSelector].
  const ModernChoiceSelector({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.multiSelect = false,
    this.required = false,
    this.enabled = true,
    this.helperText,
    this.errorText,
    this.style = const FormsStyle(),
    this.onChanged,
  });

  /// Title displayed above the choice chip group.
  final String label;

  /// Available selectable options.
  final List<FormChoiceOption<dynamic>> options;

  /// Current selected value (a single item when [multiSelect] is `false`,
  /// or a `List` of items when [multiSelect] is `true`).
  final dynamic value;

  /// Whether multiple options can be selected simultaneously.
  final bool multiSelect;

  /// Whether a required asterisk indicator is rendered.
  final bool required;

  /// Whether user interaction is enabled.
  final bool enabled;

  /// Optional helper caption below the chips.
  final String? helperText;

  /// Optional validation error message.
  final String? errorText;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked when the selection changes.
  final ValueChanged<dynamic>? onChanged;

  bool _isSelected(dynamic candidate) {
    if (multiSelect) {
      if (value is Iterable) {
        return value.contains(candidate);
      }
      return false;
    }
    return value == candidate;
  }

  void _handleTap(dynamic tappedValue) {
    if (!enabled) return;
    if (multiSelect) {
      final currentList = value is Iterable
          ? List<dynamic>.from(value as Iterable<dynamic>)
          : <dynamic>[];
      if (currentList.contains(tappedValue)) {
        currentList.remove(tappedValue);
      } else {
        currentList.add(tappedValue);
      }
      onChanged?.call(currentList);
    } else {
      onChanged?.call(tappedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldTitleLabel(
          label: label,
          required: required,
          style: style,
          trailingText: multiSelect ? 'Multi-Select' : null,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = _isSelected(option.value);
            return InkWell(
              borderRadius: BorderRadius.circular(style.borderRadius),
              onTap: () => _handleTap(option.value),
              child: AnimatedContainer(
                duration: style.animationDuration,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? style.primaryColor.withValues(alpha: 0.16)
                      : style.fieldFillColor,
                  borderRadius: BorderRadius.circular(style.borderRadius),
                  border: Border.all(
                    color: selected
                        ? style.primaryColor
                        : (hasError ? style.errorColor : style.borderColor),
                    width: selected ? 1.8 : 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (option.icon != null) ...<Widget>[
                      Icon(
                        option.icon,
                        size: 16,
                        color:
                            selected ? style.primaryColor : style.subtitleColor,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option.label,
                      style: TextStyle(
                        color: selected ? style.primaryColor : style.textColor,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (selected) ...<Widget>[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: style.primaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        _FieldSubCaption(
          helperText: helperText,
          errorText: errorText,
          style: style,
        ),
      ],
    );
  }
}

/// Modern styled dropdown selector field.
class ModernDropdownField extends StatelessWidget {
  /// Creates a [ModernDropdownField].
  const ModernDropdownField({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.required = false,
    this.enabled = true,
    this.helperText,
    this.errorText,
    this.style = const FormsStyle(),
    this.onChanged,
  });

  /// Field label displayed above the dropdown.
  final String label;

  /// Available dropdown options.
  final List<FormChoiceOption<dynamic>> options;

  /// Currently selected option value.
  final dynamic value;

  /// Whether a required asterisk indicator is rendered.
  final bool required;

  /// Whether interaction is enabled.
  final bool enabled;

  /// Optional helper caption.
  final String? helperText;

  /// Optional validation error message.
  final String? errorText;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked when a new option is chosen.
  final ValueChanged<dynamic>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final matching = options.where((o) => o.value == value).toList();
    final effectiveValue = matching.isNotEmpty
        ? matching.first.value
        : (options.isNotEmpty ? options.first.value : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldTitleLabel(
          label: label,
          required: required,
          style: style,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: style.fieldFillColor,
            borderRadius: BorderRadius.circular(style.borderRadius),
            border: Border.all(
              color: hasError ? style.errorColor : style.borderColor,
              width: style.borderWidth,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: effectiveValue,
              isExpanded: true,
              dropdownColor: style.cardColor,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: style.primaryColor,
              ),
              items: options.map((opt) {
                return DropdownMenuItem<dynamic>(
                  value: opt.value,
                  child: Row(
                    children: <Widget>[
                      if (opt.icon != null) ...<Widget>[
                        Icon(
                          opt.icon,
                          size: 18,
                          color: style.primaryColor,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          opt.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: style.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
        _FieldSubCaption(
          helperText: helperText,
          errorText: errorText,
          style: style,
        ),
      ],
    );
  }
}

/// Tactile card switch toggle with title, subtitle, and status badge.
class ModernSwitchCard extends StatelessWidget {
  /// Creates a [ModernSwitchCard].
  const ModernSwitchCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.enabled = true,
    this.style = const FormsStyle(),
    this.onChanged,
  });

  /// Primary switch title.
  final String label;

  /// Current boolean toggle state.
  final bool value;

  /// Optional secondary explanation.
  final String? subtitle;

  /// Whether interaction is enabled.
  final bool enabled;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked when toggled.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(style.borderRadius),
      onTap: enabled ? () => onChanged?.call(!value) : null,
      child: AnimatedContainer(
        duration: style.animationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? style.primaryColor.withValues(alpha: 0.1)
              : style.fieldFillColor,
          borderRadius: BorderRadius.circular(style.borderRadius),
          border: Border.all(
            color: value ? style.primaryColor : style.borderColor,
            width: value ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: value
                    ? style.primaryColor.withValues(alpha: 0.18)
                    : style.borderColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                value ? Icons.verified_user_rounded : Icons.shield_outlined,
                size: 19,
                color: value ? style.primaryColor : style.subtitleColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: style.textColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: style.subtitleColor,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              activeTrackColor: style.primaryColor,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive slider field with live badge readout.
class ModernSliderField extends StatelessWidget {
  /// Creates a [ModernSliderField].
  const ModernSliderField({
    super.key,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.helperText,
    this.enabled = true,
    this.style = const FormsStyle(),
    this.onChanged,
  });

  /// Slider field title.
  final String label;

  /// Current numeric value.
  final double value;

  /// Minimum slider bound.
  final double min;

  /// Maximum slider bound.
  final double max;

  /// Optional discrete step divisions.
  final int? divisions;

  /// Optional helper caption.
  final String? helperText;

  /// Whether interaction is enabled.
  final bool enabled;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked when the slider moves.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(min, max);
    final formatted = clamped % 1 == 0
        ? clamped.toInt().toString()
        : clamped.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: style.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: style.fieldFillColor,
            borderRadius: BorderRadius.circular(style.borderRadius),
            border: Border.all(color: style.borderColor),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: style.primaryColor,
              inactiveTrackColor: style.borderColor,
              thumbColor: style.primaryColor,
              overlayColor: style.primaryColor.withValues(alpha: 0.16),
              trackHeight: 5,
            ),
            child: Slider(
              value: clamped,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
        _FieldSubCaption(
          helperText: helperText,
          errorText: null,
          style: style,
        ),
      ],
    );
  }
}

/// Interactive 5-star rating selector with live sentiment badge.
class ModernRatingField extends StatelessWidget {
  /// Creates a [ModernRatingField].
  const ModernRatingField({
    super.key,
    required this.label,
    required this.value,
    this.maxStars = 5,
    this.required = false,
    this.enabled = true,
    this.style = const FormsStyle(),
    this.onChanged,
  });

  /// Rating field title.
  final String label;

  /// Current rating value (`1.0` to [maxStars]).
  final double value;

  /// Total number of stars rendered.
  final int maxStars;

  /// Whether a required asterisk is shown.
  final bool required;

  /// Whether interaction is enabled.
  final bool enabled;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked when a star is tapped.
  final ValueChanged<double>? onChanged;

  String _sentimentForRating(int stars) {
    if (stars <= 1) return 'Needs Work';
    if (stars == 2) return 'Fair';
    if (stars == 3) return 'Good';
    if (stars == 4) return 'Great';
    return 'Outstanding!';
  }

  @override
  Widget build(BuildContext context) {
    final activeStars = value.round().clamp(0, maxStars);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldTitleLabel(
          label: label,
          required: required,
          style: style,
          trailingText: _sentimentForRating(activeStars),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: style.fieldFillColor,
            borderRadius: BorderRadius.circular(style.borderRadius),
            border: Border.all(color: style.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: List<Widget>.generate(maxStars, (index) {
                  final starNumber = index + 1;
                  final filled = starNumber <= activeStars;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: enabled
                          ? () => onChanged?.call(starNumber.toDouble())
                          : null,
                      child: AnimatedContainer(
                        duration: style.animationDuration,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: filled
                              ? style.warningColor.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 26,
                          color: filled ? style.warningColor : style.hintColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Text(
                '$activeStars.0 / $maxStars.0',
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Segmented OTP / PIN code input field with interactive digit boxes.
class ModernOtpField extends StatefulWidget {
  /// Creates a [ModernOtpField].
  const ModernOtpField({
    super.key,
    required this.label,
    this.value = '',
    this.length = 6,
    this.required = false,
    this.enabled = true,
    this.errorText,
    this.style = const FormsStyle(),
    this.onChanged,
  });

  /// Field title displayed above the OTP boxes.
  final String label;

  /// Current OTP code string.
  final String value;

  /// Number of segmented character boxes (`4` or `6`).
  final int length;

  /// Whether a required asterisk indicator is rendered.
  final bool required;

  /// Whether user interaction is enabled.
  final bool enabled;

  /// Active validation error message, if any.
  final String? errorText;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked whenever the OTP code changes.
  final ValueChanged<String>? onChanged;

  @override
  State<ModernOtpField> createState() => _ModernOtpFieldState();
}

class _ModernOtpFieldState extends State<ModernOtpField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant ModernOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text && !_focusNode.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final code = _controller.text;
    final isComplete = code.length == widget.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _FieldTitleLabel(
                label: widget.label,
                required: widget.required,
                style: style,
              ),
            ),
            if (isComplete)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: style.successColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'VERIFIED',
                  style: TextStyle(
                    color: style.successColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
          child: Row(
            children: List<Widget>.generate(widget.length, (index) {
              final char = index < code.length ? code[index] : '';
              final isCurrent = index == code.length && _focusNode.hasFocus;
              return Expanded(
                child: AnimatedContainer(
                  duration: style.animationDuration,
                  height: 48,
                  margin: EdgeInsets.only(
                    right: index < widget.length - 1 ? 8 : 0,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: char.isNotEmpty
                        ? style.primaryColor.withValues(alpha: 0.12)
                        : style.fieldFillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasError
                          ? style.errorColor
                          : (isCurrent || char.isNotEmpty
                              ? style.primaryColor
                              : style.borderColor),
                      width: (isCurrent || char.isNotEmpty) ? 1.8 : 1.2,
                    ),
                  ),
                  child: Text(
                    char.isEmpty ? '•' : char,
                    style: TextStyle(
                      color: char.isEmpty ? style.hintColor : style.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            maxLength: widget.length,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: style.textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
            decoration: InputDecoration(
              hintText: 'Type ${widget.length}-digit code here...',
              hintStyle: TextStyle(color: style.hintColor, fontSize: 12),
              counterText: '',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: style.fieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: style.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: style.borderColor),
              ),
            ),
            onChanged: (val) {
              setState(() {});
              widget.onChanged?.call(val);
            },
          ),
        ),
        _FieldSubCaption(
          helperText: null,
          errorText: widget.errorText,
          style: style,
        ),
      ],
    );
  }
}

class _FieldTitleLabel extends StatelessWidget {
  const _FieldTitleLabel({
    required this.label,
    required this.required,
    required this.style,
    this.trailingText,
  });

  final String label;
  final bool required;
  final FormsStyle style;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: TextStyle(
                    color: style.errorColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        if (trailingText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: style.primaryColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              trailingText!,
              style: TextStyle(
                color: style.primaryColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _FieldSubCaption extends StatelessWidget {
  const _FieldSubCaption({
    required this.helperText,
    required this.errorText,
    required this.style,
  });

  final String? helperText;
  final String? errorText;
  final FormsStyle style;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    if (!hasError && (helperText == null || helperText!.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Text(
        hasError ? errorText! : helperText!,
        style: TextStyle(
          color: hasError ? style.errorColor : style.subtitleColor,
          fontSize: 12,
          fontWeight: hasError ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
