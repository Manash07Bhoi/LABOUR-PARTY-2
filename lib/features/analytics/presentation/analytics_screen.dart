import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/history_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/history_event.dart';
import 'package:labour_party/features/work/presentation/bloc/history_state.dart';
import 'package:labour_party/shared/widgets/empty_state.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _sortColumnIndex = 0;
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    // Use the data already in HistoryBloc to avoid extra hive calls
    context.read<HistoryBloc>().add(LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
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
              icon: Icons.analytics,
              message: 'No data to analyze',
              ctaText: '',
              onCtaPressed: () {},
            );
          } else if (state is HistoryLoaded) {
            // Aggregate once
            int totalWorks = state.worksMap.length;
            int totalTrips = 0;
            Map<String, int> driverRanking = {};
            Map<String, int> tractorUsage = {};

            List<Map<String, dynamic>> flatTrips = [];

            for (var dateEntry in state.groupedTrips.entries) {
              for (var sessionEntry in dateEntry.value.entries) {
                totalTrips += sessionEntry.value.length;
                for (var trip in sessionEntry.value) {
                  driverRanking[trip.driverName] =
                      (driverRanking[trip.driverName] ?? 0) + 1;
                  tractorUsage[trip.tractor] =
                      (tractorUsage[trip.tractor] ?? 0) + 1;
                  flatTrips.add({
                    'date': dateEntry.key,
                    'session': sessionEntry.key,
                    'tripNumber': trip.tripNumber,
                    'driver': trip.driverName,
                    'tractor': trip.tractor,
                    // Note: Labours are not eagerly loaded for all trips to save memory,
                    // PRD constraint: "No nested Hive reads". We will show what is available.
                  });
                }
              }
            }

            final driverEntries = driverRanking.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final topDriver = driverEntries.isNotEmpty
                ? driverEntries.first.key
                : 'N/A';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildKPIs(totalWorks, totalTrips, topDriver),
                const SizedBox(height: 24),
                const Text(
                  'Data Table',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDataTable(flatTrips),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildKPIs(int works, int trips, String topDriver) {
    return Row(
      children: [
        Expanded(child: _buildKPICard('Works', works.toString(), Icons.work)),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKPICard('Trips', trips.toString(), Icons.local_shipping),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildKPICard('Top Driver', topDriver, Icons.person)),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> flatTrips) {
    if (_sortColumnIndex == 0) {
      flatTrips.sort(
        (a, b) => _isAscending
            ? a['date'].compareTo(b['date'])
            : b['date'].compareTo(a['date']),
      );
    } else if (_sortColumnIndex == 1) {
      flatTrips.sort(
        (a, b) => _isAscending
            ? a['session'].compareTo(b['session'])
            : b['session'].compareTo(a['session']),
      );
    } else if (_sortColumnIndex == 2) {
      flatTrips.sort(
        (a, b) => _isAscending
            ? a['tripNumber'].compareTo(b['tripNumber'])
            : b['tripNumber'].compareTo(a['tripNumber']),
      );
    } else if (_sortColumnIndex == 3) {
      flatTrips.sort(
        (a, b) => _isAscending
            ? a['driver'].compareTo(b['driver'])
            : b['driver'].compareTo(a['driver']),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _isAscending,
          headingTextStyle: const TextStyle(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.bold,
          ),
          columns: [
            DataColumn(
              label: const Text('Date'),
              onSort: (idx, asc) => setState(() {
                _sortColumnIndex = idx;
                _isAscending = asc;
              }),
            ),
            DataColumn(
              label: const Text('Session'),
              onSort: (idx, asc) => setState(() {
                _sortColumnIndex = idx;
                _isAscending = asc;
              }),
            ),
            DataColumn(
              label: const Text('Trip'),
              numeric: true,
              onSort: (idx, asc) => setState(() {
                _sortColumnIndex = idx;
                _isAscending = asc;
              }),
            ),
            DataColumn(
              label: const Text('Driver'),
              onSort: (idx, asc) => setState(() {
                _sortColumnIndex = idx;
                _isAscending = asc;
              }),
            ),
            const DataColumn(label: Text('Tractor')),
          ],
          rows: flatTrips.map((row) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    row['date'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    row['session'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    '#${row['tripNumber']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    row['driver'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    row['tractor'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
