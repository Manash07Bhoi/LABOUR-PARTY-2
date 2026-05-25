import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/features/work/presentation/screens/add_edit_work_screen.dart';
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
              final state = context.read<WorkBloc>().state;
              if (state is TripDetailsLoaded) {
                final labourModels = state.tripLabours.map((tl) {
                  final labour = state.labours.firstWhere(
                    (l) => l.id == tl.labourId,
                    orElse: () => Labour(
                      id: '',
                      name: 'Unknown',
                      createdAt: DateTime.now(),
                    ),
                  );
                  return LabourFormModel(
                    labourId: labour.id,
                    name: labour.name,
                    isPresent: tl.isPresent,
                  );
                }).toList();

                context.push(
                  '/add-edit-work',
                  extra: {
                    'isNew': false,
                    'editingTrip': widget.trip,
                    'editingWork': state.work, // Passed from state
                    'editingLabours': labourModels,
                  },
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddLabourDialog(),
          ),
        ],
      ),
      body: BlocBuilder<WorkBloc, WorkState>(
        buildWhen: (previous, current) =>
            current is TripDetailsLoaded ||
            current is WorkLoading ||
            current is WorkInitial ||
            current is WorkError,
        builder: (context, state) {
          return switch (state) {
            WorkLoading() || WorkInitial() => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            NavigateToConfirmNextTripState() => const SizedBox.shrink(),
            WorkActionSuccess() => const SizedBox.shrink(),
            DashboardLoaded() => const SizedBox.shrink(),
            WorkEmpty() => const Center(child: Text('No details')),
            WorkError() => const Center(child: Text('Error loading details')),
            TripDetailsLoaded(
              tripLabours: final tripLabours,
              labours: final allLabours,
              work: final work,
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
                        _buildInfoRow(
                          'Tractor',
                          widget.trip.tractor.isNotEmpty
                              ? widget.trip.tractor
                              : 'Not specified',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Driver',
                          widget.trip.driverName.isNotEmpty
                              ? widget.trip.driverName
                              : 'Not specified',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Time',
                          DateTimeUtils.formatTime(widget.trip.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Status',
                          widget.trip.status.isNotEmpty
                              ? widget.trip.status
                              : 'Not specified',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Work Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Work Date', work?.date ?? 'Unknown'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Session', work?.session ?? 'Unknown'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Place',
                          widget.trip.place.isNotEmpty
                              ? widget.trip.place
                              : 'Not specified',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Work Type',
                          widget.trip.workType.isNotEmpty
                              ? widget.trip.workType
                              : 'Not specified',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Notes',
                          widget.trip.notes.isNotEmpty
                              ? widget.trip.notes
                              : 'Not specified',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Created At',
                          DateTimeUtils.formatTime(widget.trip.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Last Modified',
                          DateTimeUtils.formatTime(widget.trip.updatedAt),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Duration',
                          '${widget.trip.updatedAt.difference(widget.trip.createdAt).inMinutes} mins',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Labour Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total: ${tripLabours.length} | Present: ${tripLabours.where((t) => t.isPresent).length}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  final labour = allLabours.firstWhere(
                                    (l) => l.id == entry.value.labourId,
                                  );
                                  editLabourDialog(labour);
                                },
                              ),
                              Switch(
                                value: entry.value.isPresent,
                                activeTrackColor: AppTheme.successColor
                                    .withAlpha(100),
                                // ignore: deprecated_member_use
                                activeColor: AppTheme.successColor,
                                onChanged: (val) {
                                  final updated = TripLabour(
                                    id: entry.value.id,
                                    tripId: entry.value.tripId,
                                    labourId: entry.value.labourId,
                                    isPresent: val,
                                  );
                                  context.read<WorkBloc>().add(
                                    UpdateTripLabourEvent(tripLabour: updated),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppTheme.errorColor,
                                ),
                                onPressed: () {
                                  // Soft delete -> hard delete logic
                                  // PRD says: "Delete rules: if persisted: soft delete -> save. if unsaved: remove immediately"
                                  // For inline, all are persisted. So we first soft-delete, or if they click remove, we can hard-delete with an Undo snackbar.
                                  // Let's hard-delete with undo. Wait, "undo remove" is required.
                                  final tl = entry.value;
                                  context.read<WorkBloc>().add(
                                    DeleteTripLabourEvent(
                                      id: tl.id,
                                      tripId: tl.tripId,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Labour removed'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          final labour = allLabours.firstWhere(
                                            (l) => l.id == tl.labourId,
                                          );
                                          context.read<WorkBloc>().add(
                                            SaveTripLabourEvent(
                                              tripLabour: tl,
                                              labour: labour,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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
            WorkEmpty() => const SizedBox.shrink(),
            DashboardLoaded() => const SizedBox.shrink(),
            NavigateToConfirmNextTripState() => const SizedBox.shrink(),
            WorkActionSuccess() => const SizedBox.shrink(),
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
