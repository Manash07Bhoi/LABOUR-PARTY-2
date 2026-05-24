import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/shared/widgets/empty_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work History')),
      body: BlocBuilder<WorkBloc, WorkState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            // Group trips by date here conceptually
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Historical Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...state.currentTrips.map(
                  (trip) => ListTile(
                    title: Text(
                      'Trip #${trip.tripNumber} - ${trip.driverName}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      trip.tractor,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                    ),
                    onTap: () => context.push('/trip-details', extra: trip),
                  ),
                ),
              ],
            );
          }
          return EmptyStateWidget(
            icon: Icons.history,
            message: 'No history found',
            ctaText: '',
            onCtaPressed: () {},
          );
        },
      ),
    );
  }
}
