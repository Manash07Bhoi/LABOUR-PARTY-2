import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/theme/app_theme.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip #${trip.tripNumber}'),
      ),
      body: FutureBuilder<List<TripLabour>>(
        future: context.read<WorkBloc>().getLaboursForTrip(trip.id).then((value) => value.fold((l) => [], (r) => r)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          final labours = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trip Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Tractor', trip.tractor),
                    const SizedBox(height: 8),
                    _buildInfoRow('Driver', trip.driverName),
                    const SizedBox(height: 8),
                    _buildInfoRow('Time', DateTimeUtils.formatTime(trip.createdAt)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Labour Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              if (labours.isEmpty)
                const Text('No labours assigned to this trip', style: TextStyle(color: Colors.white54))
              else
                ...labours.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: entry.value.isPresent ? AppTheme.successColor : AppTheme.errorColor,
                          width: 4,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        'Labour ${entry.key + 1}',
                        style: TextStyle(
                          color: entry.value.isPresent ? Colors.white : Colors.white54,
                          decoration: entry.value.isPresent ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      trailing: Icon(
                        entry.value.isPresent ? Icons.check_circle : Icons.cancel,
                        color: entry.value.isPresent ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
