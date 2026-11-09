import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/field_prefix.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/user_profile.dart';
import '../../routing/routes.dart';
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
    return AuthScaffold(
      showBack: true,
      title: 'Create account',
      subtitle: 'Step 1 of 2 · Shipper details',
      progress: 0.5,
      bottom: BottomActionBar(
        child: PrimaryButton(
          label: 'Create account',
          loading: _submitting,
          onPressed: _submit,
        ),
      ),
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
                const FieldLabel('Full name'),
                TextFormField(
                  controller: _name,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    hintText: 'e.g. Aarav Shrestha',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  validator: Validators.name,
                ),
                Space.v16,
                const FieldLabel('Phone number'),
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
                    prefixIcon: FieldPrefix.phone(),
                  ),
                  validator: (v) => Validators.phone(v),
                ),
                Space.v16,
                const FieldLabel('Email'),
                TextFormField(
                  controller: _email,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    hintText: 'you@company.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                    helperText: "We'll send a verification link here.",
                  ),
                  validator: Validators.email,
                ),
                Space.v16,
                const FieldLabel('Company name', isRequired: false),
                TextFormField(
                  controller: _company,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.organizationName],
                  decoration: const InputDecoration(
                    hintText: 'e.g. Himal Traders Pvt. Ltd.',
                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                  ),
                ),
                Space.v16,
                const FieldLabel('Password'),
                PasswordField(
                  controller: _password,
                  enabled: !_submitting,
                  hint: 'Min. 8 characters',
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: _accepted,
                onChanged: _submitting
                    ? null
                    : (v) => setState(() => _accepted = v ?? false),
              ),
            ),
            Space.h8,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: _terms,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: _privacy,
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
        if (_submittedOnce && !_accepted)
          const FieldErrorText('Please accept the terms to create an account'),
        if (_error != null) ...[Space.v16, InlineBanner(message: _error!)],
        Space.v16,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: _submitting ? null : () => context.go(Routes.login),
              child: const Text('Log in'),
            ),
          ],
        ),
      ],
    );
  }
}
