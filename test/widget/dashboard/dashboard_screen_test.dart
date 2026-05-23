import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/dashboard/presentation/dashboard_screen.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';
import 'package:labour_party/theme/app_theme.dart';

import '../../helpers/mock_work_repository.dart';

void main() {
  testWidgets('DashboardScreen Renders Empty State Initially', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockWorkRepository();
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
      calculateNextTripNumber: CalculateNextTripNumberUseCase(mockRepo),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlocProvider.value(
          value: workBloc,
          child: const DashboardScreen(),
        ),
      ),
    );

    // BLoC immediately emits WorkLoading, wait for WorkEmpty to emit
    await tester.pump();
    await tester.pump(
      const Duration(seconds: 1),
    ); // Work Empty animation resolution

    expect(find.text('No work added today'), findsOneWidget);

    workBloc.close();
  });
}
