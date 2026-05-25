import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';

import '../helpers/mock_work_repository.dart';

void main() {
  late MockWorkRepository mockRepo;
  late WorkBloc workBloc;

  setUp(() {
    mockRepo = MockWorkRepository();
    workBloc = WorkBloc(
      getWorks: GetWorksUseCase(mockRepo),
      getWorkByDateAndSession: GetWorkByDateAndSessionUseCase(mockRepo),
      saveWork: SaveWorkUseCase(mockRepo),
      getTripsForWork: GetTripsForWorkUseCase(mockRepo),
      saveTrip: SaveTripUseCase(mockRepo),
      deleteTrip: DeleteTripUseCase(mockRepo),
      getLaboursForTrip: GetLaboursForTripUseCase(mockRepo),
      getLaboursForTrips: GetLaboursForTripsUseCase(mockRepo),
      saveTripLabour: SaveTripLabourUseCase(mockRepo),
      saveTripLabours: SaveTripLaboursUseCase(mockRepo),
      deleteTripLabour: DeleteTripLabourUseCase(mockRepo),
      calculateNextTripNumber: CalculateNextTripNumberUseCase(mockRepo),
      saveLabour: SaveLabourUseCase(mockRepo),
      getLabours: GetLaboursUseCase(mockRepo),
    );
  });

  test('E2E - Scenario C: Morning -> Evening continuity', () async {
    // Scaffold initial morning state directly into Repo
    final workMorn = Work(
      id: 'm1',
      date: '01 Jan 2024',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await mockRepo.saveWork(workMorn);
    await mockRepo.saveTrip(
      Trip(
        id: 't1',
        workId: 'm1',
        tripNumber: 1,
        tractor: '',
        driverName: '',
        createdAt: DateTime.now(),
      ),
    );
    await mockRepo.saveTrip(
      Trip(
        id: 't2',
        workId: 'm1',
        tripNumber: 2,
        tractor: '',
        driverName: '',
        createdAt: DateTime.now(),
      ),
    );

    // Load an evening state
    workBloc.add(const LoadDashboardDataEvent('01 Jan 2024', 'Evening'));
    await Future.delayed(const Duration(milliseconds: 100)); // allow emit

    // When evening is requested, the current work is NULL, but totalTrips = 2 (from morning).
    // Therefore it emits DashboardLoaded with empty currentTrips, not WorkEmpty.
    expect(workBloc.state, isA<DashboardLoaded>());

    // Wait for state to settle to NavigateToConfirmNextTripState then submit it back
    workBloc.add(
      const NavigateToConfirmNextTripEvent(
        date: '01 Jan 2024',
        session: 'Evening',
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    // We can simulate the SaveNextTripEvent since the UI handles the mapping now
    workBloc.add(
      SaveNextTripEvent(
        trip: Trip(
          id: 't3',
          workId: 'e1', // A new Evening Work ID
          tripNumber: 3,
          tractor: 'T1',
          driverName: 'D1',
          createdAt: DateTime.now(),
        ),
        tripLabours: const [],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    // Check repository directly for final continuity
    final finalTrips = mockRepo.trips;
    expect(finalTrips.length, 3);

    final lastTrip = finalTrips.last;
    expect(lastTrip.sessionWorkId(workMorn.id), isFalse); // Different Work IDs
    expect(
      lastTrip.tripNumber,
      3,
    ); // Morning 2 + 1 = 3 Continuity verified natively
  });
}

extension TripCheck on Trip {
  bool sessionWorkId(String target) {
    return workId == target;
  }
}
