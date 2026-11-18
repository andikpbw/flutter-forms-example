## 1.0.1

* Replaced synthetic SVG diagrams with real pixel-accurate animated Flutter UI recordings (`doc/showcase_banner.gif`, `doc/smart_form_preview.gif`, `doc/wizard_stepper_preview.gif`, `doc/payment_otp_preview.gif`, and `doc/themes_rating_preview.gif`) captured directly from the running `forms_example` widgets.
* Refined `SmartFormBuilder`, `ModernDropdownField`, and `FormTemplatePreset` typography and layout for clean, professional SaaS form aesthetics.

## 1.0.0

* Initial stable release of `forms_example`.
* Added `SmartFormBuilder` providing a declarative schema-driven form renderer with live completion readiness progress bar, 4 built-in template presets (`FormTemplatePreset.authSignup`, `paymentCheckout`, `feedbackSurvey`, `profileOnboarding`), live JSON payload inspector, and validation summary banners.
* Added `ModernFormStepper` providing a multi-step onboarding wizard with animated horizontal step progress indicators, per-step validation gates, and customizable navigation controls.
* Added `ModernTextField` supporting text, smart email domain quick-chips (`@humanize.id`, `@gmail.com`, `@outlook.com`), live 4-segment password entropy strength meters with rule checklist pills (`8+ chars`, `A-Z`, `0-9`, `!@#$`), numeric increment/decrement steppers, auto-formatted Luhn credit card numbers with brand detection (`VISA`, `MASTERCARD`, `AMEX`, `DISCOVER`), date pickers, and multiline text areas.
* Added `ModernChoiceSelector`, `ModernDropdownField`, `ModernSwitchCard`, `ModernSliderField`, `ModernRatingField`, and `ModernOtpField` (segmented 4/6-digit verification code boxes).
* Added `FormsController` and `FormsValidator` for reactive programmatic form state management, JSON export/import, and composable zero-dependency validation rules.
* Added 6 studio theme presets in `FormsStyle`: `modernIndigo`, `cyberDark`, `glassAurora`, `emeraldMinimal`, `sunsetWarm`, and `softNeumorphic`.
