import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String filterOption;
  final VoidCallback onReset;

  const EmptyState({
    super.key,
    required this.filterOption,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final emptyStateConfig = _getEmptyStateConfig();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF5B67CA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyStateConfig['icon'] as IconData,
                size: 80,
                color: const Color(0xFF5B67CA).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              emptyStateConfig['title'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F36),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              emptyStateConfig['message'] as String,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF8F9BB3),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (filterOption != 'all') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Show All Deadlines'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B67CA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getEmptyStateConfig() {
    switch (filterOption) {
      case 'active':
        return {
          'icon': Icons.check_circle_outline,
          'title': 'No Active Countdowns',
          'message': 'Great work! You have no pending deadlines at the moment.',
        };
      case 'completed':
        return {
          'icon': Icons.emoji_events_outlined,
          'title': 'No Completed Deadlines',
          'message': 'Complete deadlines to see them here and track your progress.',
        };
      case 'expired':
        return {
          'icon': Icons.timer_off_outlined,
          'title': 'No Expired Deadlines',
          'message': 'Excellent! All your deadlines are on track.',
        };
      default:
        return {
          'icon': Icons.timer,
          'title': 'No Deadlines Yet',
          'message': 'Start by adding your first deadline using the button below.',
        };
    }
  }
}