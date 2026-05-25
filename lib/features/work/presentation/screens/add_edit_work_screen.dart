import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:labour_party/core/database/hive_setup.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';
import 'package:labour_party/features/work/data/models/draft_model.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/shared/widgets/custom_text_field.dart';
import 'package:labour_party/shared/widgets/glass_card.dart';
import 'package:labour_party/shared/widgets/premium_button.dart';
import 'package:labour_party/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

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

class AddEditWorkScreen extends StatefulWidget {
  final bool isNew;
  final Trip? editingTrip;
  final Work? editingWork;
  final List<LabourFormModel>? editingLabours;
  const AddEditWorkScreen({
    super.key,
    this.isNew = true,
    this.editingTrip,
    this.editingWork,
    this.editingLabours,
  });

  @override
  State<AddEditWorkScreen> createState() => _AddEditWorkScreenState();
}

class _AddEditWorkScreenState extends State<AddEditWorkScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late String _date;
  late String _session;

  final _workTypeController = TextEditingController(text: 'Sand (Bali)');
  final _placeController = TextEditingController();
  final _tractorController = TextEditingController(text: 'Sonalika');
  final _driverController = TextEditingController();

  final List<LabourFormModel> _currentLabours = [];
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.editingWork != null) {
      _date = widget.editingWork!.date;
      _session = widget.editingWork!.session;
      _workTypeController.text = widget.editingWork!.workType;
      _placeController.text = widget.editingWork!.place;
    } else {
      if (widget.editingTrip != null) {
        throw Exception(
          "editingWork must be provided when editingTrip is provided to preserve date isolation.",
        );
      }
      _date = DateTimeUtils.getCurrentDateFormatted();
      _session = DateTimeUtils.getCurrentSession();
    }

    if (widget.editingTrip != null) {
      _tractorController.text = widget.editingTrip!.tractor;
      _driverController.text = widget.editingTrip!.driverName;
    }

    _loadInitialData();
    WidgetsBinding.instance.addObserver(this);
    _checkDraft();
    _workTypeController.addListener(_saveDraft);
    _placeController.addListener(_saveDraft);
    _tractorController.addListener(_saveDraft);
    _driverController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _workTypeController.dispose();
    _placeController.dispose();
    _tractorController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveDraft();
    }
  }

  void _saveDraft() {
    if (widget.editingTrip != null) return; // Only save draft for new trips
    final box = Hive.box<DraftModel>(HiveSetup.draftBox);
    final encodedLabours = jsonEncode(
      _currentLabours
          .map(
            (l) => {
              'labourId': l.labourId,
              'name': l.name,
              'isPresent': l.isPresent,
            },
          )
          .toList(),
    );
    final draft = DraftModel(
      date: _date,
      session: _session,
      workType: _workTypeController.text,
      place: _placeController.text,
      tractor: _tractorController.text,
      driverName: _driverController.text,
      encodedLabours: encodedLabours,
    );
    box.put('current_draft', draft);
  }

  void _clearDraft() {
    final box = Hive.box<DraftModel>(HiveSetup.draftBox);
    box.delete('current_draft');
  }

  void _checkDraft() {
    if (widget.editingTrip != null) return;
    final box = Hive.box<DraftModel>(HiveSetup.draftBox);
    final draft = box.get('current_draft');
    if (draft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You have an unsaved draft.'),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Restore',
              onPressed: () {
                setState(() {
                  _date = draft.date;
                  _session = draft.session;
                  _workTypeController.text = draft.workType;
                  _placeController.text = draft.place;
                  _tractorController.text = draft.tractor;
                  _driverController.text = draft.driverName;
                  try {
                    final decoded = jsonDecode(draft.encodedLabours) as List;
                    _currentLabours.clear();
                    _currentLabours.addAll(
                      decoded.map(
                        (e) => LabourFormModel(
                          labourId: e['labourId'],
                          name: e['name'],
                          isPresent: e['isPresent'],
                        ),
                      ),
                    );
                  } catch (_) {}
                });
              },
            ),
          ),
        );
      });
    }
  }

  void _loadInitialData() {
    if (widget.editingLabours != null) {
      _currentLabours.addAll(widget.editingLabours!);
    }
    final state = context.read<WorkBloc>().state;
    if (widget.editingTrip == null &&
        widget.editingWork == null &&
        state is DashboardLoaded) {
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
                      LabourFormModel(
                        labourId: _uuid.v4(),
                        name: nameCtrl.text,
                        isPresent: true,
                      ),
                    );
                    _saveDraft();
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

      _clearDraft();
      final workBloc = context.read<WorkBloc>();

      final String safeDateId = _date.replaceAll(' ', '_');
      final workId = widget.editingWork?.id ?? 'work_${safeDateId}_$_session';
      final tripId = widget.editingTrip?.id ?? _uuid.v4();

      final newWork = Work(
        id: workId,
        date: _date,
        session: _session,
        workType: _workTypeController.text,
        place: _placeController.text,
        createdAt: widget.editingWork?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newTrip = Trip(
        id: tripId,
        workId: workId,
        tripNumber: widget.editingTrip?.tripNumber ?? 0,
        tractor: _tractorController.text,
        driverName: _driverController.text,
        createdAt: widget.editingTrip?.createdAt ?? DateTime.now(),
      );

      final finalLabours = _currentLabours
          .map(
            (l) => TripLabour(
              id: _uuid.v4(),
              tripId: tripId,
              labourId: l.labourId,
              isPresent: l.isPresent,
            ),
          )
          .toList();

      final realLabours = _currentLabours
          .map<Labour>(
            (l) =>
                Labour(id: l.labourId, name: l.name, createdAt: DateTime.now()),
          )
          .toList();

      workBloc.add(
        SaveFullWorkTripEvent(
          work: newWork,
          trip: newTrip,
          tripLabours: finalLabours,
          labours: realLabours,
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
          onPressed: () {
            _saveDraft();
            context.pop();
          },
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
          LabourFormModel tl = entry.value;
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
                tl.name,
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
                        _currentLabours[idx].isPresent = val;
                        _saveDraft();
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
                        _saveDraft();
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
