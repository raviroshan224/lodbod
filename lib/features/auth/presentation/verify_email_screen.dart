import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../data/providers.dart';
import 'session.dart';
import 'widgets/auth_parts.dart';

/// Step 2 of 2 after registration. Verification is encouraged, not forced:
/// the shipper can continue and verify later from Account.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const _cooldown = 30;
  int _secondsLeft = _cooldown;
  Timer? _timer;
  bool _checking = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _message = null;
    });
    try {
      final user = await ref.read(authRepositoryProvider).reload();
      if (!mounted) return;
      if (user?.emailVerified ?? false) {
        showMessage(context, 'Email verified. Welcome to LODBOD!');
        context.go(Routes.home);
      } else {
        setState(() {
          _message = "We couldn't confirm it yet. Open the link in the email, then try again.";
          _messageIsError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = mapError(e).message;
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (!mounted) return;
      _startCooldown();
      setState(() {
        _message = 'Verification email sent again.';
        _messageIsError = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = mapError(e).message;
          _messageIsError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final email = session is SessionReady ? session.user.email : '';

    return AuthScaffold(
      step: 'Step 2 of 2',
      badge: const AuthIconBadge(Icons.mark_email_unread_outlined),
      title: 'Verify your email',
      subtitleSpan: TextSpan(
        text: 'We sent a verification link to ',
        children: [
          TextSpan(
            text: email,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const TextSpan(text: '. Open it to activate your account.'),
        ],
      ),
      children: [
        if (_message != null) ...[
          InlineBanner(
            message: _message!,
            tone: _messageIsError ? BannerTone.warning : BannerTone.success,
          ),
          Space.v16,
        ],
        PrimaryButton(
          label: "I've verified my email",
          loading: _checking,
          onPressed: _check,
        ),
        Space.v16,
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Didn't get it?",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.5),
            ),
            TextButton(
              onPressed: _secondsLeft > 0 ? null : _resend,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(
                _secondsLeft > 0
                    ? 'Resend in 0:${_secondsLeft.toString().padLeft(2, '0')}'
                    : 'Resend email',
              ),
            ),
          ],
        ),
        const Divider(height: Gap.xxl),
        TextButton(
          onPressed: () => context.go(Routes.home),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Skip for now'),
        ),
      ],
    );
  }
}
