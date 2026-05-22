import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final date = DateTimeUtils.getCurrentDateFormatted();
    final session = DateTimeUtils.getCurrentSession();
    context.read<WorkBloc>().add(LoadDashboardDataEvent(date, session));
  }

  void _confirmDeleteTrip(Trip trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurfaceColor,
          title: const Text('Delete Trip?', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete Trip #${trip.tripNumber}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
              onPressed: () {
                context.read<WorkBloc>().add(DeleteSpecificTripEvent(trip.id));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search driver or tractor...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('Work Details'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<WorkBloc, WorkState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            final filteredTrips = state.currentTrips.where((trip) {
              return trip.driverName.toLowerCase().contains(_searchQuery) ||
                     trip.tractor.toLowerCase().contains(_searchQuery);
            }).toList();

            if (filteredTrips.isEmpty) {
              return const Center(
                child: Text(
                  'No trips found.',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderStats(state),
                const SizedBox(height: 24),
                _buildTripsTable(filteredTrips),
              ],
            );
          } else if (state is WorkLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          return const Center(
            child: Text(
              'No data found.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(DashboardLoaded state) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Date', state.currentWork?.date ?? 'N/A'),
          _buildStat('Session', state.currentWork?.session ?? 'N/A'),
          _buildStat('Trips', '${state.currentTrips.length}'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTripsTable(List<Trip> trips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return Dismissible(
              key: Key(trip.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                _confirmDeleteTrip(trip);
                return false;
              },
              child: GestureDetector(
                onTap: () => context.push('/trip-details', extra: trip),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateTimeUtils.formatTime(trip.createdAt),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right, color: Colors.white54),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
