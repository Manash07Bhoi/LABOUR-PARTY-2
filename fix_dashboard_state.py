with open('lib/features/dashboard/presentation/dashboard_screen.dart', 'r') as f:
    content = f.read()

# Replace WorkActionSuccess() => Error with returning skeleton
# Wait, `TripDetailsLoaded() || WorkActionSuccess() => const Center(child: Text('Unexpected state...'))`
content = content.replace(
    'TripDetailsLoaded() || WorkActionSuccess() => const Center(\n              child: Text(\n                \'Unexpected state in Dashboard\',\n                style: TextStyle(color: AppTheme.errorColor),\n              ),\n            ),',
    'TripDetailsLoaded() => const Center(\n              child: Text(\n                \'Unexpected state in Dashboard\',\n                style: TextStyle(color: AppTheme.errorColor),\n              ),\n            ),\n            WorkActionSuccess() => _buildSkeleton(),'
)

with open('lib/features/dashboard/presentation/dashboard_screen.dart', 'w') as f:
    f.write(content)
