import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';

import '../../helpers/mock_work_repository.dart';

void main() {
  test('SaveFullWorkTripEvent saves Labour names', () async {
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
    );

    final work = Work(id: 'w1', date: '01 Jan 2024', session: 'Morning', workType: 'Sand', place: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final trip = Trip(id: 't1', workId: 'w1', tripNumber: 1, tractor: 'Deere', driverName: 'John', createdAt: DateTime.now());
    final labour = Labour(id: 'lab1', name: 'RealName', createdAt: DateTime.now());
    final tripLabour = TripLabour(id: 'tl1', tripId: 't1', labourId: 'lab1', isPresent: true);

    bloc.add(SaveFullWorkTripEvent(work: work, trip: trip, tripLabours: [tripLabour], labours: [labour]));
    
    // Wait a tick
    await Future.delayed(const Duration(milliseconds: 100));
    
    expect(mockRepo.labours.length, 1);
    expect(mockRepo.labours.first.name, 'RealName');
    bloc.close();
  });
}
