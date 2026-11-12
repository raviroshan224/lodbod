import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/session.dart';
import '../data/providers.dart';

Future<void> showFeedbackSheet(BuildContext context) {
  return showModalBottomSheet<void>(
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
  _Topic _topic = _Topic.problem;
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
      setState(() => _error = l10n.feedbackMin);
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
            topic: _topic.name,
            message: _message.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showMessage(context, l10n.feedbackSent);
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
                l10n.accountSendFeedback,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Space.v4,
              Text(
                l10n.feedbackSubtitle,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Space.v16,
              PillTabs<_Topic>(
                values: _Topic.values,
                selected: _topic,
                labelOf: (t) => t.label,
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
                decoration: InputDecoration(hintText: _topic.hint),
              ),
              if (_error != null) ...[Space.v4, InlineBanner(message: _error!)],
              Space.v12,
              PrimaryButton(
                label: l10n.feedbackSend,
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

enum _Topic {
  problem,
  idea,
  question;

  String get label => switch (this) {
    problem => l10n.feedbackProblem,
    idea => l10n.feedbackIdea,
    question => l10n.feedbackQuestion,
  };

  String get hint => switch (this) {
    problem => l10n.feedbackProblemHint,
    idea => l10n.feedbackIdeaHint,
    question => l10n.feedbackQuestionHint,
  };
}
