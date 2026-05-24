import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocBuilder<WorkBloc, WorkState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Metric',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Value',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Total Trips',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${state.totalTrips}',
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Total Labours',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${state.totalLabourCount}',
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        },
      ),
    );
  }
}
