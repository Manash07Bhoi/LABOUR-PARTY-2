import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:uuid/uuid.dart';

class WorkBloc extends Bloc<WorkEvent, WorkState> {
  final GetWorksUseCase getWorks;
  final GetWorkByDateAndSessionUseCase getWorkByDateAndSession;
  final SaveWorkUseCase saveWork;
  final GetTripsForWorkUseCase getTripsForWork;
  final SaveTripUseCase saveTrip;
  final DeleteTripUseCase deleteTrip;
  final GetLaboursForTripUseCase getLaboursForTrip;
  final SaveTripLabourUseCase saveTripLabour;
  final CalculateNextTripNumberUseCase calculateNextTripNumber;
  final Uuid uuid = const Uuid();

  WorkBloc({
    required this.getWorks,
    required this.getWorkByDateAndSession,
    required this.saveWork,
    required this.getTripsForWork,
    required this.saveTrip,
    required this.deleteTrip,
    required this.getLaboursForTrip,
    required this.saveTripLabour,
    required this.calculateNextTripNumber,
  }) : super(WorkInitial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<AddQuickTripEvent>(_onAddQuickTrip);
    on<RemoveLatestTripEvent>(_onRemoveLatestTrip);
    on<DeleteSpecificTripEvent>(_onDeleteSpecificTrip);
    on<SaveFullWorkTripEvent>(_onSaveFullWorkTrip);
    on<LoadTripDetailsEvent>(_onLoadTripDetails);
  }

  Future<int> _getNextTripNum(String date) async {
    final result = await calculateNextTripNumber(date);
    return result.fold((l) => 1, (r) => r);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<WorkState> emit,
  ) async {
    emit(WorkLoading());

    final workResult = await getWorkByDateAndSession(event.date, event.session);
    Work? currentWork;
    List<Trip> currentTrips = [];
    int currentTotalLabourCount = 0;

    await workResult.fold((failure) async {}, (work) async {
      currentWork = work;
      final tripsResult = await getTripsForWork(work.id);
      await tripsResult.fold((f) async {}, (trips) async {
        currentTrips = trips;
        for (var trip in trips) {
          final laboursResult = await getLaboursForTrip(trip.id);
          laboursResult.fold((f) {}, (labours) {
            currentTotalLabourCount += labours.where((l) => l.isPresent).length;
          });
        }
      });
    });

    int morningTripCount = 0;
    int eveningTripCount = 0;

    final morningWorkResult = await getWorkByDateAndSession(
      event.date,
      'Morning',
    );
    await morningWorkResult.fold((f) async {}, (w) async {
      final tResult = await getTripsForWork(w.id);
      tResult.fold((f) {}, (t) => morningTripCount = t.length);
    });

    final eveningWorkResult = await getWorkByDateAndSession(
      event.date,
      'Evening',
    );
    await eveningWorkResult.fold((f) async {}, (w) async {
      final tResult = await getTripsForWork(w.id);
      tResult.fold((f) {}, (t) => eveningTripCount = t.length);
    });

    int totalTrips = morningTripCount + eveningTripCount;

    if (currentWork == null && totalTrips == 0) {
      emit(const WorkEmpty("No work added today"));
    } else {
      emit(
        DashboardLoaded(
          currentWork: currentWork,
          currentTrips: currentTrips,
          totalLabourCount: currentTotalLabourCount,
          morningTripCount: morningTripCount,
          eveningTripCount: eveningTripCount,
          totalTrips: totalTrips,
        ),
      );
    }
  }

  Future<void> _onAddQuickTrip(
    AddQuickTripEvent event,
    Emitter<WorkState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(WorkLoading());

      Work work;
      int nextTripNumber = await _getNextTripNum(event.date);

      if (currentState.currentWork != null) {
        work = currentState.currentWork!;
      } else {
        work = Work(
          id: uuid.v4(),
          date: event.date,
          session: event.session,
          workType: 'Sand (Bali)',
          place: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveWork(work);
      }

      String tractor = '';
      String driverName = '';
      List<TripLabour> copiedLabours = [];

      Trip? lastTripToCopy;

      if (currentState.currentTrips.isNotEmpty) {
        lastTripToCopy = currentState.currentTrips.last;
      } else if (event.session == 'Evening') {
        final morningWorkResult = await getWorkByDateAndSession(event.date, 'Morning');
        await morningWorkResult.fold((f) async {}, (w) async {
          final tResult = await getTripsForWork(w.id);
          tResult.fold((f) {}, (trips) {
            if (trips.isNotEmpty) {
              lastTripToCopy = trips.last;
            }
          });
        });
      }

      if (lastTripToCopy != null) {
        tractor = lastTripToCopy!.tractor;
        driverName = lastTripToCopy!.driverName;

        final lastTripLaboursResult = await getLaboursForTrip(
          lastTripToCopy!.id,
        );
        lastTripLaboursResult.fold((f) {}, (labours) {
          copiedLabours = labours
              .map(
                (l) => TripLabour(
                  id: uuid.v4(),
                  tripId: '',
                  labourId: l.labourId,
                  isPresent: l.isPresent,
                ),
              )
              .toList();
        });
      }

      final newTrip = Trip(
        id: uuid.v4(),
        workId: work.id,
        tripNumber: nextTripNumber,
        tractor: tractor,
        driverName: driverName,
        createdAt: DateTime.now(),
      );

      await saveTrip(newTrip);

      for (var l in copiedLabours) {
        await saveTripLabour(
          TripLabour(
            id: l.id,
            tripId: newTrip.id,
            labourId: l.labourId,
            isPresent: l.isPresent,
          ),
        );
      }

      add(LoadDashboardDataEvent(event.date, event.session));
    }
  }

  Future<void> _onDeleteSpecificTrip(
    DeleteSpecificTripEvent event,
    Emitter<WorkState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(WorkLoading());
      await deleteTrip(event.tripId);
      if (currentState.currentWork != null) {
        add(
          LoadDashboardDataEvent(
            currentState.currentWork!.date,
            currentState.currentWork!.session,
          ),
        );
      }
    }
  }

  Future<void> _onRemoveLatestTrip(
    RemoveLatestTripEvent event,
    Emitter<WorkState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      if (currentState.currentTrips.isNotEmpty) {
        final lastTrip = currentState.currentTrips.last;
        emit(WorkLoading());
        await deleteTrip(lastTrip.id);
        if (currentState.currentWork != null) {
          add(
            LoadDashboardDataEvent(
              currentState.currentWork!.date,
              currentState.currentWork!.session,
            ),
          );
        }
      }
    }
  }

  Future<void> _onLoadTripDetails(
    LoadTripDetailsEvent event,
    Emitter<WorkState> emit,
  ) async {
    emit(WorkLoading());
    final result = await getLaboursForTrip(event.tripId);
    result.fold(
      (failure) => emit(const WorkError('Failed to load trip details')),
      (labours) => emit(TripDetailsLoaded(labours)),
    );
  }

  Future<void> _onSaveFullWorkTrip(
    SaveFullWorkTripEvent event,
    Emitter<WorkState> emit,
  ) async {
    emit(WorkLoading());

    int resolvedTripNumber = event.trip.tripNumber;
    if (resolvedTripNumber == 0) {
      resolvedTripNumber = await _getNextTripNum(event.work.date);
    }

    Trip finalTrip = Trip(
      id: event.trip.id,
      workId: event.trip.workId,
      tripNumber: resolvedTripNumber,
      tractor: event.trip.tractor,
      driverName: event.trip.driverName,
      createdAt: event.trip.createdAt,
    );

    await saveWork(event.work);
    await saveTrip(finalTrip);
    for (var tl in event.tripLabours) {
      await saveTripLabour(tl);
    }
    emit(WorkActionSuccess());
    add(LoadDashboardDataEvent(event.work.date, event.work.session));
  }
}
