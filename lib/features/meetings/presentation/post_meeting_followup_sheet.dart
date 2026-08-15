import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/application/task_list_provider.dart';
import '../../tasks/domain/task.dart';
import '../domain/meeting.dart';

class PostMeetingFollowUpSheet extends ConsumerStatefulWidget {
  final Meeting meeting;

  const PostMeetingFollowUpSheet({super.key, required this.meeting});

  @override
  ConsumerState<PostMeetingFollowUpSheet> createState() =>
      _PostMeetingFollowUpSheetState();
}

class _PostMeetingFollowUpSheetState
    extends ConsumerState<PostMeetingFollowUpSheet> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createFollowUp() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe the follow-up')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final task = Task.create(
      title: text,
      description: 'Follow-up from: ${widget.meeting.title}',
      priority: TaskPriority.high,
      dueAt: DateTime.now().add(const Duration(days: 1)),
      estimatedMinutes: 30,
      tags: ['follow-up'],
    );

    await ref.read(taskListProvider.notifier).addTask(task);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow-up task created for tomorrow'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Meeting finished',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.meeting.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Any follow-ups?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. Send proposal to Sarah',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting ? null : _createFollowUp,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Follow-up Task'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No follow-up needed'),
          ),
        ],
      ),
    );
  }
}
