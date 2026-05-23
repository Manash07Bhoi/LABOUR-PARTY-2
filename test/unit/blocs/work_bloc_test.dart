import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';

import '../../helpers/mock_work_repository.dart';

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
      calculateNextTripNumber: CalculateNextTripNumberUseCase(mockRepo),
    );
  });

  tearDown(() {
    workBloc.close();
  });

  test('WorkBloc - Edit Historical Trip Preserves Original Number', () async {
    final work = Work(id: 'w1', date: '01 Jan 2024', session: 'Morning', workType: 'Sand', place: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final trip = Trip(id: 't1', workId: 'w1', tripNumber: 2, tractor: '', driverName: '', createdAt: DateTime.now());
    await mockRepo.saveWork(work);

    // Send event
    workBloc.add(SaveFullWorkTripEvent(work: work, trip: trip, tripLabours: const []));

    // Await state updates
    await expectLater(
      workBloc.stream,
      emitsInOrder([
        isA<WorkLoading>(),
        isA<WorkActionSuccess>(),
        isA<WorkLoading>(),
        isA<DashboardLoaded>().having((s) => s.currentTrips.first.tripNumber, 'preserves exact number', 2),
      ]),
    );
  });
}
