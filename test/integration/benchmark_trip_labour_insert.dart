import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:uuid/uuid.dart';

import '../helpers/mock_work_repository.dart';

void main() {
  test('Benchmark - TripLabour Insert', () async {
    final mockRepo = MockWorkRepository();
    final saveTripLabour = SaveTripLabourUseCase(mockRepo);
    final saveTripLabours = SaveTripLaboursUseCase(mockRepo);
    final uuid = Uuid();

    Future<Duration> runLoopBenchmark(int count) async {
      final labours = List.generate(
        count,
        (index) => TripLabour(
          id: uuid.v4(),
          tripId: 'trip_1',
          labourId: 'labour_$index',
          isPresent: true,
        ),
      );

      final stopwatch = Stopwatch()..start();
      for (final labour in labours) {
        await saveTripLabour(labour);
      }
      stopwatch.stop();
      return stopwatch.elapsed;
    }

    Future<Duration> runBatchBenchmark(int count) async {
      final labours = List.generate(
        count,
        (index) => TripLabour(
          id: uuid.v4(),
          tripId: 'trip_1',
          labourId: 'labour_$index',
          isPresent: true,
        ),
      );

      final stopwatch = Stopwatch()..start();
      await saveTripLabours(labours);
      stopwatch.stop();
      return stopwatch.elapsed;
    }

    // Warm up
    await runLoopBenchmark(10);
    await runBatchBenchmark(10);

    final timeLoop10 = await runLoopBenchmark(10);
    final timeLoop50 = await runLoopBenchmark(50);
    final timeLoop100 = await runLoopBenchmark(100);
    final timeLoop500 = await runLoopBenchmark(500);
    final timeLoop1000 = await runLoopBenchmark(1000);

    print('--- Loop Insert Benchmark (Baseline) ---');
    print('10 Labours: ${timeLoop10.inMicroseconds} microseconds');
    print('50 Labours: ${timeLoop50.inMicroseconds} microseconds');
    print('100 Labours: ${timeLoop100.inMicroseconds} microseconds');
    print('500 Labours: ${timeLoop500.inMicroseconds} microseconds');
    print('1000 Labours: ${timeLoop1000.inMicroseconds} microseconds');

    final timeBatch10 = await runBatchBenchmark(10);
    final timeBatch50 = await runBatchBenchmark(50);
    final timeBatch100 = await runBatchBenchmark(100);
    final timeBatch500 = await runBatchBenchmark(500);
    final timeBatch1000 = await runBatchBenchmark(1000);

    print('--- Batch Insert Benchmark (Optimized) ---');
    print('10 Labours: ${timeBatch10.inMicroseconds} microseconds');
    print('50 Labours: ${timeBatch50.inMicroseconds} microseconds');
    print('100 Labours: ${timeBatch100.inMicroseconds} microseconds');
    print('500 Labours: ${timeBatch500.inMicroseconds} microseconds');
    print('1000 Labours: ${timeBatch1000.inMicroseconds} microseconds');
  });
}
