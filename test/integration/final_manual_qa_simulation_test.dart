import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';

import '../helpers/mock_work_repository.dart';

void main() {
  late MockWorkRepository repo;
  late WorkBloc bloc;

  setUp(() {
    repo = MockWorkRepository();
    bloc = WorkBloc(
      getWorks: GetWorksUseCase(repo),
      getWorkByDateAndSession: GetWorkByDateAndSessionUseCase(repo),
      saveWork: SaveWorkUseCase(repo),
      getTripsForWork: GetTripsForWorkUseCase(repo),
      saveTrip: SaveTripUseCase(repo),
      deleteTrip: DeleteTripUseCase(repo),
      getLaboursForTrip: GetLaboursForTripUseCase(repo),
      getLaboursForTrips: GetLaboursForTripsUseCase(repo),
      saveTripLabour: SaveTripLabourUseCase(repo),
      saveTripLabours: SaveTripLaboursUseCase(repo),
      calculateNextTripNumber: CalculateNextTripNumberUseCase(repo),
      saveLabour: SaveLabourUseCase(repo),
      getLabours: GetLaboursUseCase(repo),
      deleteTripLabour: DeleteTripLabourUseCase(repo),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('Data Integrity Audit - No Hidden Duplication', () async {
    // Initial State
    expect(repo.works.length, 0);
    expect(repo.trips.length, 0);
    expect(repo.labours.length, 0);
    expect(repo.tripLabours.length, 0);

    // Scenario A: Fresh Install equivalent
    final work1 = Work(
      id: 'work_24_May_2026_Morning',
      date: '24 May 2026',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final trip1 = Trip(
      id: 't1',
      workId: work1.id,
      tripNumber: 1,
      tractor: 'T1',
      driverName: 'D1',
      createdAt: DateTime.now(),
    );
    final l1 = Labour(id: 'l1', name: 'Rahul', createdAt: DateTime.now());
    final tl1 = TripLabour(
      id: 'tl1',
      tripId: 't1',
      labourId: 'l1',
      isPresent: true,
    );

    bloc.add(
      SaveFullWorkTripEvent(
        work: work1,
        trip: trip1,
        tripLabours: [tl1],
        labours: [l1],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    expect(repo.works.length, 1);
    expect(repo.trips.length, 1);
    expect(repo.labours.length, 1);
    expect(repo.tripLabours.length, 1);

    // Scenario B: Edit Existing Trip
    final trip1Edit = Trip(
      id: 't1',
      workId: work1.id,
      tripNumber: 1,
      tractor: 'T2_Edited',
      driverName: 'D2_Edited',
      createdAt: trip1.createdAt,
    );
    final l2 = Labour(id: 'l2', name: 'Manash', createdAt: DateTime.now());
    final tl2 = TripLabour(
      id: 'tl2',
      tripId: 't1',
      labourId: 'l2',
      isPresent: true,
    );

    // Simulating deleting l1 and adding l2
    bloc.add(
      SaveFullWorkTripEvent(
        work: work1,
        trip: trip1Edit,
        tripLabours: [tl2],
        labours: [l2],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    // Verify lengths did not duplicate orphaned records
    expect(repo.works.length, 1);
    expect(repo.trips.length, 1);
    expect(
      repo.labours.length,
      2,
    ); // Labour entities persist globally historically
    expect(
      repo.tripLabours.length,
      2,
    ); // TripLabour soft deletes old record (isPresent=false), keeps new one
    expect(
      repo.tripLabours.any((tl) => tl.labourId == 'l2' && tl.isPresent),
      true,
    );
    expect(
      repo.tripLabours.any((tl) => tl.labourId == 'l1' && !tl.isPresent),
      true,
    );

    // Scenario C: Multi-Day Isolation
    final work2 = Work(
      id: 'work_25_May_2026_Morning',
      date: '25 May 2026',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final trip2 = Trip(
      id: 't2',
      workId: work2.id,
      tripNumber: 1,
      tractor: 'T1',
      driverName: 'D1',
      createdAt: DateTime.now(),
    );
    final tl3 = TripLabour(
      id: 'tl3',
      tripId: 't2',
      labourId: 'l2',
      isPresent: true,
    );

    bloc.add(
      SaveFullWorkTripEvent(
        work: work2,
        trip: trip2,
        tripLabours: [tl3],
        labours: [l2],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    expect(repo.works.length, 2);
    expect(repo.trips.length, 2);
    expect(repo.tripLabours.length, 3);

    // Verifying isolation
    expect(repo.works.any((w) => w.id == 'work_24_May_2026_Morning'), true);
    expect(repo.works.any((w) => w.id == 'work_25_May_2026_Morning'), true);
  });
}
