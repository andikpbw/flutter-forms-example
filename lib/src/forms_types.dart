import 'package:flutter/material.dart';

/// Signature for a field validation function that receives the field's [value]
/// and the current snapshot of [allValues] across the form.
///
/// Returns an error message string if validation fails, or `null` when valid.
typedef FormsFieldRule = String? Function(
  dynamic value,
  Map<String, dynamic> allValues,
);

/// Supported modern input field types in `forms_example`.
enum FormFieldType {
  /// Standard single-line text input with prefix/suffix icon and clear action.
  text,

  /// Smart email input with optional one-tap domain suggestion chips.
  email,

  /// Password input with visibility toggle, live strength bar, and rule pills.
  password,

  /// Numeric input with increment/decrement stepper controls and bounds.
  number,

  /// Multi-line expandable text area with live character counter.
  multiline,

  /// Modern dropdown selector menu with icons and subtitles.
  dropdown,

  /// Animated single-select or multi-select choice chips.
  choiceChips,

  /// Tactile card switch toggle with title, subtitle, and status badge.
  switchToggle,

  /// Smooth value slider with live formatted badge readout.
  slider,

  /// Interactive star rating selector with sentiment label feedback.
  rating,

  /// Auto-formatted credit card number input with Luhn check and brand badge.
  creditCard,

  /// Segmented one-time passcode (OTP / PIN) verification boxes.
  otp,

  /// Modern inline/modal date picker field.
  datePicker,
}

/// Controls when form fields automatically run validation rules.
enum FormAutoValidateMode {
  /// Validation only runs when explicitly triggered via controller methods.
  disabled,

  /// Validates a field as soon as the user modifies or interacts with it.
  onUserInteraction,

  /// Validates fields only after the first submit attempt has been made.
  onSubmitOnly,

  /// Validates all fields immediately and continuously.
  always,
}

/// Built-in turnkey form template presets for instant scaffolding.
enum FormTemplatePreset {
  /// SaaS Account Registration with smart email chips & password meter.
  authSignup(
    title: 'Create Developer Account',
    subtitle:
        'Modern authentication form with live password entropy & email chips',
    icon: Icons.verified_user_rounded,
  ),

  /// Payment & Billing Checkout with Luhn credit card & OTP verification.
  paymentCheckout(
    title: 'Instant Pro Checkout',
    subtitle:
        'Auto-formatted card brand detection, Luhn validation & security PIN',
    icon: Icons.credit_card_rounded,
  ),

  /// Product Feedback & Experience Survey with ratings, sliders & tags.
  feedbackSurvey(
    title: 'Product Experience Survey',
    subtitle:
        'Interactive star ratings, NPS slider, and multi-select feature chips',
    icon: Icons.auto_awesome_rounded,
  ),

  /// Workspace Profile & Preferences Configuration.
  profileOnboarding(
    title: 'Workspace Onboarding',
    subtitle: 'Role selection, team capacity stepper, and notification toggles',
    icon: Icons.rocket_launch_rounded,
  );

  /// Creates a [FormTemplatePreset] metadata entry.
  const FormTemplatePreset({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  /// Display title of the template.
  final String title;

  /// Descriptive subtitle of the template.
  final String subtitle;

  /// Leading icon representing the template.
  final IconData icon;
}

/// Categorized password security strength tiers.
enum PasswordStrengthLevel {
  /// No password entered yet.
  empty('Enter password', 0.0),

  /// Low entropy password that fails core requirements.
  weak('Weak', 0.25),

  /// Moderate password meeting basic length and character mix.
  fair('Fair', 0.50),

  /// Strong password meeting almost all complexity criteria.
  good('Good', 0.75),

  /// High-entropy password meeting all length, case, digit, and symbol checks.
  strong('Strong', 1.0);

  /// Creates a [PasswordStrengthLevel] with a display [label] and [normalizedScore].
  const PasswordStrengthLevel(this.label, this.normalizedScore);

  /// Human-readable strength label.
  final String label;

  /// Default normalized progress value between `0.0` and `1.0`.
  final double normalizedScore;
}

/// Detected payment card network brand.
enum CreditCardBrand {
  /// Unrecognized or incomplete card prefix.
  unknown('CARD', Icons.credit_card_rounded),

  /// Visa network (starts with 4).
  visa('VISA', Icons.payment_rounded),

  /// Mastercard network (starts with 51-55 or 2221-2720).
  mastercard('MASTERCARD', Icons.credit_score_rounded),

  /// American Express network (starts with 34 or 37).
  amex('AMEX', Icons.account_balance_wallet_rounded),

  /// Discover network (starts with 6011 or 65).
  discover('DISCOVER', Icons.loyalty_rounded);

  /// Creates a [CreditCardBrand] descriptor.
  const CreditCardBrand(this.label, this.icon);

  /// Uppercase badge label for the card network.
  final String label;

  /// Icon representing the card network.
  final IconData icon;
}

/// Detailed real-time analysis of a password string.
@immutable
class PasswordStrengthAnalysis {
  /// Creates a [PasswordStrengthAnalysis] snapshot.
  const PasswordStrengthAnalysis({
    required this.score,
    required this.level,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  /// Normalized score from `0.0` (empty) to `1.0` (maximum strength).
  final double score;

  /// Categorized strength tier.
  final PasswordStrengthLevel level;

  /// Whether the password meets the minimum character length requirement.
  final bool hasMinLength;

  /// Whether the password contains at least one uppercase letter (`A-Z`).
  final bool hasUppercase;

  /// Whether the password contains at least one lowercase letter (`a-z`).
  final bool hasLowercase;

  /// Whether the password contains at least one numeric digit (`0-9`).
  final bool hasDigit;

  /// Whether the password contains at least one special symbol.
  final bool hasSpecialChar;

  /// Number of individual security rules satisfied (`0` to `5`).
  int get passedRulesCount {
    var count = 0;
    if (hasMinLength) count++;
    if (hasUppercase) count++;
    if (hasLowercase) count++;
    if (hasDigit) count++;
    if (hasSpecialChar) count++;
    return count;
  }

  /// Human-readable label for the current password tier.
  String get label => level.label;
}

/// Represents a selectable item in dropdowns, radio groups, or choice chips.
@immutable
class FormChoiceOption<T> {
  /// Creates a [FormChoiceOption].
  const FormChoiceOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.badge,
  });

  /// Underlying value stored in the form controller when selected.
  final T value;

  /// Primary text label shown to the user.
  final String label;

  /// Optional secondary description.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing badge pill text.
  final String? badge;
}

/// Declarative schema blueprint for a single field in `SmartFormBuilder`
/// or `ModernFormStepper`.
@immutable
class FormFieldConfig {
  /// Creates a [FormFieldConfig] definition.
  const FormFieldConfig({
    required this.key,
    required this.label,
    this.type = FormFieldType.text,
    this.hint,
    this.helperText,
    this.initialValue,
    this.required = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.validators = const <FormsFieldRule>[],
    this.options = const <FormChoiceOption<dynamic>>[],
    this.multiSelect = false,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.step = 1,
    this.maxLength,
    this.maxLines = 3,
    this.emailDomains = const <String>[
      'gmail.com',
      'humanize.id',
      'outlook.com',
    ],
    this.showPasswordMeter = true,
    this.otpLength = 6,
    this.stepIndex = 0,
  });

  /// Unique identifier key used in `FormsController.values`.
  final String key;

  /// Human-readable field title.
  final String label;

  /// Visual and functional widget type for this field.
  final FormFieldType type;

  /// Placeholder hint text inside the field when empty.
  final String? hint;

  /// Supporting guidance text displayed below the field.
  final String? helperText;

  /// Default initial value populated into the controller.
  final dynamic initialValue;

  /// Whether the field must be non-empty before form submission.
  final bool required;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// Optional leading icon inside the input container.
  final IconData? prefixIcon;

  /// Optional trailing icon inside the input container.
  final IconData? suffixIcon;

  /// Ordered list of validation rules evaluated for this field.
  final List<FormsFieldRule> validators;

  /// Available selectable options for [FormFieldType.dropdown] or
  /// [FormFieldType.choiceChips].
  final List<FormChoiceOption<dynamic>> options;

  /// Whether [FormFieldType.choiceChips] allows selecting multiple values.
  final bool multiSelect;

  /// Minimum numeric bound for [FormFieldType.number], [FormFieldType.slider],
  /// or [FormFieldType.rating].
  final double min;

  /// Maximum numeric bound for [FormFieldType.number], [FormFieldType.slider],
  /// or [FormFieldType.rating].
  final double max;

  /// Optional discrete divisions for [FormFieldType.slider].
  final int? divisions;

  /// Increment/decrement delta for [FormFieldType.number].
  final double step;

  /// Optional maximum character length for text inputs.
  final int? maxLength;

  /// Maximum visible lines for [FormFieldType.multiline].
  final int maxLines;

  /// Quick-insert domain suggestions for [FormFieldType.email].
  final List<String> emailDomains;

  /// Whether [FormFieldType.password] displays the live 4-bar strength meter.
  final bool showPasswordMeter;

  /// Number of character boxes for [FormFieldType.otp].
  final int otpLength;

  /// Zero-based wizard step index that owns this field.
  final int stepIndex;
}

/// Declarative definition for a step inside `ModernFormStepper`.
@immutable
class FormStepConfig {
  /// Creates a [FormStepConfig] for a multi-step wizard.
  const FormStepConfig({
    required this.title,
    required this.fields,
    this.subtitle,
    this.icon = Icons.check_circle_outline_rounded,
    this.badgeText,
  });

  /// Step header title.
  final String title;

  /// Optional step subtitle or instruction.
  final String? subtitle;

  /// Icon displayed inside the step indicator node.
  final IconData icon;

  /// Optional badge text (e.g., `'Step 1'` or `'Required'`).
  final String? badgeText;

  /// List of form fields rendered inside this step.
  final List<FormFieldConfig> fields;
}

/// Immutable result snapshot produced when a form is submitted.
@immutable
class FormSubmissionResult {
  /// Creates a [FormSubmissionResult].
  const FormSubmissionResult({
    required this.isSuccess,
    required this.values,
    required this.errors,
    required this.timestamp,
    this.message,
  });

  /// Whether all validation checks passed and submission succeeded.
  final bool isSuccess;

  /// Sanitized key-value map of all form fields at submission time.
  final Map<String, dynamic> values;

  /// Map of field keys to validation error messages (empty when [isSuccess] is true).
  final Map<String, String> errors;

  /// Timestamp when the submission completed.
  final DateTime timestamp;

  /// Optional status or summary message.
  final String? message;
}
