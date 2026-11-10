import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import 'session.dart';
import 'widgets/auth_parts.dart';

/// Log in with one "email or phone number" field and a password. One field
/// for both (as most sign-in forms do) means no mode to pick first and no
/// typing a phone number into an email box.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _submitting = false;
  bool _submittedOnce = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submittedOnce = true;
      _error = null;
    });
    ref.read(authNoticeProvider.notifier).clear();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await ref
          .read(authActionsProvider)
          .signIn(identifier: _identifier.text, password: _password.text);
      HapticFeedback.lightImpact();
      // The router moves to Home once the profile has loaded.
    } catch (e) {
      if (mounted) setState(() => _error = mapError(e).message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _error ?? ref.watch(authNoticeProvider);

    return AuthScaffold(
      showBrand: true,
      title: 'Welcome back',
      subtitle: 'Log in to manage your loads and shipments.',
      footer: const LegalFootnote(),
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
                const FieldLabel.plain('Email or phone number'),
                TextFormField(
                  key: const ValueKey('identifier'),
                  controller: _identifier,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.telephoneNumber,
                  ],
                  decoration: const InputDecoration(
                    hintText: 'you@company.com or 98XXXXXXXX',
                  ),
                  validator: Validators.identifier,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                Space.v20,
                const FieldLabel.plain('Password'),
                PasswordField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  enabled: !_submitting,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password is required' : null,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _submitting
                ? null
                : () => context.push(Routes.forgotPassword),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: const Text('Forgot password?'),
          ),
        ),
        Space.v12,
        if (message != null) ...[InlineBanner(message: message), Space.v16],
        PrimaryButton(
          label: 'Log in',
          loading: _submitting,
          onPressed: _submit,
        ),
        Space.v16,
        // `go`, not `push`: the router must see /register as the current
        // location to continue to email verification after sign-up.
        AuthSwitchPrompt(
          prompt: "Don't have an account?",
          action: 'Create account',
          onPressed: _submitting ? null : () => context.go(Routes.register),
        ),
      ],
    );
  }
}
