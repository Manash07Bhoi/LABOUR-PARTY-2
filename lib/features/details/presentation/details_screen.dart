import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/theme/app_theme.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  void initState() {
    super.initState();
    final date = DateTimeUtils.getCurrentDateFormatted();
    final session = DateTimeUtils.getCurrentSession();
    context.read<WorkBloc>().add(LoadDashboardDataEvent(date, session));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Details'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<WorkBloc, WorkState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            if (state.currentTrips.isEmpty) {
              return const Center(
                child: Text(
                  'No trips available for details.',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderStats(state),
                const SizedBox(height: 24),
                _buildTripsTable(state),
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

  Widget _buildTripsTable(DashboardLoaded state) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppTheme.primaryColor.withAlpha(51),
          ),
          columnSpacing: 24,
          columns: const [
            DataColumn(
              label: Text(
                'Trip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Tractor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Driver',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: state.currentTrips.map((trip) {
            return DataRow(
              cells: [
                DataCell(Text('#${trip.tripNumber}')),
                DataCell(Text(DateTimeUtils.formatTime(trip.createdAt))),
                DataCell(Text(trip.tractor)),
                DataCell(Text(trip.driverName)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
