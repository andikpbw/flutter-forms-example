import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forms_example/forms_example.dart';

void main() {
  group('FormsValidator Unit Tests', () {
    test('required validator checks null, empty string, iterable, and bool',
        () {
      final rule = FormsValidator.required(message: 'Required');
      expect(rule(null, const <String, dynamic>{}), 'Required');
      expect(rule('   ', const <String, dynamic>{}), 'Required');
      expect(rule(<String>[], const <String, dynamic>{}), 'Required');
      expect(rule(false, const <String, dynamic>{}), 'Required');
      expect(rule('Humanize AI', const <String, dynamic>{}), isNull);
      expect(rule(<String>['flutter'], const <String, dynamic>{}), isNull);
      expect(rule(true, const <String, dynamic>{}), isNull);
    });

    test('email, url, phone, numeric, and range validators work accurately',
        () {
      final emailRule = FormsValidator.email();
      expect(emailRule('invalid-email', const <String, dynamic>{}), isNotNull);
      expect(emailRule('dev@humanize.id', const <String, dynamic>{}), isNull);

      final urlRule = FormsValidator.url();
      expect(urlRule('not a url', const <String, dynamic>{}), isNotNull);
      expect(urlRule('https://humanize.id', const <String, dynamic>{}), isNull);

      final phoneRule = FormsValidator.phone();
      expect(phoneRule('abc', const <String, dynamic>{}), isNotNull);
      expect(phoneRule('+62 812-3456-7890', const <String, dynamic>{}), isNull);

      final numRule = FormsValidator.numeric();
      expect(numRule('12x', const <String, dynamic>{}), isNotNull);
      expect(numRule('42.5', const <String, dynamic>{}), isNull);

      final rangeRule = FormsValidator.range(10, 50);
      expect(rangeRule(5, const <String, dynamic>{}), isNotNull);
      expect(rangeRule(25, const <String, dynamic>{}), isNull);
      expect(rangeRule(90, const <String, dynamic>{}), isNotNull);
    });

    test('password analysis and strength validator evaluate all rules', () {
      final empty = FormsValidator.analyzePassword('');
      expect(empty.level, PasswordStrengthLevel.empty);
      expect(empty.passedRulesCount, 0);

      final weak = FormsValidator.analyzePassword('abc');
      expect(weak.level, PasswordStrengthLevel.weak);

      final strong = FormsValidator.analyzePassword('Humanize#2026!');
      expect(strong.level, PasswordStrengthLevel.strong);
      expect(strong.passedRulesCount, 5);
      expect(strong.hasMinLength, isTrue);
      expect(strong.hasUppercase, isTrue);
      expect(strong.hasLowercase, isTrue);
      expect(strong.hasDigit, isTrue);
      expect(strong.hasSpecialChar, isTrue);

      final rule = FormsValidator.passwordStrength();
      expect(rule('short', const <String, dynamic>{}), isNotNull);
      expect(rule('Humanize#2026!', const <String, dynamic>{}), isNull);
    });

    test('creditCard Luhn check, brand detection, and formatter work', () {
      expect(FormsValidator.detectCardBrand('4242'), CreditCardBrand.visa);
      expect(
          FormsValidator.detectCardBrand('5200'), CreditCardBrand.mastercard);
      expect(FormsValidator.detectCardBrand('3782'), CreditCardBrand.amex);
      expect(FormsValidator.detectCardBrand('6011'), CreditCardBrand.discover);
      expect(FormsValidator.detectCardBrand('9999'), CreditCardBrand.unknown);

      final formatted = FormsValidator.formatCardNumber('4242424242424242');
      expect(formatted, '4242 4242 4242 4242');
      expect(FormsValidator.isLuhnValid(formatted), isTrue);
      expect(FormsValidator.isLuhnValid('4242 4242 4242 4241'), isFalse);
    });

    test('matchField and compose validators combine rules properly', () {
      final matchRule = FormsValidator.matchField('password');
      expect(
        matchRule('wrong', <String, dynamic>{'password': 'secret'}),
        isNotNull,
      );
      expect(
        matchRule('secret', <String, dynamic>{'password': 'secret'}),
        isNull,
      );

      final composed = FormsValidator.compose(<FormsFieldRule>[
        FormsValidator.required(),
        FormsValidator.minLength(5),
      ]);
      expect(composed('', const <String, dynamic>{}), isNotNull);
      expect(composed('abc', const <String, dynamic>{}), isNotNull);
      expect(composed('valid_text', const <String, dynamic>{}), isNull);
    });
  });

  group('FormsController & FormsStyle Tests', () {
    test('FormsController manages presets, validation, JSON export, and reset',
        () async {
      final controller = FormsController(
        preset: FormTemplatePreset.authSignup,
      );
      expect(controller.fields.length, 5);
      expect(controller.completionPercentage, 100);
      expect(controller.isValid, isTrue);

      controller.setValue('email', 'invalid_email');
      expect(controller.getError('email'), isNotNull);
      expect(controller.isValid, isFalse);

      final failedSubmission = await controller.submit();
      expect(failedSubmission.isSuccess, isFalse);

      controller.setValue('email', 'support@humanize.id');
      expect(controller.getError('email'), isNull);

      final okSubmission = await controller.submit();
      expect(okSubmission.isSuccess, isTrue);
      expect(controller.toFormattedJson(), contains('support@humanize.id'));

      controller.reset();
      expect(controller.getValue<String>('email'), 'founder@humanize.id');
    });

    test('FormsStyle provides 6 presets and copyWith customization', () {
      final presets = <FormsStyle>[
        FormsStyle.modernIndigo(),
        FormsStyle.cyberDark(),
        FormsStyle.glassAurora(),
        FormsStyle.emeraldMinimal(),
        FormsStyle.sunsetWarm(),
        FormsStyle.softNeumorphic(),
      ];
      expect(presets.length, 6);
      expect(presets[1].isDark, isTrue);
      final customized = presets[0].copyWith(borderRadius: 24.0);
      expect(customized.borderRadius, 24.0);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('ModernTextField renders email domain chips and password meter',
        (tester) async {
      String latestEmail = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ModernTextField(
                    label: 'Work Email',
                    type: FormFieldType.email,
                    initialValue: 'andik',
                    emailDomains: const <String>['humanize.id', 'gmail.com'],
                    onChanged: (val) => latestEmail = val.toString(),
                  ),
                  const ModernTextField(
                    label: 'Password',
                    type: FormFieldType.password,
                    initialValue: 'Humanize#2026!',
                    showPasswordMeter: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('@humanize.id'), findsOneWidget);
      expect(find.text('Strong'), findsOneWidget);

      await tester.tap(find.text('@humanize.id'));
      await tester.pumpAndSettle();
      expect(latestEmail, 'andik@humanize.id');
    });

    testWidgets(
        'SmartFormBuilder renders presets, switches templates, and submits',
        (tester) async {
      FormSubmissionResult? submittedResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SmartFormBuilder(
                showPresetSelector: true,
                showJsonPreview: true,
                style: FormsStyle.cyberDark(),
                onSubmitted: (res) => submittedResult = res,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Submit Form'), findsOneWidget);

      await tester.ensureVisible(find.text('Submit Form'));
      await tester.tap(find.text('Submit Form'));
      await tester.pumpAndSettle();
      expect(submittedResult, isNotNull);
      expect(submittedResult!.isSuccess, isTrue);

      await tester.ensureVisible(find.text('Payment & Billing'));
      await tester.tap(find.text('Payment & Billing'));
      await tester.pumpAndSettle();
      expect(find.text('Cardholder Name'), findsOneWidget);
      expect(find.text('LUHN OK'), findsOneWidget);
    });

    testWidgets('ModernFormStepper navigates across 3 wizard steps and submits',
        (tester) async {
      FormSubmissionResult? wizardResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ModernFormStepper(
                style: FormsStyle.modernIndigo(),
                onSubmitted: (res) => wizardResult = res,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Advance from Step 1 to Step 2
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 3'), findsOneWidget);

      // Advance from Step 2 to Step 3
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Complete Setup'), findsOneWidget);

      // Submit on final step
      await tester.ensureVisible(find.text('Complete Setup'));
      await tester.tap(find.text('Complete Setup'));
      await tester.pumpAndSettle();
      expect(wizardResult, isNotNull);
      expect(wizardResult!.isSuccess, isTrue);
    });
  });
}
