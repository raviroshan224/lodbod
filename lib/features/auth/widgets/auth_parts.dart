import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common.dart';
import '../../../routing/routes.dart';

/// Shared scaffold for auth screens: centred, scrollable, keyboard-safe.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.showBack = false,
    this.title,
    this.subtitle,
    this.progress,
    this.bottom,
  });

  final List<Widget> children;
  final bool showBack;
  final String? title;
  final String? subtitle;

  /// 0..1 progress shown under the header (multi-step flows).
  final double? progress;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Screens reached with `go` have nothing to pop to: system back
      // returns to log in instead of closing the app.
      canPop: !showBack || context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.login);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (showBack || title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.page,
                    Gap.sm,
                    Gap.page,
                    0,
                  ),
                  child: Row(
                    children: [
                      if (showBack)
                        CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Back',
                          size: 40,
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go(Routes.login),
                        ),
                      if (title != null) ...[
                        Space.h12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title!,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (progress != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.page,
                    Gap.md,
                    Gap.page,
                    0,
                  ),
                  child: ClipRRect(
                    borderRadius: Radii.chip,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: const Duration(milliseconds: 400),
                      builder: (_, v, _) =>
                          LinearProgressIndicator(value: v, minHeight: 4),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      Gap.xl,
                      Gap.lg,
                      Gap.xl,
                      Gap.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
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
    this.hint = 'Your password',
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool showStrength;
  final String hint;
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
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
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
        'Use 8+ characters with a letter and a number',
        AppColors.textMuted,
      ),
      1 => ('Weak', AppColors.error),
      2 => ('Good', AppColors.warning),
      _ => ('Strong', AppColors.success),
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
                  height: 4,
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
        Space.v4,
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: strength == 0 ? AppColors.textMuted : color,
            fontWeight: FontWeight.w600,
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
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
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
