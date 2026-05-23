import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';

import '../../helpers/mock_work_repository.dart';

void main() {
  late MockWorkRepository mockRepo;
  late CalculateNextTripNumberUseCase useCase;

  setUp(() {
    mockRepo = MockWorkRepository();
    useCase = CalculateNextTripNumberUseCase(mockRepo);
  });

  test('Trip Numbering - No Morning, Evening Starts at 1', () async {
    final workEve = Work(id: 'eve1', date: '01 Jan 2024', session: 'Evening', workType: 'Sand', place: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    await mockRepo.saveWork(workEve);

    final result = await useCase('01 Jan 2024');
    expect(result.fold((l) => 0, (r) => r), 1);
  });

  test('Trip Numbering - Morning 1->2->3, Evening Starts at 4', () async {
    final workMorn = Work(id: 'morn1', date: '01 Jan 2024', session: 'Morning', workType: 'Sand', place: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    await mockRepo.saveWork(workMorn);
    await mockRepo.saveTrip(Trip(id: 't1', workId: 'morn1', tripNumber: 1, tractor: '', driverName: '', createdAt: DateTime.now()));
    await mockRepo.saveTrip(Trip(id: 't2', workId: 'morn1', tripNumber: 2, tractor: '', driverName: '', createdAt: DateTime.now()));
    await mockRepo.saveTrip(Trip(id: 't3', workId: 'morn1', tripNumber: 3, tractor: '', driverName: '', createdAt: DateTime.now()));

    final result = await useCase('01 Jan 2024');
    expect(result.fold((l) => 0, (r) => r), 4);
  });

  test('Trip Numbering - Evening Continues from 4', () async {
    final workMorn = Work(id: 'morn1', date: '01 Jan 2024', session: 'Morning', workType: 'Sand', place: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final workEve = Work(id: 'eve1', date: '01 Jan 2024', session: 'Evening', workType: 'Sand', place: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    await mockRepo.saveWork(workMorn);
    await mockRepo.saveWork(workEve);

    await mockRepo.saveTrip(Trip(id: 't1', workId: 'morn1', tripNumber: 1, tractor: '', driverName: '', createdAt: DateTime.now()));
    await mockRepo.saveTrip(Trip(id: 't2', workId: 'morn1', tripNumber: 2, tractor: '', driverName: '', createdAt: DateTime.now()));
    await mockRepo.saveTrip(Trip(id: 't3', workId: 'morn1', tripNumber: 3, tractor: '', driverName: '', createdAt: DateTime.now()));
    await mockRepo.saveTrip(Trip(id: 't4', workId: 'eve1', tripNumber: 4, tractor: '', driverName: '', createdAt: DateTime.now()));

    final result = await useCase('01 Jan 2024');
    expect(result.fold((l) => 0, (r) => r), 5);
  });

  test('Trip Numbering - Delete Middle Trip Preserves Safe Chronology', () async {
    final workMorn = Work(id: 'morn1', date: '01 Jan 2024', session: 'Morning', workType: 'Sand', place: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
    await mockRepo.saveWork(workMorn);
    await mockRepo.saveTrip(Trip(id: 't1', workId: 'morn1', tripNumber: 1, tractor: '', driverName: '', createdAt: DateTime.now()));
    await mockRepo.saveTrip(Trip(id: 't3', workId: 'morn1', tripNumber: 3, tractor: '', driverName: '', createdAt: DateTime.now()));

    // Max trip is 3, so next should be 4 even if 2 is missing.
    final result = await useCase('01 Jan 2024');
    expect(result.fold((l) => 0, (r) => r), 4);
  });
}
