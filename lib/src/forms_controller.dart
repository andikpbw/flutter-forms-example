import 'dart:convert';

import 'package:flutter/material.dart';

import 'forms_types.dart';
import 'forms_validators.dart';

/// Reactive state and validation controller for `SmartFormBuilder`,
/// `ModernFormStepper`, and standalone `forms_example` widgets.
class FormsController extends ChangeNotifier {
  /// Creates a [FormsController] with optional initial schema, values, or preset.
  FormsController({
    List<FormFieldConfig>? fields,
    Map<String, dynamic>? initialValues,
    this.autoValidateMode = FormAutoValidateMode.onUserInteraction,
    FormTemplatePreset? preset,
  }) {
    if (preset != null) {
      applyPreset(preset, notify: false);
    } else if (fields != null) {
      registerFields(fields, notify: false);
    }
    if (initialValues != null) {
      for (final entry in initialValues.entries) {
        _values[entry.key] = entry.value;
        _initialValues[entry.key] = entry.value;
      }
    }
    if (autoValidateMode == FormAutoValidateMode.always) {
      validateAll(markAllTouched: false, notify: false);
    }
  }

  /// Controls when validation rules are automatically evaluated.
  FormAutoValidateMode autoValidateMode;

  final Map<String, FormFieldConfig> _fieldConfigs =
      <String, FormFieldConfig>{};
  final Map<String, dynamic> _values = <String, dynamic>{};
  final Map<String, dynamic> _initialValues = <String, dynamic>{};
  final Map<String, String> _errors = <String, String>{};
  final Set<String> _touchedKeys = <String>{};

  int _currentStep = 0;
  int _totalSteps = 1;
  bool _isSubmitting = false;
  bool _hasAttemptedSubmit = false;
  FormSubmissionResult? _lastSubmission;
  FormTemplatePreset? _activePreset;

  /// Currently active template preset, if one was applied.
  FormTemplatePreset? get activePreset => _activePreset;

  /// Registered field configurations in insertion order.
  List<FormFieldConfig> get fields =>
      List<FormFieldConfig>.unmodifiable(_fieldConfigs.values);

  /// Unmodifiable snapshot of all current form field values.
  Map<String, dynamic> get values => Map<String, dynamic>.unmodifiable(_values);

  /// Unmodifiable snapshot of active validation error messages by field key.
  Map<String, String> get errors => Map<String, String>.unmodifiable(_errors);

  /// Set of field keys that the user has interacted with.
  Set<String> get touchedKeys => Set<String>.unmodifiable(_touchedKeys);

  /// Current active step index in a multi-step wizard (`0`-based).
  int get currentStep => _currentStep;

  /// Total number of steps configured for the wizard.
  int get totalSteps => _totalSteps;

  /// Whether a form submission operation is currently in progress.
  bool get isSubmitting => _isSubmitting;

  /// Whether a submission attempt has occurred at least once.
  bool get hasAttemptedSubmit => _hasAttemptedSubmit;

  /// Most recent submission result snapshot, or `null` if not yet submitted.
  FormSubmissionResult? get lastSubmission => _lastSubmission;

  /// Whether the form currently has zero active validation errors.
  bool get isValid => _errors.isEmpty;

  /// Total count of registered fields.
  int get totalFieldsCount => _fieldConfigs.length;

  /// Count of registered fields that currently hold a non-empty valid value.
  int get completedFieldsCount {
    if (_fieldConfigs.isEmpty) return 0;
    var count = 0;
    for (final config in _fieldConfigs.values) {
      final val = _values[config.key];
      if (_isValueFilled(val) && !_errors.containsKey(config.key)) {
        count++;
      }
    }
    return count;
  }

  /// Normalized form completion progress from `0.0` to `1.0`.
  double get completionProgress {
    if (_fieldConfigs.isEmpty) return 1.0;
    return (completedFieldsCount / _fieldConfigs.length).clamp(0.0, 1.0);
  }

  /// Form completion percentage as an integer between `0` and `100`.
  int get completionPercentage => (completionProgress * 100).round();

  /// Registers or updates a list of [FormFieldConfig] items in the controller.
  void registerFields(
    List<FormFieldConfig> configs, {
    bool clearExisting = false,
    bool notify = true,
  }) {
    if (clearExisting) {
      _fieldConfigs.clear();
      _values.clear();
      _initialValues.clear();
      _errors.clear();
      _touchedKeys.clear();
    }
    var maxStep = 0;
    for (final config in configs) {
      _fieldConfigs[config.key] = config;
      if (config.stepIndex > maxStep) {
        maxStep = config.stepIndex;
      }
      if (!_values.containsKey(config.key)) {
        final defaultVal = _resolveDefaultValue(config);
        _values[config.key] = defaultVal;
        _initialValues[config.key] = defaultVal;
      }
    }
    _totalSteps = maxStep + 1;
    if (_currentStep >= _totalSteps) {
      _currentStep = 0;
    }
    if (notify) notifyListeners();
  }

  /// Registers steps from a multi-step wizard configuration.
  void registerSteps(
    List<FormStepConfig> steps, {
    bool clearExisting = true,
    bool notify = true,
  }) {
    final flattened = <FormFieldConfig>[];
    for (var i = 0; i < steps.length; i++) {
      for (final field in steps[i].fields) {
        flattened.add(
          FormFieldConfig(
            key: field.key,
            label: field.label,
            type: field.type,
            hint: field.hint,
            helperText: field.helperText,
            initialValue: field.initialValue,
            required: field.required,
            enabled: field.enabled,
            prefixIcon: field.prefixIcon,
            suffixIcon: field.suffixIcon,
            validators: field.validators,
            options: field.options,
            multiSelect: field.multiSelect,
            min: field.min,
            max: field.max,
            divisions: field.divisions,
            step: field.step,
            maxLength: field.maxLength,
            maxLines: field.maxLines,
            emailDomains: field.emailDomains,
            showPasswordMeter: field.showPasswordMeter,
            otpLength: field.otpLength,
            stepIndex: i,
          ),
        );
      }
    }
    registerFields(flattened, clearExisting: clearExisting, notify: false);
    _totalSteps = steps.isEmpty ? 1 : steps.length;
    if (_currentStep >= _totalSteps) _currentStep = 0;
    if (notify) notifyListeners();
  }

  /// Loads one of the built-in [FormTemplatePreset] schemas into this controller.
  void applyPreset(
    FormTemplatePreset preset, {
    bool notify = true,
  }) {
    _activePreset = preset;
    _lastSubmission = null;
    _hasAttemptedSubmit = false;
    _currentStep = 0;
    final presetFields = buildPresetFields(preset);
    registerFields(presetFields, clearExisting: true, notify: notify);
  }

  /// Retrieves the current value for [key] cast to [T], or `null` if absent.
  T? getValue<T>(String key) {
    final raw = _values[key];
    if (raw is T) return raw;
    return null;
  }

  /// Updates the value of field [key] and optionally runs validation.
  void setValue(
    String key,
    dynamic value, {
    bool markTouched = true,
    bool? validate,
  }) {
    _values[key] = value;
    if (markTouched) {
      _touchedKeys.add(key);
    }

    final shouldValidate = validate ??
        (autoValidateMode == FormAutoValidateMode.always ||
            (autoValidateMode == FormAutoValidateMode.onUserInteraction &&
                _touchedKeys.contains(key)) ||
            (autoValidateMode == FormAutoValidateMode.onSubmitOnly &&
                _hasAttemptedSubmit));

    if (shouldValidate) {
      validateField(key, notify: false);
    } else if (_errors.containsKey(key)) {
      validateField(key, notify: false);
    }

    notifyListeners();
  }

  /// Returns the current validation error message for [key], or `null` if valid.
  String? getError(String key) => _errors[key];

  /// Explicitly sets or clears a custom validation error message for [key].
  void setError(String key, String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      _errors.remove(key);
    } else {
      _errors[key] = errorMessage;
    }
    notifyListeners();
  }

  /// Clears all active validation error messages across the form.
  void clearErrors() {
    if (_errors.isEmpty) return;
    _errors.clear();
    notifyListeners();
  }

  /// Whether the user has interacted with the field identified by [key].
  bool isTouched(String key) => _touchedKeys.contains(key);

  /// Marks the field identified by [key] as touched by the user.
  void markTouched(String key, {bool validate = true}) {
    _touchedKeys.add(key);
    if (validate &&
        (autoValidateMode == FormAutoValidateMode.onUserInteraction ||
            autoValidateMode == FormAutoValidateMode.always)) {
      validateField(key, notify: false);
    }
    notifyListeners();
  }

  /// Evaluates all validation rules for a single field [key].
  ///
  /// Returns `true` if the field is valid, or `false` if an error occurred.
  bool validateField(
    String key, {
    bool notify = true,
  }) {
    final config = _fieldConfigs[key];
    if (config == null || !config.enabled) {
      _errors.remove(key);
      if (notify) notifyListeners();
      return true;
    }

    final value = _values[key];
    String? error;

    if (config.required) {
      error = FormsValidator.required(
        message: '${config.label} is required',
      )(value, _values);
    }

    if (error == null) {
      for (final validator in config.validators) {
        error = validator(value, _values);
        if (error != null) break;
      }
    }

    if (error != null) {
      _errors[key] = error;
    } else {
      _errors.remove(key);
    }

    if (notify) notifyListeners();
    return error == null;
  }

  /// Validates all fields assigned to a specific wizard [stepIndex].
  ///
  /// Returns `true` when every field in that step passes validation.
  bool validateStep(
    int stepIndex, {
    bool markStepTouched = true,
    bool notify = true,
  }) {
    var allValid = true;
    for (final config in _fieldConfigs.values) {
      if (config.stepIndex == stepIndex) {
        if (markStepTouched) {
          _touchedKeys.add(config.key);
        }
        final valid = validateField(config.key, notify: false);
        if (!valid) allValid = false;
      }
    }
    if (notify) notifyListeners();
    return allValid;
  }

  /// Validates all registered fields across the entire form.
  ///
  /// Returns `true` if every field passes validation.
  bool validateAll({
    bool markAllTouched = true,
    bool notify = true,
  }) {
    var allValid = true;
    for (final key in _fieldConfigs.keys) {
      if (markAllTouched) {
        _touchedKeys.add(key);
      }
      final valid = validateField(key, notify: false);
      if (!valid) allValid = false;
    }
    if (notify) notifyListeners();
    return allValid;
  }

  /// Advances the wizard to the next step if [validateCurrentStep] passes.
  ///
  /// Returns `true` if the step advanced.
  bool nextStep({bool validateCurrentStep = true}) {
    if (validateCurrentStep && !validateStep(_currentStep)) {
      return false;
    }
    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Moves the wizard back to the previous step.
  bool previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Jumps directly to wizard step [index] (`0 <= index < totalSteps`).
  void goToStep(int index) {
    final target = index.clamp(0, _totalSteps - 1);
    if (target != _currentStep) {
      _currentStep = target;
      notifyListeners();
    }
  }

  /// Validates all fields and executes the submission lifecycle.
  Future<FormSubmissionResult> submit({
    Future<void> Function(Map<String, dynamic> values)? onAsyncSubmit,
  }) async {
    _hasAttemptedSubmit = true;
    final valid = validateAll(markAllTouched: true, notify: true);

    if (!valid) {
      final failedResult = FormSubmissionResult(
        isSuccess: false,
        values: Map<String, dynamic>.from(_values),
        errors: Map<String, String>.from(_errors),
        timestamp: DateTime.now(),
        message: 'Please resolve ${_errors.length} highlighted field(s).',
      );
      _lastSubmission = failedResult;
      notifyListeners();
      return failedResult;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      if (onAsyncSubmit != null) {
        await onAsyncSubmit(Map<String, dynamic>.from(_values));
      }
      final successResult = FormSubmissionResult(
        isSuccess: true,
        values: Map<String, dynamic>.from(_values),
        errors: const <String, String>{},
        timestamp: DateTime.now(),
        message: 'Form submitted successfully!',
      );
      _lastSubmission = successResult;
      return successResult;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Resets all fields back to their initial default values and clears errors.
  void reset() {
    _values
      ..clear()
      ..addAll(_initialValues);
    _errors.clear();
    _touchedKeys.clear();
    _currentStep = 0;
    _hasAttemptedSubmit = false;
    _lastSubmission = null;
    notifyListeners();
  }

  /// Populates form values from an external [map].
  void loadFromMap(
    Map<String, dynamic> map, {
    bool validate = false,
  }) {
    for (final entry in map.entries) {
      _values[entry.key] = entry.value;
    }
    if (validate) {
      validateAll(markAllTouched: false, notify: false);
    }
    notifyListeners();
  }

  /// Exports a clean, JSON-serializable map of current form values.
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    for (final entry in _values.entries) {
      final val = entry.value;
      if (val is DateTime) {
        result[entry.key] = val.toIso8601String().split('T').first;
      } else if (val is Set) {
        result[entry.key] = val.toList();
      } else {
        result[entry.key] = val;
      }
    }
    return result;
  }

  /// Exports current form values as an indented JSON string.
  String toFormattedJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toMap());
  }

  static dynamic _resolveDefaultValue(FormFieldConfig config) {
    if (config.initialValue != null) return config.initialValue;
    switch (config.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.password:
      case FormFieldType.multiline:
      case FormFieldType.creditCard:
      case FormFieldType.otp:
      case FormFieldType.datePicker:
        return '';
      case FormFieldType.number:
      case FormFieldType.slider:
        return config.min;
      case FormFieldType.rating:
        return 4.0;
      case FormFieldType.switchToggle:
        return false;
      case FormFieldType.dropdown:
        return config.options.isNotEmpty ? config.options.first.value : null;
      case FormFieldType.choiceChips:
        return config.multiSelect ? <dynamic>[] : null;
    }
  }

  static bool _isValueFilled(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is bool) return true;
    if (value is num) return true;
    return true;
  }

  /// Generates the turnkey field list for a [FormTemplatePreset].
  static List<FormFieldConfig> buildPresetFields(FormTemplatePreset preset) {
    switch (preset) {
      case FormTemplatePreset.authSignup:
        return <FormFieldConfig>[
          FormFieldConfig(
            key: 'full_name',
            label: 'Full Name',
            hint: 'e.g. Andik Prabowo',
            prefixIcon: Icons.person_outline_rounded,
            required: true,
            initialValue: 'Andik Prabowo',
            validators: <FormsFieldRule>[
              FormsValidator.minLength(3),
            ],
          ),
          FormFieldConfig(
            key: 'email',
            label: 'Work Email',
            type: FormFieldType.email,
            hint: 'name@company.com',
            prefixIcon: Icons.mail_outline_rounded,
            required: true,
            initialValue: 'founder@humanize.id',
            emailDomains: const <String>[
              'humanize.id',
              'gmail.com',
              'outlook.com',
            ],
            validators: <FormsFieldRule>[
              FormsValidator.email(),
            ],
          ),
          FormFieldConfig(
            key: 'password',
            label: 'Password',
            type: FormFieldType.password,
            hint: 'Minimum 8 characters',
            prefixIcon: Icons.lock_outline_rounded,
            required: true,
            initialValue: 'Humanize#2026!',
            showPasswordMeter: true,
            validators: <FormsFieldRule>[
              FormsValidator.passwordStrength(minLength: 8),
            ],
          ),
          const FormFieldConfig(
            key: 'role',
            label: 'Role',
            type: FormFieldType.choiceChips,
            required: true,
            initialValue: 'flutter',
            options: <FormChoiceOption<dynamic>>[
              FormChoiceOption<String>(
                value: 'flutter',
                label: 'Mobile Engineer',
                icon: Icons.phone_iphone_rounded,
              ),
              FormChoiceOption<String>(
                value: 'backend',
                label: 'Backend Engineer',
                icon: Icons.dns_outlined,
              ),
              FormChoiceOption<String>(
                value: 'product',
                label: 'Product Designer',
                icon: Icons.design_services_outlined,
              ),
            ],
          ),
          const FormFieldConfig(
            key: 'accept_terms',
            label: 'Agree to Terms of Service',
            helperText: 'Receive account security and release notifications',
            type: FormFieldType.switchToggle,
            initialValue: true,
          ),
        ];

      case FormTemplatePreset.paymentCheckout:
        return <FormFieldConfig>[
          FormFieldConfig(
            key: 'cardholder',
            label: 'Cardholder Name',
            hint: 'ANDIK PRABOWO',
            prefixIcon: Icons.badge_outlined,
            required: true,
            initialValue: 'ANDIK PRABOWO',
            validators: <FormsFieldRule>[
              FormsValidator.minLength(3),
            ],
          ),
          FormFieldConfig(
            key: 'card_number',
            label: 'Card Number',
            type: FormFieldType.creditCard,
            hint: '4242 4242 4242 4242',
            helperText: 'Supports Visa, Mastercard, Amex with Luhn check',
            required: true,
            initialValue: '4242 4242 4242 4242',
            validators: <FormsFieldRule>[
              FormsValidator.creditCard(),
            ],
          ),
          const FormFieldConfig(
            key: 'billing_plan',
            label: 'Subscription Plan',
            type: FormFieldType.dropdown,
            required: true,
            initialValue: 'pro',
            options: <FormChoiceOption<dynamic>>[
              FormChoiceOption<String>(
                value: 'starter',
                label: 'Starter Plan — \$19 / month',
                icon: Icons.layers_outlined,
              ),
              FormChoiceOption<String>(
                value: 'pro',
                label: 'Professional Plan — \$49 / month',
                icon: Icons.verified_outlined,
              ),
              FormChoiceOption<String>(
                value: 'enterprise',
                label: 'Enterprise Plan — \$149 / month',
                icon: Icons.domain_outlined,
              ),
            ],
          ),
          const FormFieldConfig(
            key: 'seats',
            label: 'Team Seats',
            type: FormFieldType.number,
            min: 1,
            max: 250,
            step: 1,
            initialValue: 5,
          ),
          FormFieldConfig(
            key: 'security_otp',
            label: 'Verification Code (6-Digit OTP)',
            type: FormFieldType.otp,
            otpLength: 6,
            required: true,
            initialValue: '849204',
            validators: <FormsFieldRule>[
              FormsValidator.otpLength(6),
            ],
          ),
        ];

      case FormTemplatePreset.feedbackSurvey:
        return const <FormFieldConfig>[
          FormFieldConfig(
            key: 'overall_rating',
            label: 'Overall Library Experience Rating',
            type: FormFieldType.rating,
            min: 1,
            max: 5,
            initialValue: 5.0,
            required: true,
          ),
          FormFieldConfig(
            key: 'nps_score',
            label: 'Likelihood to Recommend (NPS Score)',
            type: FormFieldType.slider,
            min: 0,
            max: 100,
            divisions: 20,
            initialValue: 95.0,
            helperText: 'Slide between 0% and 100% satisfaction',
          ),
          FormFieldConfig(
            key: 'favorite_features',
            label: 'Favorite UI Components (Multi-Select)',
            type: FormFieldType.choiceChips,
            multiSelect: true,
            required: true,
            initialValue: <String>['wizard', 'password_meter', 'themes'],
            options: <FormChoiceOption<dynamic>>[
              FormChoiceOption<String>(
                value: 'wizard',
                label: 'Multi-Step Wizard',
                icon: Icons.route_rounded,
              ),
              FormChoiceOption<String>(
                value: 'password_meter',
                label: 'Password Entropy Meter',
                icon: Icons.shield_rounded,
              ),
              FormChoiceOption<String>(
                value: 'themes',
                label: '6 Studio Themes',
                icon: Icons.palette_rounded,
              ),
              FormChoiceOption<String>(
                value: 'luhn_card',
                label: 'Luhn Card Detector',
                icon: Icons.credit_card_rounded,
              ),
            ],
          ),
          FormFieldConfig(
            key: 'feedback_notes',
            label: 'Additional Suggestions & Feedback',
            type: FormFieldType.multiline,
            hint: 'Share what you love or want next...',
            maxLength: 240,
            maxLines: 3,
            initialValue:
                'Super clean architecture, zero external dependencies, and smooth animations!',
          ),
        ];

      case FormTemplatePreset.profileOnboarding:
        return <FormFieldConfig>[
          FormFieldConfig(
            key: 'workspace_url',
            label: 'Organization Domain URL',
            hint: 'https://humanize.id',
            prefixIcon: Icons.language_rounded,
            required: true,
            initialValue: 'https://humanize.id',
            validators: <FormsFieldRule>[
              FormsValidator.url(),
            ],
          ),
          const FormFieldConfig(
            key: 'launch_date',
            label: 'Target Production Launch Date',
            type: FormFieldType.datePicker,
            initialValue: '2026-12-01',
            required: true,
          ),
          const FormFieldConfig(
            key: 'daily_quota',
            label: 'Daily API Request Quota (in Thousands)',
            type: FormFieldType.slider,
            min: 10,
            max: 500,
            divisions: 49,
            initialValue: 250.0,
          ),
          const FormFieldConfig(
            key: 'auto_scale',
            label: 'Enable Autonomous Edge Auto-Scaling',
            helperText: 'Automatically scales clusters during traffic spikes',
            type: FormFieldType.switchToggle,
            initialValue: true,
          ),
        ];
    }
  }

  /// Generates a ready-to-use 3-step onboarding & checkout wizard schema.
  static List<FormStepConfig> buildDefaultWizardSteps() {
    return <FormStepConfig>[
      FormStepConfig(
        title: 'Account Identity',
        subtitle: 'Verify your identity and security credentials',
        icon: Icons.person_pin_rounded,
        badgeText: 'Step 1',
        fields: <FormFieldConfig>[
          FormFieldConfig(
            key: 'wizard_name',
            label: 'Full Name',
            hint: 'Andik Prabowo',
            prefixIcon: Icons.person_outline_rounded,
            required: true,
            initialValue: 'Andik Prabowo',
            validators: <FormsFieldRule>[
              FormsValidator.minLength(3),
            ],
          ),
          FormFieldConfig(
            key: 'wizard_email',
            label: 'Developer Email',
            type: FormFieldType.email,
            hint: 'team@humanize.id',
            prefixIcon: Icons.email_outlined,
            required: true,
            initialValue: 'team@humanize.id',
            validators: <FormsFieldRule>[
              FormsValidator.email(),
            ],
          ),
          FormFieldConfig(
            key: 'wizard_password',
            label: 'Security Password',
            type: FormFieldType.password,
            required: true,
            initialValue: 'Humanize#2026!',
            showPasswordMeter: true,
            validators: <FormsFieldRule>[
              FormsValidator.passwordStrength(minLength: 8),
            ],
          ),
        ],
      ),
      const FormStepConfig(
        title: 'Stack & Capacity',
        subtitle: 'Configure your architecture preferences and team scale',
        icon: Icons.layers_rounded,
        badgeText: 'Step 2',
        fields: <FormFieldConfig>[
          FormFieldConfig(
            key: 'wizard_stack',
            label: 'Target Deployment Platforms',
            type: FormFieldType.choiceChips,
            multiSelect: true,
            required: true,
            initialValue: <String>['ios_android', 'web_wasm', 'desktop'],
            options: <FormChoiceOption<dynamic>>[
              FormChoiceOption<String>(
                value: 'ios_android',
                label: 'iOS & Android',
                icon: Icons.stay_current_portrait_rounded,
              ),
              FormChoiceOption<String>(
                value: 'web_wasm',
                label: 'Flutter Web / WASM',
                icon: Icons.public_rounded,
              ),
              FormChoiceOption<String>(
                value: 'desktop',
                label: 'macOS, Windows & Linux',
                icon: Icons.laptop_mac_rounded,
              ),
            ],
          ),
          FormFieldConfig(
            key: 'wizard_members',
            label: 'Active Engineering Seats',
            type: FormFieldType.number,
            min: 1,
            max: 100,
            step: 1,
            initialValue: 8,
          ),
          FormFieldConfig(
            key: 'wizard_perf_budget',
            label: 'Target Frame Budget Confidence (%)',
            type: FormFieldType.slider,
            min: 50,
            max: 100,
            divisions: 10,
            initialValue: 95.0,
          ),
        ],
      ),
      FormStepConfig(
        title: 'Verify & Launch',
        subtitle: 'Confirm 6-digit OTP & activate your workspace',
        icon: Icons.verified_rounded,
        badgeText: 'Step 3',
        fields: <FormFieldConfig>[
          FormFieldConfig(
            key: 'wizard_otp',
            label: '6-Digit Security Passcode',
            type: FormFieldType.otp,
            otpLength: 6,
            required: true,
            initialValue: '202619',
            validators: <FormsFieldRule>[
              FormsValidator.otpLength(6),
            ],
          ),
          const FormFieldConfig(
            key: 'wizard_rating',
            label: 'Onboarding Experience Rating',
            type: FormFieldType.rating,
            min: 1,
            max: 5,
            initialValue: 5.0,
          ),
          const FormFieldConfig(
            key: 'wizard_realtime_guard',
            label: 'Enable Real-Time AI Form Guard',
            helperText: 'Powered by Humanize AI validation telemetry',
            type: FormFieldType.switchToggle,
            initialValue: true,
          ),
        ],
      ),
    ];
  }
}
