import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common.dart';
import 'session.dart';

/// Shown while the saved session is restored. The router moves on as soon as
/// the session is known, so this never delays the user artificially. If the
/// profile can't be loaded, it says so and offers retry or sign-out instead
/// of waiting forever.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session is SessionProfileError) {
      return _ProfileLoadFailed(message: session.error.message);
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.75,
                  colors: [Color(0xFFFFE3D5), AppColors.background],
                ),
              ),
            ),
          ),
          const Center(child: BrandMark(size: 72, showWordmark: true)),
          Positioned(
            left: Gap.xl * 2,
            right: Gap.xl * 2,
            bottom: Gap.xxl,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: Radii.chip,
                    child: const LinearProgressIndicator(minHeight: 3),
                  ),
                  Space.v8,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Checking your session…',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadFailed extends ConsumerWidget {
  const _ProfileLoadFailed({required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Gap.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 56),
                Space.v24,
                const Text(
                  "We couldn't load your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Space.v8,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Space.v24,
                FilledButton(
                  onPressed: () => ref.invalidate(profileProvider),
                  child: const Text('Try again'),
                ),
                Space.v8,
                TextButton(
                  onPressed: () => ref.read(authActionsProvider).signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
