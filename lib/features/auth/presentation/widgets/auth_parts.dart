import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/common.dart';
import '../../../../routing/routes.dart';

/// Shared layout for every auth screen: a classic single column on white.
///
/// Top to bottom: optional back button or brand lockup, an optional step
/// caption, title and subtitle, then the form with its actions inline (the
/// primary button sits right under the last field, never pinned far away).
/// An optional [footer] (legal text) sits at the bottom of the screen and
/// steps aside while the keyboard is open.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.subtitleSpan,
    this.step,
    this.badge,
    this.showBack = false,
    this.showBrand = false,
    this.footer,
  });

  final String title;
  final String? subtitle;

  /// Rich subtitle (e.g. with an email address in bold), used instead of
  /// [subtitle].
  final InlineSpan? subtitleSpan;

  /// Small caption above the title in multi-step flows, e.g. "Step 1 of 2".
  final String? step;

  /// Icon above the title on confirmation screens (see [AuthIconBadge]).
  final Widget? badge;
  final bool showBack;

  /// The LODBOD logo lockup above the title (entry screens).
  final bool showBrand;
  final Widget? footer;
  final List<Widget> children;

  static const subtitleStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
    height: 1.45,
  );

  /// Field outline: dark enough for the 3:1 contrast WCAG asks of input
  /// boundaries, light enough to stay quiet on white.
  static const _fieldBorder = Color(0xFF9C8D89);

  /// White, outlined fields on the white auth pages; the app's tonal filled
  /// fields would read as grey blocks here.
  static ThemeData _theme(ThemeData base) {
    OutlineInputBorder line(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: Radii.input,
          borderSide: BorderSide(color: color, width: width),
        );
    return base.copyWith(
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: line(_fieldBorder),
        enabledBorder: line(_fieldBorder),
        disabledBorder: line(AppColors.border),
        focusedBorder: line(AppColors.primary, 1.5),
        errorBorder: line(AppColors.error),
        focusedErrorBorder: line(AppColors.error, 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final titleStyle = Theme.of(context).textTheme.headlineSmall
        ?.copyWith(fontSize: 26, letterSpacing: -0.5);

    return PopScope(
      // Screens reached with `go` have nothing to pop to: system back
      // returns to log in instead of closing the app.
      canPop: !showBack || context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.login);
      },
      child: Theme(
        data: _theme(Theme.of(context)),
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                if (showBack)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: 'Back',
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(Routes.login),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      Gap.xl,
                      showBack ? Gap.sm : Gap.xxl,
                      Gap.xl,
                      Gap.xl,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showBrand) ...[
                              const AuthBrand(),
                              const SizedBox(height: 40),
                            ],
                            if (badge != null) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: badge,
                              ),
                              Space.v20,
                            ],
                            if (step != null) ...[
                              Text(
                                step!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Space.v8,
                            ],
                            Text(title, style: titleStyle),
                            if (subtitleSpan != null) ...[
                              Space.v8,
                              Text.rich(subtitleSpan!, style: subtitleStyle),
                            ] else if (subtitle != null) ...[
                              Space.v8,
                              Text(subtitle!, style: subtitleStyle),
                            ],
                            Space.v32,
                            ...children,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (footer != null && !keyboardOpen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.xl,
                      Gap.sm,
                      Gap.xl,
                      Gap.lg,
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo tile and wordmark side by side, for the top of entry screens.
class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BrandMark(size: 36, elevated: false),
        SizedBox(width: 10),
        BrandWordmark(size: 24),
      ],
    );
  }
}

/// Round icon above the title on confirmation screens ("Check your email").
class AuthIconBadge extends StatelessWidget {
  const AuthIconBadge(this.icon, {super.key, this.success = false});
  final IconData icon;

  /// Green for a completed action, brand orange for one still to do.
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: success ? AppColors.successSoft : AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 28,
        color: success ? AppColors.success : AppColors.primary,
      ),
    );
  }
}

/// Centered "Don't have an account? Create account" line under the primary
/// button.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.5,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}

/// Password input with show/hide toggle and an optional strength meter.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.focusNode,
    this.validator,
    this.enabled = true,
    this.showStrength = false,
    this.hint,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool showStrength;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      key: const ValueKey('password'),
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.showStrength ? (_) => setState(() {}) : null,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
    );
    if (!widget.showStrength) return field;

    final strength = Validators.passwordStrength(widget.controller.text);
    final (label, color) = switch (strength) {
      0 => (
        'At least 8 characters, with a letter and a number',
        AppColors.textMuted,
      ),
      1 => ('Weak password', AppColors.error),
      2 => ('Good password', AppColors.warning),
      _ => ('Strong password', AppColors.success),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field,
        Space.v8,
        Row(
          children: [
            for (var i = 1; i <= 3; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= strength ? color : AppColors.divider,
                    borderRadius: Radii.chip,
                  ),
                ),
              ),
              if (i < 3) Space.h4,
            ],
          ],
        ),
        Space.v6,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: color,
            fontWeight: strength == 0 ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// "By continuing you agree to the Terms and Privacy Policy" with links.
class LegalFootnote extends StatefulWidget {
  const LegalFootnote({
    super.key,
    this.prefix = 'By continuing you agree to the ',
  });
  final String prefix;

  @override
  State<LegalFootnote> createState() => _LegalFootnoteState();
}

class _LegalFootnoteState extends State<LegalFootnote> {
  late final _terms = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.terms);
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.privacy);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textMuted,
    );
    return Text.rich(
      TextSpan(
        text: widget.prefix,
        children: [
          TextSpan(text: 'Terms of Service', style: link, recognizer: _terms),
          const TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy', style: link, recognizer: _privacy),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12.5,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}
