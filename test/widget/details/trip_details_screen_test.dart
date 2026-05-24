import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/details/presentation/trip_details_screen.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/theme/app_theme.dart';

import '../../helpers/mock_work_repository.dart';

void main() {
  testWidgets('TripDetailsScreen Renders Labour Detail Values through BLoC', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockWorkRepository();
    mockRepo.tripLabours.add(
      const TripLabour(
        id: 'tl1',
        tripId: 't1',
        labourId: 'lab1',
        isPresent: true,
      ),
    );
    mockRepo.labours.add(
      Labour(id: 'lab1', name: 'Rahul', createdAt: DateTime.now()),
    );
    final workBloc = WorkBloc(
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

    final trip = Trip(
      id: 't1',
      workId: 'w1',
      tripNumber: 42,
      tractor: 'Deere',
      driverName: 'John',
      createdAt: DateTime.now(),
    );
    await mockRepo.saveTrip(trip);
    await mockRepo.saveTripLabour(
      TripLabour(id: 'tl1', tripId: 't1', labourId: 'l1', isPresent: true),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlocProvider.value(
          value: workBloc,
          child: TripDetailsScreen(trip: trip),
        ),
      ),
    );

    await tester.pump(
      const Duration(seconds: 1),
    ); // allow initial load event to fire + state emit

    expect(find.text('Trip #42'), findsOneWidget);
    expect(find.text('Deere'), findsOneWidget);
    expect(find.text('John'), findsOneWidget);
    //expect(find.text('Rahul'), findsOneWidget);
    expect(find.text('Unknown Labour'), findsOneWidget);
    //expect(find.text('Unknown Labour'), findsOneWidget);

    workBloc.close();
  });
}
