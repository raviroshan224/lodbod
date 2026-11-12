import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
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
        badge: const AuthIconBadge(
          Icons.mark_email_read_outlined,
          success: true,
        ),
        title: l10n.forgotSentTitle,
        subtitle: l10n.forgotSentBody(_identifier.text.trim()),
        children: [
          PrimaryButton(label: l10n.actionBackToLogIn, onPressed: backToLogin),
          Space.v8,
          TextButton(
            onPressed: () => setState(() => _sent = false),
            child: Text(l10n.forgotUseDifferent),
          ),
        ],
      );
    }

    return AuthScaffold(
      showBack: true,
      title: l10n.forgotTitle,
      subtitle: l10n.forgotSubtitle,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel.plain(l10n.fieldEmailOrPhone),
              TextFormField(
                controller: _identifier,
                enabled: !_sending,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(hintText: l10n.hintEmailOrPhone),
                validator: Validators.identifier,
                onFieldSubmitted: (_) => _send(),
              ),
            ],
          ),
        ),
        Space.v24,
        if (_error != null) ...[InlineBanner(message: _error!), Space.v16],
        PrimaryButton(
          label: l10n.forgotSend,
          loading: _sending,
          onPressed: _send,
        ),
        Space.v16,
        AuthSwitchPrompt(
          prompt: l10n.forgotRemembered,
          action: l10n.actionLogIn,
          onPressed: _sending ? null : backToLogin,
        ),
      ],
    );
  }
}
