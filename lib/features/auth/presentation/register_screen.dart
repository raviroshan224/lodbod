import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/field_prefix.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../domain/user_profile.dart';
import 'session.dart';
import 'widgets/auth_parts.dart';

/// Step 1 of 2: shipper details. Step 2 (email verification) follows
/// automatically once the account is created.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _password = TextEditingController();
  late final _terms = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.terms);
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.privacy);

  bool _accepted = false;
  bool _submitting = false;
  bool _submittedOnce = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _company, _password]) {
      c.dispose();
    }
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submittedOnce = true;
      _error = null;
    });
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !_accepted) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await ref
          .read(authActionsProvider)
          .register(
            Registration(
              name: _name.text,
              phone: Validators.normalizePhone(_phone.text),
              email: _email.text,
              company: _company.text,
              password: _password.text,
            ),
          );
      HapticFeedback.lightImpact();
      // The router continues to email verification.
    } catch (e) {
      if (mounted) setState(() => _error = mapError(e).message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textMuted,
    );

    return AuthScaffold(
      showBack: true,
      step: l10n.stepOf(1, 2),
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      children: [
        Form(
          key: _formKey,
          autovalidateMode: _submittedOnce
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldLabel.plain(l10n.fieldFullName),
                TextFormField(
                  controller: _name,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: InputDecoration(hintText: l10n.hintName),
                  validator: Validators.name,
                ),
                Space.v20,
                FieldLabel.plain(l10n.fieldPhone),
                TextFormField(
                  controller: _phone,
                  enabled: !_submitting,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                    LengthLimitingTextInputFormatter(16),
                  ],
                  decoration: const InputDecoration(
                    hintText: '98XXXXXXXX',
                    prefixIcon: FieldPrefix.dialCode(),
                  ),
                  validator: (v) => Validators.phone(v),
                ),
                Space.v20,
                FieldLabel.plain(l10n.fieldEmail),
                TextFormField(
                  controller: _email,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    hintText: l10n.hintEmail,
                    helperText: l10n.registerVerifyHelper,
                  ),
                  validator: Validators.email,
                ),
                Space.v20,
                FieldLabel(l10n.fieldCompany, isRequired: false),
                TextFormField(
                  controller: _company,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.organizationName],
                  decoration: InputDecoration(hintText: l10n.hintCompany),
                ),
                Space.v20,
                FieldLabel.plain(l10n.fieldPassword),
                PasswordField(
                  controller: _password,
                  enabled: !_submitting,
                  showStrength: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.newPassword,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        Space.v16,
        // The whole row toggles the box, like tapping a form label.
        InkWell(
          onTap: _submitting
              ? null
              : () => setState(() => _accepted = !_accepted),
          borderRadius: Radii.input,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _accepted,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: _submitting
                    ? null
                    : (v) => setState(() => _accepted = v ?? false),
              ),
              Space.h8,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Text.rich(
                    TextSpan(
                      text: l10n.legalIAgree,
                      children: [
                        TextSpan(
                          text: l10n.legalTerms,
                          style: link,
                          recognizer: _terms,
                        ),
                        TextSpan(text: l10n.legalAnd),
                        TextSpan(
                          text: l10n.legalPrivacy,
                          style: link,
                          recognizer: _privacy,
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_submittedOnce && !_accepted)
          FieldErrorText(l10n.registerAcceptTerms),
        Space.v24,
        if (_error != null) ...[InlineBanner(message: _error!), Space.v16],
        PrimaryButton(
          label: l10n.actionCreateAccount,
          loading: _submitting,
          onPressed: _submit,
        ),
        Space.v16,
        AuthSwitchPrompt(
          prompt: l10n.registerHaveAccount,
          action: l10n.actionLogIn,
          onPressed: _submitting ? null : () => context.go(Routes.login),
        ),
      ],
    );
  }
}
