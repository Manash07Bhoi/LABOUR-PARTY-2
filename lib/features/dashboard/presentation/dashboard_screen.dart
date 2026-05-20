import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/shared/widgets/empty_state.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/shared/widgets/skeleton_loading.dart';
import 'package:labour_party/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _currentDate;
  late String _currentSession;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTimeUtils.getCurrentDateFormatted();
    _currentSession = DateTimeUtils.getCurrentSession();
    context.read<WorkBloc>().add(
      LoadDashboardDataEvent(_currentDate, _currentSession),
    );
  }

  void _onAddQuickTrip() {
    context.read<WorkBloc>().add(
      AddQuickTripEvent(date: _currentDate, session: _currentSession),
    );
    context.go('/add-edit-work', extra: {'isNew': true});
  }

  void _onRemoveLatestTrip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurfaceColor,
        title: const Text('Remove Trip', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to remove the latest trip?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<WorkBloc>().add(const RemoveLatestTripEvent());
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.agriculture, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Labour Party',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: BlocBuilder<WorkBloc, WorkState>(
        builder: (context, state) {
          if (state is WorkLoading || state is WorkInitial) {
            return _buildSkeleton();
          } else if (state is WorkEmpty) {
            return _buildEmptyState();
          } else if (state is DashboardLoaded) {
            return _buildDashboard(state);
          } else if (state is WorkError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
                onPressed: () {
                  context.go('/add-edit-work', extra: {'isNew': true});
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Work'),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(duration: 2.seconds, color: Colors.white24),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SkeletonContainer(width: double.infinity, height: 180),
        const SizedBox(height: 24),
        const SkeletonContainer(width: double.infinity, height: 80),
        const SizedBox(height: 24),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonContainer(width: double.infinity, height: 100),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      message: 'No work added today',
      ctaText: 'Add First Trip',
      icon: Icons.work_outline,
      onCtaPressed: () => context.go('/add-edit-work', extra: {'isNew': true}),
    ).animate().fade().scale();
  }

  Widget _buildDashboard(DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WorkBloc>().add(
          LoadDashboardDataEvent(_currentDate, _currentSession),
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildSummaryCard(state).animate().fade().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          _buildQuickTripCounter(
            state,
          ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          const Text(
            'Recent Trips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fade(delay: 200.ms),
          const SizedBox(height: 12),
          _buildRecentTripsList(state).animate().fade(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DashboardLoaded state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_currentDate • $_currentSession',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (state.currentWork != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.currentWork!.workType,
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Total\nTrips',
                '${state.totalTrips}',
                Icons.local_shipping_outlined,
              ),
              _buildStatItem(
                'Total\nLabour',
                '${state.totalLabourCount}',
                Icons.people_outline,
              ),
              _buildStatItem(
                'Morning\nTrips',
                '${state.morningTripCount}',
                Icons.wb_sunny_outlined,
              ),
              _buildStatItem(
                'Evening\nTrips',
                '${state.eveningTripCount}',
                Icons.nights_stay_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickTripCounter(DashboardLoaded state) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: state.currentTrips.isNotEmpty
                ? _onRemoveLatestTrip
                : null,
            icon: const Icon(Icons.remove_circle_outline, size: 32),
            color: state.currentTrips.isNotEmpty
                ? AppTheme.errorColor
                : Colors.white24,
          ),
          Column(
            children: [
              const Text(
                'Current Trip',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.currentTrips.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
                onPressed: _onAddQuickTrip,
                icon: const Icon(Icons.add_circle, size: 40),
                color: AppTheme.successColor,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
        ],
      ),
    );
  }

  Widget _buildRecentTripsList(DashboardLoaded state) {
    if (state.currentTrips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No trips recorded yet.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.currentTrips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = state.currentTrips[state.currentTrips.length - 1 - index];
        return Dismissible(
          key: ValueKey(trip.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.darkSurfaceColor,
                title: const Text(
                  'Delete Trip',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Are you sure you want to delete this trip?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            context.read<WorkBloc>().add(const RemoveLatestTripEvent());
          },
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${trip.tripNumber}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.tractor.isNotEmpty
                            ? trip.tractor
                            : 'Unknown Tractor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Driver: ${trip.driverName.isNotEmpty ? trip.driverName : 'Unknown'}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateTimeUtils.formatTime(trip.createdAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
