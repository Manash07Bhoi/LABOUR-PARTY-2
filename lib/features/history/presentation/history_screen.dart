import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:labour_party/features/work/presentation/bloc/history_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/history_event.dart';
import 'package:labour_party/features/work/presentation/bloc/history_state.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/shared/widgets/empty_state.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/theme/app_theme.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HistoryBloc>().add(LoadHistoryEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading || state is HistoryInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          } else if (state is HistoryError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            );
          } else if (state is HistoryEmpty) {
            return EmptyStateWidget(
              icon: Icons.history,
              message: 'No historical work found',
              ctaText: '',
              onCtaPressed: () {},
            );
          } else if (state is HistoryLoaded) {
            final dates = state.groupedTrips.keys.toList()
              ..sort((a, b) => _compareDates(b, a)); // Descending order

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final sessions = state.groupedTrips[date]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: index == 0,
                        title: Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: sessions.entries.map((sessionEntry) {
                          final session = sessionEntry.key;
                          final trips = sessionEntry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  session,
                                  style: const TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...trips.map((trip) {
                                final work = state.worksMap[trip.workId];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  title: Text(
                                    'Trip #${trip.tripNumber} - ${trip.driverName}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    trip.tractor,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white54,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          if (work != null) {
                                            // Passing the work object correctly preserves history
                                            context.push(
                                              '/add-edit-work',
                                              extra: {
                                                'isNew': false,
                                                'editingTrip': trip,
                                                'editingWork': work,
                                                'editingLabours':
                                                    null, // Need to load them in details, or we can just push trip details!
                                              },
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.errorColor,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _confirmDelete(context, trip.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Navigate to Trip Details where it fully loads labours
                                    context.push('/trip-details', extra: trip);
                                  },
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  int _compareDates(String dateA, String dateB) {
    try {
      final a = DateTimeUtils.parseDate(dateA);
      final b = DateTimeUtils.parseDate(dateB);
      return a.compareTo(b);
    } catch (_) {
      return dateA.compareTo(dateB);
    }
  }

  void _confirmDelete(BuildContext context, String tripId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurfaceColor,
        title: const Text(
          'Delete Trip?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this trip?',
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
              final workBloc = context.read<WorkBloc>();
              final historyBloc = context.read<HistoryBloc>();
              workBloc.add(DeleteSpecificTripEvent(tripId));
              Navigator.pop(ctx);
              // Wait a bit and refresh history
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                historyBloc.add(LoadHistoryEvent());
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
