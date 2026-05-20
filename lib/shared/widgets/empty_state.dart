import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String ctaText;
  final VoidCallback onCtaPressed;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.ctaText,
    required this.onCtaPressed,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onCtaPressed, child: Text(ctaText)),
          ],
        ),
      ),
    );
  }
}
