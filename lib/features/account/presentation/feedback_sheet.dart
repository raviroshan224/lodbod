import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/session.dart';
import '../data/providers.dart';

/// "Send feedback": stored in Firestore for the LODBOD team.
Future<void> showFeedbackSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    // Above the tab bar, so it's dimmed and can't be tapped meanwhile.
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (_) => const _FeedbackSheet(),
  );
}

class _FeedbackSheet extends ConsumerStatefulWidget {
  const _FeedbackSheet();

  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  static const _topics = ['Problem', 'Idea', 'Question'];
  String _topic = _topics.first;
  final _message = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_message.text.trim().length < 10) {
      setState(
        () => _error = 'Tell us a little more (at least 10 characters).',
      );
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .sendFeedback(
            ref.read(currentUserProvider).id,
            topic: _topic,
            message: _message.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showMessage(context, 'Thanks! Your feedback has been sent.');
    } catch (e) {
      if (mounted) setState(() => _error = mapError(e).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Send feedback',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Space.v4,
              const Text(
                'We read every message.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Space.v16,
              PillTabs<String>(
                values: _topics,
                selected: _topic,
                labelOf: (t) => t,
                onChanged: _sending ? null : (t) => setState(() => _topic = t),
              ),
              Space.v12,
              TextField(
                controller: _message,
                enabled: !_sending,
                autofocus: true,
                minLines: 4,
                maxLines: 6,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: switch (_topic) {
                    'Problem' => 'What happened, and what did you expect?',
                    'Idea' => 'What would make LODBOD better for you?',
                    _ => 'What would you like to know?',
                  },
                ),
              ),
              if (_error != null) ...[Space.v4, InlineBanner(message: _error!)],
              Space.v12,
              PrimaryButton(
                label: 'Send',
                icon: Icons.send_rounded,
                loading: _sending,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
