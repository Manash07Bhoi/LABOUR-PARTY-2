import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/shared/widgets/custom_text_field.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/shared/widgets/premium_button.dart';
import 'package:labour_party/theme/app_theme.dart';

class LabourFormModel {
  final String labourId;
  final String name;
  bool isPresent;
  LabourFormModel({
    required this.labourId,
    required this.name,
    this.isPresent = true,
  });
}

class ConfirmNextTripScreen extends StatefulWidget {
  final Work work;
  final int nextTripNumber;
  final List<LabourFormModel> previousLabours;
  final String place;
  final String workType;

  const ConfirmNextTripScreen({
    super.key,
    required this.work,
    required this.nextTripNumber,
    required this.previousLabours,
    required this.place,
    required this.workType,
  });

  @override
  State<ConfirmNextTripScreen> createState() => _ConfirmNextTripScreenState();
}

class _ConfirmNextTripScreenState extends State<ConfirmNextTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tractorController = TextEditingController();
  final _driverController = TextEditingController();
  final _placeController = TextEditingController();
  final _notesController = TextEditingController();
  String _workType = 'Sand (Bali)';
  late List<LabourFormModel> _labours;

  @override
  void initState() {
    super.initState();
    _labours = widget.previousLabours
        .map(
          (l) => LabourFormModel(
            labourId: l.labourId,
            name: l.name,
            isPresent: l.isPresent,
          ),
        )
        .toList();
    _placeController.text = widget.place;
    _workType = widget.workType;
  }

  @override
  void dispose() {
    _tractorController.dispose();
    _driverController.dispose();
    _placeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newTripId = const Uuid().v4();
      final newTrip = Trip(
        id: newTripId,
        workId: widget.work.id,
        tripNumber: widget.nextTripNumber,
        tractor: _tractorController.text.trim(),
        driverName: _driverController.text.trim(),
        createdAt: DateTime.now(),
        place: _placeController.text.trim(),
        workType: _workType,
        notes: _notesController.text.trim(),
      );

      // Clone collections as requested (map creates a new iterable/list)
      final newTripLabours = _labours
          .map(
            (l) => TripLabour(
              id: const Uuid().v4(),
              tripId: newTripId,
              labourId: l.labourId,
              isPresent: l.isPresent,
            ),
          )
          .toList();

      context.read<WorkBloc>().add(
        SaveNextTripEvent(trip: newTrip, tripLabours: newTripLabours),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Next Trip')),
      body: BlocListener<WorkBloc, WorkState>(
        listener: (context, state) {
          if (state is WorkActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trip added successfully')),
            );
            context.read<WorkBloc>().add(
              LoadDashboardDataEvent(widget.work.date, widget.work.session),
            );
          } else if (state is WorkError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Trip Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Work Date: ${widget.work.date}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Session: ${widget.work.session}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Trip #: ${widget.nextTripNumber}',
                      style: const TextStyle(color: Colors.white70),
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
                      'Trip Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _tractorController,
                      label: 'Tractor (e.g., Sonalika, JohnDeere)',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _driverController,
                      label: 'Driver Name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _workType,
                      dropdownColor: AppTheme.darkSurfaceColor,
                      decoration: const InputDecoration(
                        labelText: 'Work Type',
                        prefixIcon: Icon(
                          Icons.category,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      items: ['Sand (Bali)', 'Soil', 'Stone', 'Custom'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _workType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _placeController,
                      label: 'Place / Location',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _notesController,
                      label: 'Notes',
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
                      'Labour & Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_labours.isEmpty)
                      const Text(
                        'No labours available',
                        style: TextStyle(color: Colors.white54),
                      )
                    else
                      ..._labours.map((l) {
                        return SwitchListTile(
                          title: Text(
                            l.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            l.isPresent ? 'Present' : 'Absent',
                            style: TextStyle(
                              color: l.isPresent
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                          ),
                          value: l.isPresent,
                          onChanged: (val) {
                            setState(() {
                              l.isPresent = val;
                            });
                          },
                          activeColor: AppTheme.successColor,
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PremiumButton(
                onPressed: _onSave,
                text: 'Save as Next Trip',
                icon: Icons.check_circle,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
