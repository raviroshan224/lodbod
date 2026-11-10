import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/field_prefix.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/navigation_parts.dart';
import '../../core/widgets/state_views.dart';
import '../../routing/routes.dart';
import 'session.dart';
import 'widgets/auth_parts.dart';

enum LoginMethod { phone, email }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  LoginMethod _method = LoginMethod.phone;
  bool _submitting = false;
  bool _submittedOnce = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
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
          .signIn(
            identifier: _method == LoginMethod.phone
                ? _phone.text
                : _email.text,
            password: _password.text,
          );
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
    final isPhone = _method == LoginMethod.phone;
    final notice = ref.watch(authNoticeProvider);
    final message = _error ?? notice;

    return AuthScaffold(
      bottom: AuthActionRow(
        // `go`, not `push`: the router must see /register as the current
        // location to continue to email verification after sign-up.
        secondary: TextButton(
          onPressed: _submitting ? null : () => context.go(Routes.register),
          child: const Text('Create account'),
        ),
        primary: SizedBox(
          width: 136,
          child: PrimaryButton(
            label: 'Log in',
            loading: _submitting,
            onPressed: _submit,
          ),
        ),
        footer: const LegalFootnote(),
      ),
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: BrandMark(size: 56),
        ),
        Space.v24,
        Text('Welcome back', style: Theme.of(context).textTheme.headlineLarge),
        Space.v8,
        const Text(
          'Log in to post loads, compare bids and track your shipments.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15.5,
            height: 1.4,
          ),
        ),
        Space.v32,
        Form(
          key: _formKey,
          autovalidateMode: _submittedOnce
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PillTabs<LoginMethod>(
                  values: LoginMethod.values,
                  selected: _method,
                  labelOf: (m) => m == LoginMethod.phone ? 'Phone' : 'Email',
                  iconOf: (m) => m == LoginMethod.phone
                      ? Icons.phone_outlined
                      : Icons.mail_outline_rounded,
                  onChanged: _submitting
                      ? null
                      : (m) => setState(() => _method = m),
                ),
                Space.v24,
                FieldLabel(isPhone ? 'Phone number' : 'Email address'),
                if (isPhone)
                  TextFormField(
                    key: const ValueKey('phone'),
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
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  )
                else
                  TextFormField(
                    key: const ValueKey('email'),
                    controller: _email,
                    enabled: !_submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      hintText: 'you@company.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                    ),
                    validator: Validators.email,
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                Space.v16,
                const FieldLabel('Password'),
                PasswordField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  enabled: !_submitting,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password is required' : null,
                  onSubmitted: (_) => _submit(),
                ),
                Space.v4,
                Align(
                  alignment: Alignment.centerLeft,
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
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: message == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: Gap.md),
                  child: InlineBanner(message: message),
                ),
        ),
      ],
    );
  }
}
