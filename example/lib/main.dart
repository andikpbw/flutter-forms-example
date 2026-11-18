import 'package:flutter/material.dart';
import 'package:forms_example/forms_example.dart';

void main() {
  runApp(const FormsExampleShowcaseApp());
}

/// Root showcase application for `forms_example`.
class FormsExampleShowcaseApp extends StatefulWidget {
  /// Creates the [FormsExampleShowcaseApp].
  const FormsExampleShowcaseApp({super.key});

  @override
  State<FormsExampleShowcaseApp> createState() =>
      _FormsExampleShowcaseAppState();
}

class _FormsExampleShowcaseAppState extends State<FormsExampleShowcaseApp> {
  int _selectedThemeIndex = 0;
  int _selectedTabIndex = 0;

  late final FormsController _builderController;
  late final FormsController _wizardController;

  static final List<_ThemeEntry> _themeEntries = <_ThemeEntry>[
    _ThemeEntry('Modern Indigo', FormsStyle.modernIndigo()),
    _ThemeEntry('Cyber Dark', FormsStyle.cyberDark()),
    _ThemeEntry('Glass Aurora', FormsStyle.glassAurora()),
    _ThemeEntry('Emerald Minimal', FormsStyle.emeraldMinimal()),
    _ThemeEntry('Sunset Warm', FormsStyle.sunsetWarm()),
    _ThemeEntry('Soft Neumorphic', FormsStyle.softNeumorphic()),
  ];

  @override
  void initState() {
    super.initState();
    _builderController = FormsController(
      preset: FormTemplatePreset.authSignup,
    );
    _wizardController = FormsController()
      ..registerSteps(FormsController.buildDefaultWizardSteps());
  }

  @override
  void dispose() {
    _builderController.dispose();
    _wizardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _themeEntries[_selectedThemeIndex];
    final style = activeTheme.style;

    return MaterialApp(
      title: 'forms_example Studio Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: style.isDark ? Brightness.dark : Brightness.light,
        colorSchemeSeed: style.primaryColor,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: style.backgroundColor,
        appBar: AppBar(
          backgroundColor: style.cardColor,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: style.accentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.dynamic_form_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'forms_example Studio',
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: style.primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Humanize AI',
                  style: TextStyle(
                    color: style.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildThemeSelectorBar(style),
                  const SizedBox(height: 14),
                  _buildModeTabs(style),
                  const SizedBox(height: 16),
                  if (_selectedTabIndex == 0)
                    SmartFormBuilder(
                      controller: _builderController,
                      style: style,
                      showPresetSelector: true,
                      showJsonPreview: true,
                    )
                  else
                    ModernFormStepper(
                      controller: _wizardController,
                      style: style,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelectorBar(FormsStyle style) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(_themeEntries.length, (index) {
          final entry = _themeEntries[index];
          final selected = index == _selectedThemeIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.name),
              selected: selected,
              selectedColor: style.primaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: selected ? style.primaryColor : style.textColor,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 12,
              ),
              onSelected: (_) => setState(() => _selectedThemeIndex = index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildModeTabs(FormsStyle style) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ModeTabButton(
            title: 'Smart Schema Builder',
            icon: Icons.auto_awesome_mosaic_rounded,
            selected: _selectedTabIndex == 0,
            style: style,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeTabButton(
            title: 'Multi-Step Wizard',
            icon: Icons.route_rounded,
            selected: _selectedTabIndex == 1,
            style: style,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
        ),
      ],
    );
  }
}

class _ThemeEntry {
  const _ThemeEntry(this.name, this.style);
  final String name;
  final FormsStyle style;
}

class _ModeTabButton extends StatelessWidget {
  const _ModeTabButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final FormsStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: style.animationDuration,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          gradient: selected ? style.accentGradient : null,
          color: selected ? null : style.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? style.primaryColor : style.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 17,
              color: selected ? Colors.white : style.subtitleColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : style.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
