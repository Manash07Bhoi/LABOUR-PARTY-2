import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/details/presentation/trip_details_screen.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';

class MockWorkBloc extends Bloc<WorkEvent, WorkState> implements WorkBloc {
  MockWorkBloc(super.initialState);
  @override
  Stream<WorkState> get stream => const Stream.empty();
  @override
  void add(WorkEvent event) {}
  @override
  Future<void> close() async {}
  @override
  get calculateNextTripNumber => throw UnimplementedError();
  @override
  get deleteTrip => throw UnimplementedError();
  @override
  get getLaboursForTrip => throw UnimplementedError();
  @override
  get getLaboursForTrips => throw UnimplementedError();
  @override
  get getTripsForWork => throw UnimplementedError();
  @override
  get getWorkByDateAndSession => throw UnimplementedError();
  @override
  get getWorks => throw UnimplementedError();
  @override
  get saveTrip => throw UnimplementedError();
  @override
  get saveTripLabour => throw UnimplementedError();
  @override
  get saveTripLabours => throw UnimplementedError();
  @override
  get saveWork => throw UnimplementedError();
  @override
  get uuid => throw UnimplementedError();
  @override
  get saveLabour => throw UnimplementedError();
  @override
  get getLabours => throw UnimplementedError();
  @override
  get deleteTripLabour => throw UnimplementedError();
}

void main() {
  testWidgets('TripDetailsScreen shows labours and remove icon', (
    WidgetTester tester,
  ) async {
    final trip = Trip(
      id: 't1',
      workId: 'w1',
      tripNumber: 1,
      tractor: 'T1',
      driverName: 'D1',
      createdAt: DateTime.now(),
      place: 'Location',
      workType: 'Sand',
      notes: 'Test Notes',
      updatedAt: DateTime.now(),
      status: 'Completed',
    );
    final work = Work(
      id: 'w1',
      date: '01 Jan 2024',
      session: 'Morning',
      workType: 'Sand',
      place: 'Location',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final labour = Labour(
      id: 'l1',
      name: 'John Doe',
      createdAt: DateTime.now(),
    );
    final tripLabour = TripLabour(
      id: 'tl1',
      tripId: 't1',
      labourId: 'l1',
      isPresent: true,
    );

    final bloc = MockWorkBloc(
      TripDetailsLoaded(
        tripLabours: [tripLabour],
        labours: [labour],
        work: work,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<WorkBloc>.value(
          value: bloc,
          child: TripDetailsScreen(trip: trip),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final johnDoeFinder = find.text('John Doe', skipOffstage: false);

    expect(johnDoeFinder, findsOneWidget);
    expect(
      find.byIcon(Icons.remove_circle_outline, skipOffstage: false),
      findsOneWidget,
    );
  });
}
