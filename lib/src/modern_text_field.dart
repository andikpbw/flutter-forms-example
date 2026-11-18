import 'package:flutter/material.dart';

import 'forms_style.dart';
import 'forms_types.dart';
import 'forms_validators.dart';

/// A modern, lightweight, and highly customizable input field widget supporting
/// text, email domain quick-chips, password entropy meters, numeric steppers,
/// auto-formatted Luhn credit card numbers, date selection, and multiline text.
class ModernTextField extends StatefulWidget {
  /// Creates a [ModernTextField].
  const ModernTextField({
    super.key,
    required this.label,
    this.fieldKey,
    this.type = FormFieldType.text,
    this.initialValue,
    this.hint,
    this.helperText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.min = 0,
    this.max = 1000,
    this.step = 1,
    this.emailDomains = const <String>[
      'humanize.id',
      'gmail.com',
      'outlook.com',
    ],
    this.showPasswordMeter = true,
    this.style = const FormsStyle(),
    this.onChanged,
    this.onSubmitted,
  });

  /// Field title displayed above the input container.
  final String label;

  /// Optional unique identifier key for testing or form binding.
  final String? fieldKey;

  /// Functional input mode (`text`, `email`, `password`, `number`, `creditCard`, etc.).
  final FormFieldType type;

  /// Initial string or numeric value displayed in the input.
  final dynamic initialValue;

  /// Placeholder hint displayed when the field is empty.
  final String? hint;

  /// Helper description displayed below the field when no error is active.
  final String? helperText;

  /// Active validation error message, or `null` when valid.
  final String? errorText;

  /// Whether an asterisk badge is shown next to [label].
  final bool required;

  /// Whether user interaction is enabled.
  final bool enabled;

  /// Optional leading icon inside the field container.
  final IconData? prefixIcon;

  /// Optional trailing icon inside the field container.
  final IconData? suffixIcon;

  /// Optional character limit.
  final int? maxLength;

  /// Visible lines count (automatically >1 when [type] is [FormFieldType.multiline]).
  final int maxLines;

  /// Minimum value for [FormFieldType.number].
  final double min;

  /// Maximum value for [FormFieldType.number].
  final double max;

  /// Step delta for [FormFieldType.number] increment/decrement buttons.
  final double step;

  /// Quick-insert domain pills for [FormFieldType.email].
  final List<String> emailDomains;

  /// Whether [FormFieldType.password] renders the live 4-segment strength meter.
  final bool showPasswordMeter;

  /// Visual theme configuration.
  final FormsStyle style;

  /// Callback invoked whenever the field value changes.
  final ValueChanged<dynamic>? onChanged;

  /// Callback invoked when the user submits the field from the keyboard.
  final ValueChanged<String>? onSubmitted;

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: _formatInitialValue(widget.initialValue),
    );
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = _formatInitialValue(widget.initialValue);
    if (incoming != _textController.text && !_isFocused) {
      _textController.text = incoming;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  String _formatInitialValue(dynamic val) {
    if (val == null) return '';
    if (widget.type == FormFieldType.creditCard) {
      return FormsValidator.formatCardNumber(val.toString());
    }
    if (widget.type == FormFieldType.number && val is num) {
      return val % 1 == 0 ? val.toInt().toString() : val.toString();
    }
    return val.toString();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _handleTextChanged(String raw) {
    if (widget.type == FormFieldType.creditCard) {
      final formatted = FormsValidator.formatCardNumber(raw);
      if (formatted != raw) {
        _textController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      setState(() {});
      widget.onChanged?.call(formatted);
      return;
    }

    if (widget.type == FormFieldType.number) {
      final parsed = num.tryParse(raw.trim());
      setState(() {});
      widget.onChanged?.call(parsed ?? raw);
      return;
    }

    setState(() {});
    widget.onChanged?.call(raw);
  }

  void _stepNumericValue(double delta) {
    if (!widget.enabled) return;
    final current = double.tryParse(_textController.text.trim()) ?? widget.min;
    final next = (current + delta).clamp(widget.min, widget.max);
    final formatted =
        next % 1 == 0 ? next.toInt().toString() : next.toStringAsFixed(1);
    _textController.text = formatted;
    setState(() {});
    widget.onChanged?.call(next % 1 == 0 ? next.toInt() : next);
  }

  void _applyEmailDomain(String domain) {
    if (!widget.enabled) return;
    final current = _textController.text.trim();
    final atIndex = current.indexOf('@');
    final localPart = atIndex >= 0
        ? current.substring(0, atIndex)
        : (current.isEmpty ? 'user' : current);
    final updated = '$localPart@$domain';
    _textController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
    setState(() {});
    widget.onChanged?.call(updated);
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return;
    final initial =
        DateTime.tryParse(_textController.text) ?? DateTime(2026, 12, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      final iso =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _textController.text = iso;
      setState(() {});
      widget.onChanged?.call(iso);
    }
  }

  IconData _resolvePrefixIcon() {
    if (widget.prefixIcon != null) return widget.prefixIcon!;
    switch (widget.type) {
      case FormFieldType.email:
        return Icons.alternate_email_rounded;
      case FormFieldType.password:
        return Icons.lock_outline_rounded;
      case FormFieldType.number:
        return Icons.tag_rounded;
      case FormFieldType.creditCard:
        return Icons.credit_card_rounded;
      case FormFieldType.datePicker:
        return Icons.calendar_today_rounded;
      case FormFieldType.multiline:
        return Icons.notes_rounded;
      default:
        return Icons.edit_outlined;
    }
  }

  TextInputType _resolveKeyboardType() {
    switch (widget.type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
      case FormFieldType.creditCard:
        return TextInputType.number;
      case FormFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final text = _textController.text;
    final isFilled = text.trim().isNotEmpty;

    final Color activeBorderColor;
    if (hasError) {
      activeBorderColor = style.errorColor;
    } else if (_isFocused) {
      activeBorderColor = style.primaryColor;
    } else if (isFilled && style.showValidationIcon) {
      activeBorderColor = style.successColor.withValues(alpha: 0.45);
    } else {
      activeBorderColor = style.borderColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeaderRow(style, text),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: style.animationDuration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color:
                _isFocused ? style.fieldFocusedFillColor : style.fieldFillColor,
            borderRadius: BorderRadius.circular(style.borderRadius),
            border: Border.all(
              color: activeBorderColor,
              width: (_isFocused || hasError)
                  ? style.focusedBorderWidth
                  : style.borderWidth,
            ),
            boxShadow: _isFocused
                ? <BoxShadow>[
                    BoxShadow(
                      color: (hasError ? style.errorColor : style.primaryColor)
                          .withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Row(
            crossAxisAlignment: widget.type == FormFieldType.multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  top: widget.type == FormFieldType.multiline ? 14 : 0,
                ),
                child: Icon(
                  _resolvePrefixIcon(),
                  size: 19,
                  color: hasError
                      ? style.errorColor
                      : (_isFocused ? style.primaryColor : style.subtitleColor),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  readOnly: widget.type == FormFieldType.datePicker,
                  onTap: widget.type == FormFieldType.datePicker
                      ? _pickDate
                      : null,
                  obscureText:
                      widget.type == FormFieldType.password && _obscurePassword,
                  keyboardType: _resolveKeyboardType(),
                  maxLines: widget.type == FormFieldType.multiline
                      ? widget.maxLines
                      : 1,
                  maxLength: widget.maxLength,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing:
                        widget.type == FormFieldType.creditCard ? 1.1 : 0.1,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: style.hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    counterText: '',
                    contentPadding: style.contentPadding,
                  ),
                  onChanged: _handleTextChanged,
                  onSubmitted: widget.onSubmitted,
                ),
              ),
              _buildTrailingActions(style, text, hasError, isFilled),
            ],
          ),
        ),
        if (widget.type == FormFieldType.email &&
            widget.emailDomains.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          _buildEmailDomainChips(style, text),
        ],
        if (widget.type == FormFieldType.password &&
            widget.showPasswordMeter) ...<Widget>[
          const SizedBox(height: 8),
          _buildPasswordMeter(style, text),
        ],
        _buildFooterMessage(style, hasError),
      ],
    );
  }

  Widget _buildHeaderRow(FormsStyle style, String text) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.required)
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
        if (widget.type == FormFieldType.creditCard)
          _buildCardBrandBadge(style, text),
        if (widget.maxLength != null)
          Text(
            '${text.length}/${widget.maxLength}',
            style: TextStyle(
              color: style.subtitleColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildCardBrandBadge(FormsStyle style, String text) {
    final brand = FormsValidator.detectCardBrand(text);
    final isLuhn = FormsValidator.isLuhnValid(text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: style.primaryColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: style.primaryColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(brand.icon, size: 12, color: style.primaryColor),
              const SizedBox(width: 4),
              Text(
                brand.label,
                style: TextStyle(
                  color: style.primaryColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (isLuhn) ...<Widget>[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: style.successColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'LUHN OK',
              style: TextStyle(
                color: style.successColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingActions(
    FormsStyle style,
    String text,
    bool hasError,
    bool isFilled,
  ) {
    final actions = <Widget>[];

    if (widget.type == FormFieldType.number) {
      actions.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _StepperIconButton(
              icon: Icons.remove_rounded,
              style: style,
              onTap: () => _stepNumericValue(-widget.step),
            ),
            const SizedBox(width: 4),
            _StepperIconButton(
              icon: Icons.add_rounded,
              style: style,
              onTap: () => _stepNumericValue(widget.step),
            ),
            const SizedBox(width: 8),
          ],
        ),
      );
      return Row(mainAxisSize: MainAxisSize.min, children: actions);
    }

    if (widget.type == FormFieldType.password) {
      actions.add(
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          onPressed: widget.enabled
              ? () => setState(() => _obscurePassword = !_obscurePassword)
              : null,
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 19,
            color: style.subtitleColor,
          ),
        ),
      );
    } else if (widget.type == FormFieldType.datePicker) {
      actions.add(
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Select date',
          onPressed: widget.enabled ? _pickDate : null,
          icon: Icon(
            Icons.event_available_rounded,
            size: 19,
            color: style.primaryColor,
          ),
        ),
      );
    } else if (isFilled && widget.enabled) {
      actions.add(
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Clear text',
          onPressed: () {
            _textController.clear();
            setState(() {});
            widget.onChanged?.call('');
          },
          icon: Icon(
            Icons.close_rounded,
            size: 17,
            color: style.subtitleColor,
          ),
        ),
      );
    }

    if (style.showValidationIcon && (hasError || isFilled)) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            hasError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            size: 18,
            color: hasError ? style.errorColor : style.successColor,
          ),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  Widget _buildEmailDomainChips(FormsStyle style, String currentText) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.emailDomains.map((domain) {
        final isSelected = currentText.endsWith('@$domain');
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _applyEmailDomain(domain),
          child: AnimatedContainer(
            duration: style.animationDuration,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? style.primaryColor.withValues(alpha: 0.16)
                  : style.fieldFillColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? style.primaryColor : style.borderColor,
              ),
            ),
            child: Text(
              '@$domain',
              style: TextStyle(
                color: isSelected ? style.primaryColor : style.subtitleColor,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPasswordMeter(FormsStyle style, String password) {
    final analysis = FormsValidator.analyzePassword(password);
    final Color barColor;
    switch (analysis.level) {
      case PasswordStrengthLevel.empty:
        barColor = style.borderColor;
      case PasswordStrengthLevel.weak:
        barColor = style.errorColor;
      case PasswordStrengthLevel.fair:
        barColor = style.warningColor;
      case PasswordStrengthLevel.good:
        barColor = style.primaryColor;
      case PasswordStrengthLevel.strong:
        barColor = style.successColor;
    }

    final activeBars = analysis.level == PasswordStrengthLevel.empty
        ? 0
        : analysis.level.index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: List<Widget>.generate(4, (index) {
                  final filled = index < activeBars;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: style.animationDuration,
                      height: 5,
                      margin: EdgeInsets.only(right: index < 3 ? 5 : 0),
                      decoration: BoxDecoration(
                        color: filled ? barColor : style.borderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              analysis.label,
              style: TextStyle(
                color: barColor == style.borderColor
                    ? style.subtitleColor
                    : barColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: <Widget>[
            _RulePill(
              label: '8+ chars',
              passed: analysis.hasMinLength,
              style: style,
            ),
            _RulePill(
              label: 'A-Z',
              passed: analysis.hasUppercase,
              style: style,
            ),
            _RulePill(
              label: '0-9',
              passed: analysis.hasDigit,
              style: style,
            ),
            _RulePill(
              label: '!@#\$',
              passed: analysis.hasSpecialChar,
              style: style,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterMessage(FormsStyle style, bool hasError) {
    if (!hasError &&
        (widget.helperText == null || widget.helperText!.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Text(
        hasError ? widget.errorText! : widget.helperText!,
        style: TextStyle(
          color: hasError ? style.errorColor : style.subtitleColor,
          fontSize: 12,
          fontWeight: hasError ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  const _StepperIconButton({
    required this.icon,
    required this.style,
    required this.onTap,
  });

  final IconData icon;
  final FormsStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: style.primaryColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: style.primaryColor.withValues(alpha: 0.35),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: style.primaryColor,
        ),
      ),
    );
  }
}

class _RulePill extends StatelessWidget {
  const _RulePill({
    required this.label,
    required this.passed,
    required this.style,
  });

  final String label;
  final bool passed;
  final FormsStyle style;

  @override
  Widget build(BuildContext context) {
    final activeColor = passed ? style.successColor : style.subtitleColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: passed
            ? style.successColor.withValues(alpha: 0.14)
            : style.fieldFillColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: passed
              ? style.successColor.withValues(alpha: 0.4)
              : style.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            passed ? Icons.check_rounded : Icons.circle_outlined,
            size: 11,
            color: activeColor,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: activeColor,
              fontSize: 10.5,
              fontWeight: passed ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
