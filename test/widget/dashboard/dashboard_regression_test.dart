import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/dashboard/presentation/dashboard_screen.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/features/work/presentation/bloc/work_state.dart';
import 'package:labour_party/features/work/presentation/bloc/work_event.dart';
import 'package:bloc/bloc.dart';

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
}

void main() {
  testWidgets('Dashboard recovers gracefully from TripDetailsLoaded', (WidgetTester tester) async {
    final bloc = MockWorkBloc(const TripDetailsLoaded(tripLabours: [], labours: []));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<WorkBloc>.value(
          value: bloc,
          child: const DashboardScreen(),
        ),
      ),
    );

    expect(find.text('Unexpected state in Dashboard'), findsNothing);
  });
}
