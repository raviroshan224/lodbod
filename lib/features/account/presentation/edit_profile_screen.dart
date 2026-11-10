import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/field_prefix.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/session.dart';
import '../data/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: ref.read(currentUserProvider).name,
  );
  late final _company = TextEditingController(
    text: ref.read(currentUserProvider).company,
  );
  late final _phone = TextEditingController(
    text: ref.read(currentUserProvider).phone,
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final user = ref.read(currentUserProvider);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .updateProfile(
            user.copyWith(
              name: _name.text.trim(),
              company: _company.text.trim(),
              phone: Validators.normalizePhone(_phone.text),
            ),
            previousPhone: user.phone,
          );
      if (!mounted) return;
      showMessage(context, 'Profile updated');
      context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = mapError(e).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: const DetailAppBar(title: 'Profile & company'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Gap.page,
            Gap.sm,
            Gap.page,
            Gap.xl,
          ),
          children: [
            Center(
              child: InitialsAvatar(
                Fmt.initials(_name.text.isEmpty ? user.name : _name.text),
                size: 72,
              ),
            ),
            Space.v24,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Full name'),
                  TextFormField(
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                    validator: Validators.name,
                  ),
                  Space.v16,
                  const FieldLabel('Company name', isRequired: false),
                  TextFormField(
                    controller: _company,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.business_outlined, size: 20),
                    ),
                  ),
                  Space.v16,
                  const FieldLabel('Phone number'),
                  TextFormField(
                    controller: _phone,
                    enabled: !_saving,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: FieldPrefix.phone(),
                      helperText: 'You can log in with this number.',
                    ),
                    validator: (v) => Validators.phone(v),
                  ),
                  Space.v16,
                  const FieldLabel.plain('Email'),
                  TextFormField(
                    initialValue: user.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                      helperText:
                          'Your sign-in email. Contact support to change it.',
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[Space.v16, InlineBanner(message: _error!)],
            Space.v12,
            const Text(
              'Carriers see your name and company on requests you post.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: PrimaryButton(
          label: 'Save changes',
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}
