import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:labour_party/shared/widgets/custom_text_field.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final Uuid _uuid = const Uuid();

  void _showAddLabourDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.darkSurfaceColor,
          title: const Text(
            'Add Labour',
            style: TextStyle(color: Colors.white),
          ),
          content: CustomTextField(
            label: 'Labour Name',
            controller: nameCtrl,
            hint: 'Enter name',
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
                if (nameCtrl.text.isNotEmpty) {
                  final newLabour = Labour(
                    id: _uuid.v4(),
                    name: nameCtrl.text,
                    createdAt: DateTime.now(),
                  );
                  final newTripLabour = TripLabour(
                    id: _uuid.v4(),
                    tripId: widget.trip.id,
                    labourId: newLabour.id,
                    isPresent: true,
                  );
                  context.read<WorkBloc>().add(
                    SaveTripLabourEvent(
                      tripLabour: newTripLabour,
                      labour: newLabour,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void editLabourDialog(Labour labour) {
    showDialog(
      context: context,
      builder: (ctx) {
        final nameCtrl = TextEditingController(text: labour.name);
        return AlertDialog(
          backgroundColor: AppTheme.darkSurfaceColor,
          title: const Text(
            'Edit Labour',
            style: TextStyle(color: Colors.white),
          ),
          content: CustomTextField(
            label: 'Labour Name',
            controller: nameCtrl,
            hint: 'Enter name',
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
                if (nameCtrl.text.isNotEmpty) {
                  final updatedLabour = Labour(
                    id: labour.id,
                    name: nameCtrl.text,
                    createdAt: labour.createdAt,
                  );
                  context.read<WorkBloc>().add(
                    SaveLabourEvent(labour: updatedLabour),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<WorkBloc>().add(LoadTripDetailsEvent(widget.trip.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip #${widget.trip.tripNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit trip requires work object! Let's fetch it via BLoC? No, we can just push to AddEdit.
              // Wait, AddEditWorkScreen requires the Work object?
              // The user said "Edit Trip" from this screen.
              context.push(
                '/add-edit-work',
                extra: {
                  'isNew': false,
                  'editingTrip': widget.trip,
                  'editingWork': null,
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddLabourDialog(),
          ),
        ],
      ),
      body: BlocBuilder<WorkBloc, WorkState>(
        builder: (context, state) {
          return switch (state) {
            WorkLoading() || WorkInitial() => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            TripDetailsLoaded(
              tripLabours: final tripLabours,
              labours: final allLabours,
            ) =>
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trip Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Tractor', widget.trip.tractor),
                        const SizedBox(height: 8),
                        _buildInfoRow('Driver', widget.trip.driverName),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Time',
                          DateTimeUtils.formatTime(widget.trip.createdAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Labour Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (tripLabours.isEmpty)
                    const Text(
                      'No labours assigned to this trip',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ...tripLabours.asMap().entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              color: entry.value.isPresent
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              width: 4,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            allLabours
                                .firstWhere(
                                  (l) => l.id == entry.value.labourId,
                                  orElse: () => Labour(
                                    id: '',
                                    name: 'Unknown Labour',
                                    createdAt: DateTime.now(),
                                  ),
                                )
                                .name,
                            style: TextStyle(
                              color: entry.value.isPresent
                                  ? Colors.white
                                  : Colors.white54,
                              decoration: entry.value.isPresent
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          trailing: Icon(
                            entry.value.isPresent
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: entry.value.isPresent
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      );
                    }),
                ],
              ),
            WorkError(message: final message) => Center(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ),
            WorkEmpty() ||
            DashboardLoaded() ||
            WorkActionSuccess() => const Center(
              child: Text(
                'Unexpected state in TripDetails',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          };
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
