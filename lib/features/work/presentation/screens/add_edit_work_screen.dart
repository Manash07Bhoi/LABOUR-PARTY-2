import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/shared/widgets/custom_text_field.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/shared/widgets/premium_button.dart';
import 'package:labour_party/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class AddEditWorkScreen extends StatefulWidget {
  final bool isNew;
  const AddEditWorkScreen({super.key, this.isNew = true});

  @override
  State<AddEditWorkScreen> createState() => _AddEditWorkScreenState();
}

class _AddEditWorkScreenState extends State<AddEditWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _date;
  late String _session;

  final _workTypeController = TextEditingController(text: 'Sand (Bali)');
  final _placeController = TextEditingController();
  final _tractorController = TextEditingController(text: 'Sonalika');
  final _driverController = TextEditingController();

  final List<TripLabour> _currentLabours = [];
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _date = DateTimeUtils.getCurrentDateFormatted();
    _session = DateTimeUtils.getCurrentSession();
    _loadInitialData();
  }

  void _loadInitialData() {
    final state = context.read<WorkBloc>().state;
    if (state is DashboardLoaded) {
      if (state.currentWork != null) {
        _workTypeController.text = state.currentWork!.workType;
        _placeController.text = state.currentWork!.place;
      }
      if (state.currentTrips.isNotEmpty) {
        final lastTrip = state.currentTrips.last;
        _tractorController.text = lastTrip.tractor;
        _driverController.text = lastTrip.driverName;
      }
    }
  }

  void _addLabour() {
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
                  setState(() {
                    _currentLabours.add(
                      TripLabour(
                        id: _uuid.v4(),
                        tripId: '',
                        labourId: _uuid.v4(),
                        isPresent: true,
                      ),
                    );
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text(
                'Add',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveWork() {
    if (_formKey.currentState!.validate()) {
      if (_currentLabours.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('At least one labour is required.')),
        );
        return;
      }

      final workBloc = context.read<WorkBloc>();
      final state = workBloc.state;

      Work? existingWork;

      if (state is DashboardLoaded) {
        existingWork = state.currentWork;
      }

      final workId = existingWork?.id ?? _uuid.v4();
      final tripId = _uuid.v4();

      final newWork = Work(
        id: workId,
        date: _date,
        session: _session,
        workType: _workTypeController.text,
        place: _placeController.text,
        createdAt: existingWork?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newTrip = Trip(
        id: tripId,
        workId: workId,
        tripNumber: 0, // Assigned properly inside BLoC via UseCase
        tractor: _tractorController.text,
        driverName: _driverController.text,
        createdAt: DateTime.now(),
      );

      final finalLabours = _currentLabours
          .map(
            (l) => TripLabour(
              id: l.id,
              tripId: tripId,
              labourId: l.labourId,
              isPresent: l.isPresent,
            ),
          )
          .toList();

      workBloc.add(
        SaveFullWorkTripEvent(
          work: newWork,
          trip: newTrip,
          tripLabours: finalLabours,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Trip'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<WorkBloc, WorkState>(
        listener: (context, state) {
          if (state is WorkActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trip Saved Successfully!')),
            );
            context.pop();
          } else if (state is WorkError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderInfo(),
                const SizedBox(height: 24),
                _buildWorkInfoSection(),
                const SizedBox(height: 24),
                _buildTripInfoSection(),
                const SizedBox(height: 24),
                _buildLabourListSection(),
                const SizedBox(height: 32),
                PremiumButton(
                  text: 'Save Trip',
                  icon: Icons.save,
                  onPressed: _saveWork,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                _date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Session',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                _session,
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Work Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Work Type *',
          controller: _workTypeController,
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Place (Optional)',
          controller: _placeController,
        ),
      ],
    );
  }

  Widget _buildTripInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTractorSelection(),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Driver Name *',
          controller: _driverController,
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTractorSelection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tractorController.text = 'Sonalika'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _tractorController.text == 'Sonalika'
                    ? AppTheme.primaryColor
                    : AppTheme.darkSurfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _tractorController.text == 'Sonalika'
                      ? Colors.transparent
                      : Colors.white24,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Sonalika',
                style: TextStyle(
                  color: _tractorController.text == 'Sonalika'
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tractorController.text = 'JohnDeere'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _tractorController.text == 'JohnDeere'
                    ? AppTheme.primaryColor
                    : AppTheme.darkSurfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _tractorController.text == 'JohnDeere'
                      ? Colors.transparent
                      : Colors.white24,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'JohnDeere',
                style: TextStyle(
                  color: _tractorController.text == 'JohnDeere'
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabourListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Labour List *',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _addLabour,
              icon: const Icon(Icons.person_add, color: AppTheme.accentColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_currentLabours.isEmpty)
          const Text(
            'No labours added. Please add at least one.',
            style: TextStyle(color: AppTheme.errorColor, fontSize: 14),
          ),
        ..._currentLabours.asMap().entries.map((entry) {
          int idx = entry.key;
          TripLabour tl = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkSurfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: tl.isPresent
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  width: 4,
                ),
              ),
            ),
            child: ListTile(
              title: Text(
                'Labour ${idx + 1}',
                style: TextStyle(
                  color: tl.isPresent ? Colors.white : Colors.white54,
                  decoration: tl.isPresent ? null : TextDecoration.lineThrough,
                ),
              ),
              subtitle: !tl.isPresent
                  ? const Text(
                      'Not working this trip',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                      ),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: tl.isPresent,
                    activeTrackColor: AppTheme.successColor.withAlpha(100),
                    // ignore: deprecated_member_use
                    activeColor: AppTheme.successColor,
                    onChanged: (val) {
                      setState(() {
                        _currentLabours[idx] = TripLabour(
                          id: tl.id,
                          tripId: tl.tripId,
                          labourId: tl.labourId,
                          isPresent: val,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppTheme.errorColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentLabours.removeAt(idx);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
