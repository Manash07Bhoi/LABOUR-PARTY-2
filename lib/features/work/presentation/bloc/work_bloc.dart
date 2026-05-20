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
  }) : super(WorkInitial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<AddQuickTripEvent>(_onAddQuickTrip);
    on<RemoveLatestTripEvent>(_onRemoveLatestTrip);
    on<SaveFullWorkTripEvent>(_onSaveFullWorkTrip);
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
      int nextTripNumber = 1;

      // To find the absolute next trip number, we check the highest trip number of the day across both sessions
      int highestMorningTrip = 0;
      int highestEveningTrip = 0;

      final morningWorkResult = await getWorkByDateAndSession(
        event.date,
        'Morning',
      );
      await morningWorkResult.fold((f) async {}, (w) async {
        final tResult = await getTripsForWork(w.id);
        tResult.fold((f) {}, (trips) {
          if (trips.isNotEmpty) {
            highestMorningTrip = trips
                .map((t) => t.tripNumber)
                .reduce((a, b) => a > b ? a : b);
          }
        });
      });

      final eveningWorkResult = await getWorkByDateAndSession(
        event.date,
        'Evening',
      );
      await eveningWorkResult.fold((f) async {}, (w) async {
        final tResult = await getTripsForWork(w.id);
        tResult.fold((f) {}, (trips) {
          if (trips.isNotEmpty) {
            highestEveningTrip = trips
                .map((t) => t.tripNumber)
                .reduce((a, b) => a > b ? a : b);
          }
        });
      });

      nextTripNumber =
          (highestEveningTrip > highestMorningTrip
              ? highestEveningTrip
              : highestMorningTrip) +
          1;

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

      // Try to find the absolute last trip of the day to copy data from
      Trip? lastTripToCopy;

      if (currentState.currentTrips.isNotEmpty) {
        // If there are trips in the current session, use the last one
        lastTripToCopy = currentState.currentTrips.last;
      } else if (event.session == 'Evening') {
        // If it's the evening session and there are no trips yet, try to get the last trip from the morning session
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

  Future<void> _onSaveFullWorkTrip(
    SaveFullWorkTripEvent event,
    Emitter<WorkState> emit,
  ) async {
    emit(WorkLoading());
    await saveWork(event.work);
    await saveTrip(event.trip);
    for (var tl in event.tripLabours) {
      await saveTripLabour(tl);
    }
    emit(WorkActionSuccess());
    add(LoadDashboardDataEvent(event.work.date, event.work.session));
  }
}
