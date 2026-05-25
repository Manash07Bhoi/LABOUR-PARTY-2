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

  test('GATE 1: Labour Integrity & Edit Preservation', () async {
    final work = Work(
      id: 'w_24_may',
      date: '24 May 2026',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final trip = Trip(
      id: 't1',
      workId: 'w_24_may',
      tripNumber: 1,
      tractor: 'T1',
      driverName: 'D1',
      createdAt: DateTime.now(),
    );
    final l1 = Labour(id: 'l1', name: 'Rahul', createdAt: DateTime.now());
    final l2 = Labour(id: 'l2', name: 'Manash', createdAt: DateTime.now());
    final l3 = Labour(id: 'l3', name: 'Sita', createdAt: DateTime.now());

    final tl1 = TripLabour(
      id: 'tl1',
      tripId: 't1',
      labourId: 'l1',
      isPresent: true,
    );
    final tl2 = TripLabour(
      id: 'tl2',
      tripId: 't1',
      labourId: 'l2',
      isPresent: true,
    );
    final tl3 = TripLabour(
      id: 'tl3',
      tripId: 't1',
      labourId: 'l3',
      isPresent: true,
    );

    bloc.add(
      SaveFullWorkTripEvent(
        work: work,
        trip: trip,
        tripLabours: [tl1, tl2, tl3],
        labours: [l1, l2, l3],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    expect(repo.labours.length, 3);
    expect(repo.labours.any((l) => l.name == 'Rahul'), true);
    expect(repo.labours.any((l) => l.name == 'Unknown Labour'), false);
    expect(repo.tripLabours.length, 3);
  });

  test('GATE 2: Attendance Toggle & Negative Button', () async {
    final work = Work(
      id: 'w_24_may',
      date: '24 May 2026',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final trip = Trip(
      id: 't1',
      workId: 'w_24_may',
      tripNumber: 1,
      tractor: 'T1',
      driverName: 'D1',
      createdAt: DateTime.now(),
    );
    final l1 = Labour(id: 'l1', name: 'Rahul', createdAt: DateTime.now());
    final l2 = Labour(id: 'l2', name: 'Manash', createdAt: DateTime.now());

    // Save 2 labours
    final tl1 = TripLabour(
      id: 'tl1',
      tripId: 't1',
      labourId: 'l1',
      isPresent: true,
    );
    final tl2 = TripLabour(
      id: 'tl2',
      tripId: 't1',
      labourId: 'l2',
      isPresent: true,
    );
    bloc.add(
      SaveFullWorkTripEvent(
        work: work,
        trip: trip,
        tripLabours: [tl1, tl2],
        labours: [l1, l2],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    // Negative button: Edit trip, remove l2, and mark l1 absent
    final tl1_edit = TripLabour(
      id: 'tl1',
      tripId: 't1',
      labourId: 'l1',
      isPresent: false,
    );
    bloc.add(
      SaveFullWorkTripEvent(
        work: work,
        trip: trip,
        tripLabours: [tl1_edit],
        labours: [l1],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    // Validate
    // Since we do soft deletes, we inserted 2 originally. In the edit, we passed only 1 (tl1_edit).
    // The missing one is soft-deleted. So the length is still 2!
    expect(repo.tripLabours.length, 2); 
    expect(repo.tripLabours.any((tl) => tl.labourId == 'l1' && tl.isPresent == false), true); 
    expect(repo.tripLabours.any((tl) => tl.labourId == 'l2' && tl.isPresent == false), true); // l2 was soft deleted
  });

  test('GATE 3: Date Isolation', () async {
    final work24 = Work(
      id: 'work_24_May_2026_Morning',
      date: '24 May 2026',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final work25 = Work(
      id: 'work_25_May_2026_Morning',
      date: '25 May 2026',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final trip24 = Trip(
      id: 't1',
      workId: work24.id,
      tripNumber: 1,
      tractor: 'T1',
      driverName: 'D1',
      createdAt: DateTime.now(),
    );
    final trip25 = Trip(
      id: 't2',
      workId: work25.id,
      tripNumber: 1,
      tractor: 'T1',
      driverName: 'D1',
      createdAt: DateTime.now(),
    );

    bloc.add(
      SaveFullWorkTripEvent(
        work: work24,
        trip: trip24,
        tripLabours: [],
        labours: [],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    bloc.add(
      SaveFullWorkTripEvent(
        work: work25,
        trip: trip25,
        tripLabours: [],
        labours: [],
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));

    expect(repo.works.length, 2);
    expect(repo.works.any((w) => w.date == '24 May 2026'), true);
    expect(repo.works.any((w) => w.date == '25 May 2026'), true);
  });
}
