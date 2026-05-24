import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';

import '../../helpers/mock_work_repository.dart';

void main() {
  test('SearchDashboardEvent filters trips correctly', () async {
    final mockRepo = MockWorkRepository();
    final bloc = WorkBloc(
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
      saveLabour: SaveLabourUseCase(mockRepo),
      getLabours: GetLaboursUseCase(mockRepo),
      deleteTripLabour: DeleteTripLabourUseCase(mockRepo),
    );

    final work = Work(
      id: 'w1',
      date: '01 Jan 2024',
      session: 'Morning',
      workType: 'Sand',
      place: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await mockRepo.saveWork(work);

    final trip1 = Trip(
      id: 't1',
      workId: 'w1',
      tripNumber: 1,
      tractor: 'Deere',
      driverName: 'John',
      createdAt: DateTime.now(),
    );
    final trip2 = Trip(
      id: 't2',
      workId: 'w1',
      tripNumber: 2,
      tractor: 'Sonalika',
      driverName: 'Mike',
      createdAt: DateTime.now(),
    );

    await mockRepo.saveTrip(trip1);
    await mockRepo.saveTrip(trip2);

    bloc.add(const LoadDashboardDataEvent('01 Jan 2024', 'Morning'));
    await Future.delayed(const Duration(milliseconds: 100));

    expect(bloc.state is DashboardLoaded, true);
    expect((bloc.state as DashboardLoaded).currentTrips.length, 2);

    bloc.add(const SearchDashboardEvent('john'));
    await Future.delayed(const Duration(milliseconds: 100));

    expect(bloc.state is DashboardLoaded, true);
    expect((bloc.state as DashboardLoaded).currentTrips.length, 1);
    expect(
      (bloc.state as DashboardLoaded).currentTrips.first.driverName,
      'John',
    );

    bloc.close();
  });
}
