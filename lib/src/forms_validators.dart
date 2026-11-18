import 'forms_types.dart';

/// Collection of composable, zero-dependency form validators and input analyzers.
class FormsValidator {
  const FormsValidator._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9\s\-()]{7,18}$',
  );

  static final RegExp _urlRegex = RegExp(
    r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]{2,}(\/\S*)?$',
  );

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(
    r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?~`]',
  );

  /// Requires a non-null, non-empty value (strings, collections, booleans).
  static FormsFieldRule required({
    String message = 'This field is required',
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return message;
      if (value is String && value.trim().isEmpty) return message;
      if (value is Iterable && value.isEmpty) return message;
      if (value is Map && value.isEmpty) return message;
      if (value is bool && !value) return message;
      return null;
    };
  }

  /// Validates that a string is a well-formed email address.
  static FormsFieldRule email({
    String message = 'Enter a valid email address',
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      if (!_emailRegex.hasMatch(text)) return message;
      return null;
    };
  }

  /// Validates that a string contains at least [min] characters.
  static FormsFieldRule minLength(
    int min, {
    String? message,
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final text = value.toString();
      if (text.isEmpty) return null;
      if (text.length < min) {
        return message ?? 'Must be at least $min characters';
      }
      return null;
    };
  }

  /// Validates that a string does not exceed [max] characters.
  static FormsFieldRule maxLength(
    int max, {
    String? message,
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final text = value.toString();
      if (text.length > max) {
        return message ?? 'Must be at most $max characters';
      }
      return null;
    };
  }

  /// Validates password complexity against configurable character rules.
  static FormsFieldRule passwordStrength({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireDigit = true,
    bool requireSpecial = true,
    String? message,
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final text = value.toString();
      if (text.isEmpty) return null;
      final analysis = analyzePassword(text, minLength: minLength);
      if (!analysis.hasMinLength) {
        return message ?? 'Password must be at least $minLength characters';
      }
      if (requireUppercase && !analysis.hasUppercase) {
        return message ?? 'Include at least one uppercase letter (A-Z)';
      }
      if (requireDigit && !analysis.hasDigit) {
        return message ?? 'Include at least one number (0-9)';
      }
      if (requireSpecial && !analysis.hasSpecialChar) {
        return message ?? 'Include at least one special symbol (!@#\$%)';
      }
      return null;
    };
  }

  /// Computes a real-time [PasswordStrengthAnalysis] for the given [password].
  static PasswordStrengthAnalysis analyzePassword(
    String password, {
    int minLength = 8,
  }) {
    if (password.isEmpty) {
      return const PasswordStrengthAnalysis(
        score: 0.0,
        level: PasswordStrengthLevel.empty,
        hasMinLength: false,
        hasUppercase: false,
        hasLowercase: false,
        hasDigit: false,
        hasSpecialChar: false,
      );
    }

    final hasMin = password.length >= minLength;
    final hasUpper = _uppercaseRegex.hasMatch(password);
    final hasLower = _lowercaseRegex.hasMatch(password);
    final hasNum = _digitRegex.hasMatch(password);
    final hasSpec = _specialCharRegex.hasMatch(password);

    var passed = 0;
    if (hasMin) passed++;
    if (hasUpper) passed++;
    if (hasLower) passed++;
    if (hasNum) passed++;
    if (hasSpec) passed++;

    final lengthBonus = (password.length >= 12) ? 0.1 : 0.0;
    final rawScore = ((passed / 5.0) + lengthBonus).clamp(0.1, 1.0);

    final PasswordStrengthLevel level;
    if (passed <= 2) {
      level = PasswordStrengthLevel.weak;
    } else if (passed == 3) {
      level = PasswordStrengthLevel.fair;
    } else if (passed == 4) {
      level = PasswordStrengthLevel.good;
    } else {
      level = PasswordStrengthLevel.strong;
    }

    return PasswordStrengthAnalysis(
      score: rawScore,
      level: level,
      hasMinLength: hasMin,
      hasUppercase: hasUpper,
      hasLowercase: hasLower,
      hasDigit: hasNum,
      hasSpecialChar: hasSpec,
    );
  }

  /// Validates an international or local phone number format.
  static FormsFieldRule phone({
    String message = 'Enter a valid phone number',
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      if (!_phoneRegex.hasMatch(text)) return message;
      return null;
    };
  }

  /// Validates a web URL string.
  static FormsFieldRule url({
    String message = 'Enter a valid URL (e.g. https://humanize.id)',
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      if (!_urlRegex.hasMatch(text)) return message;
      return null;
    };
  }

  /// Validates that the input can be parsed as a number.
  static FormsFieldRule numeric({
    String message = 'Enter a valid number',
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      if (value is num) return null;
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      if (num.tryParse(text) == null) return message;
      return null;
    };
  }

  /// Validates that a numeric value lies within `[min, max]`.
  static FormsFieldRule range(
    num min,
    num max, {
    String? message,
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final num? parsed =
          value is num ? value : num.tryParse(value.toString().trim());
      if (parsed == null) {
        return message ?? 'Enter a number between $min and $max';
      }
      if (parsed < min || parsed > max) {
        return message ?? 'Value must be between $min and $max';
      }
      return null;
    };
  }

  /// Validates a credit card number using length and Luhn checksum rules.
  static FormsFieldRule creditCard({
    String message = 'Enter a valid card number',
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final digits = value.toString().replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return null;
      if (!isLuhnValid(digits)) return message;
      return null;
    };
  }

  /// Validates that an OTP / PIN string matches the required [length].
  static FormsFieldRule otpLength(
    int length, {
    String? message,
  }) {
    return (dynamic value, Map<String, dynamic> _) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      if (text.length != length) {
        return message ?? 'Enter all $length verification digits';
      }
      return null;
    };
  }

  /// Validates that a field's value matches another field identified by [targetKey].
  static FormsFieldRule matchField(
    String targetKey, {
    String? targetLabel,
    String? message,
  }) {
    return (dynamic value, Map<String, dynamic> allValues) {
      if (value == null) return null;
      final other = allValues[targetKey];
      if (value.toString() != (other?.toString() ?? '')) {
        return message ?? 'Must match ${targetLabel ?? targetKey}';
      }
      return null;
    };
  }

  /// Combines multiple [validators] into a single rule that returns the first
  /// error message encountered.
  static FormsFieldRule compose(List<FormsFieldRule> validators) {
    return (dynamic value, Map<String, dynamic> allValues) {
      for (final validator in validators) {
        final error = validator(value, allValues);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Performs a standard Luhn checksum verification on a credit card string.
  static bool isLuhnValid(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;

    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Detects the [CreditCardBrand] from a partial or complete card number.
  static CreditCardBrand detectCardBrand(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return CreditCardBrand.unknown;
    if (digits.startsWith('4')) return CreditCardBrand.visa;
    if (digits.startsWith('34') || digits.startsWith('37')) {
      return CreditCardBrand.amex;
    }
    if (digits.startsWith('6011') || digits.startsWith('65')) {
      return CreditCardBrand.discover;
    }
    if (digits.length >= 2) {
      final prefix2 = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (prefix2 >= 51 && prefix2 <= 55) return CreditCardBrand.mastercard;
    }
    if (digits.length >= 4) {
      final prefix4 = int.tryParse(digits.substring(0, 4)) ?? 0;
      if (prefix4 >= 2221 && prefix4 <= 2720) {
        return CreditCardBrand.mastercard;
      }
    }
    return CreditCardBrand.unknown;
  }

  /// Formats a raw digit string into 4-digit credit card groups.
  static String formatCardNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final clamped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < clamped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clamped[i]);
    }
    return buffer.toString();
  }
}
