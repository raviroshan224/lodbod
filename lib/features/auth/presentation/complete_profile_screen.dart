import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/field_prefix.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/state_views.dart';
import 'session.dart';
import 'widgets/auth_parts.dart';

/// Shown if an account exists but its shipper profile doesn't (for example
/// sign-up was interrupted by a lost connection).
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _company.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final session = ref.read(sessionProvider);
    if (_saving || session is! SessionNeedsProfile) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(authActionsProvider)
          .completeProfile(
            session.user,
            name: _name.text,
            phone: Validators.normalizePhone(_phone.text),
            company: _company.text,
          );
    } catch (e) {
      if (mounted) setState(() => _error = mapError(e).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBrand: true,
      title: 'Finish setting up',
      subtitle:
          'Tell us who you are so carriers know who they are working with.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FieldLabel.plain('Full name'),
              TextFormField(
                controller: _name,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. Aarav Shrestha',
                ),
                validator: Validators.name,
              ),
              Space.v20,
              const FieldLabel.plain('Phone number'),
              TextFormField(
                controller: _phone,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
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
              const FieldLabel('Company name', isRequired: false),
              TextFormField(
                controller: _company,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Himal Traders Pvt. Ltd.',
                ),
                onFieldSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
        Space.v24,
        if (_error != null) ...[InlineBanner(message: _error!), Space.v16],
        PrimaryButton(label: 'Continue', loading: _saving, onPressed: _save),
        Space.v8,
        TextButton(
          onPressed: _saving
              ? null
              : () => ref.read(authActionsProvider).signOut(),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
