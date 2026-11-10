import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/form_parts.dart';
import '../../core/widgets/state_views.dart';
import '../../routing/routes.dart';
import 'session.dart';
import 'widgets/auth_parts.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider).sendPasswordReset(_identifier.text);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = mapError(e).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    void backToLogin() =>
        context.canPop() ? context.pop() : context.go(Routes.login);

    if (_sent) {
      return AuthScaffold(
        showBack: true,
        bottom: BottomActionBar(
          child: PrimaryButton(label: 'Back to log in', onPressed: backToLogin),
        ),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 40,
                color: AppColors.success,
              ),
            ),
          ),
          Space.v24,
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Space.v8,
          Text(
            'If an account exists for ${_identifier.text.trim()}, a link to reset your password is on its way. '
            "It may take a minute, and it's worth checking your spam folder.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
          Space.v16,
          Center(
            child: TextButton(
              onPressed: () => setState(() => _sent = false),
              child: const Text('Use a different email or phone'),
            ),
          ),
        ],
      );
    }

    return AuthScaffold(
      showBack: true,
      bottom: BottomActionBar(
        child: PrimaryButton(
          label: 'Send reset link',
          loading: _sending,
          onPressed: _send,
        ),
      ),
      children: [
        Text(
          'Reset your password',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Space.v8,
        const Text(
          "Enter the email or phone number on your account and we'll email you a link to set a new password.",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.5,
            height: 1.45,
          ),
        ),
        Space.v24,
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FieldLabel('Email or phone number'),
              TextFormField(
                controller: _identifier,
                enabled: !_sending,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'you@company.com or 98XXXXXXXX',
                  prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                ),
                validator: Validators.identifier,
                onFieldSubmitted: (_) => _send(),
              ),
            ],
          ),
        ),
        if (_error != null) ...[Space.v16, InlineBanner(message: _error!)],
      ],
    );
  }
}
