import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/common.dart';

/// Shown while the saved session is restored. The router moves on as soon as
/// the session is known, so this never delays the user artificially.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
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
                  const Row(
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
