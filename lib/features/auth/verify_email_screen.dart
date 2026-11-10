import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/state_views.dart';
import '../../data/providers.dart';
import '../../routing/routes.dart';
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
      title: 'Verify your email',
      subtitle: 'One last step before you start posting loads.',
      progress: 1,
      bottom: BottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              label: "I've verified my email",
              loading: _checking,
              onPressed: _check,
            ),
            Space.v4,
            TextButton(
              onPressed: () => context.go(Routes.home),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.mark_email_unread_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        Space.v24,
        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Space.v8,
        Text.rich(
          TextSpan(
            text: 'We sent a verification link to ',
            children: [
              TextSpan(
                text: email,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(text: '. Open it to confirm your account.'),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
        Space.v16,
        Center(
          child: _secondsLeft > 0
              ? Text(
                  'Resend available in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                )
              : TextButton(
                  onPressed: _resend,
                  child: const Text('Resend email'),
                ),
        ),
        if (_message != null) ...[
          Space.v12,
          InlineBanner(
            message: _message!,
            tone: _messageIsError ? BannerTone.warning : BannerTone.success,
          ),
        ],
      ],
    );
  }
}
