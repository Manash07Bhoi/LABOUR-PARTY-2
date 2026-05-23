import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:labour_party/features/work/data/datasources/work_local_data_source.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';
import 'dart:io';

void main() {
  Future<void> runBenchmarkForSize(int numTrips, int numLaboursPerTrip) async {
    // ignore: avoid_print
    print(
      '\n--- Benchmark for ${numTrips * numLaboursPerTrip} TripLabours ($numTrips trips) ---',
    );

    final tempDir = await Directory.systemTemp.createTemp(
      'hive_bench_$numTrips',
    );
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WorkModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TripModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LabourModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TripLabourModelAdapter());
    }

    final startupStopwatch = Stopwatch()..start();
    final workBox = await Hive.openBox<WorkModel>('works');
    final tripBox = await Hive.openBox<TripModel>('trips');
    final labourBox = await Hive.openBox<LabourModel>('labours');
    final tripLabourBox = await Hive.openBox<TripLabourModel>('tripLabours');
    startupStopwatch.stop();
    // ignore: avoid_print
    print('Startup (open boxes): ${startupStopwatch.elapsedMilliseconds} ms');

    final dataSource = WorkLocalDataSourceImpl(
      workBox: workBox,
      tripBox: tripBox,
      labourBox: labourBox,
      tripLabourBox: tripLabourBox,
    );

    // Seeding
    final seedStopwatch = Stopwatch()..start();
    final tripLaboursMap = <String, TripLabourModel>{};
    for (int i = 0; i < numTrips; i++) {
      final tripId = 'trip_$i';
      // Only adding TripLabours to save time in seeding
      for (int j = 0; j < numLaboursPerTrip; j++) {
        final tlId = 'tl_${i}_$j';
        final tl = TripLabourModel(
          id: tlId,
          tripId: tripId,
          labourId: 'labour_$j',
          isPresent: true,
        );
        // Using composite key for fast putAll
        tripLaboursMap['${tripId}_$tlId'] = tl;
      }
    }
    await tripLabourBox.putAll(tripLaboursMap);
    seedStopwatch.stop();
    // ignore: avoid_print
    print('Seeding took: ${seedStopwatch.elapsedMilliseconds} ms');

    // 1. Measure Lookup
    final targetTripId = 'trip_${numTrips ~/ 2}';
    final lookupStopwatch = Stopwatch()..start();
    final labours = await dataSource.getLaboursForTrip(targetTripId);
    lookupStopwatch.stop();
    // ignore: avoid_print
    print(
      'Lookup for 1 trip ($numLaboursPerTrip labours): ${lookupStopwatch.elapsedMilliseconds} ms',
    );
    expect(labours.length, numLaboursPerTrip);

    // 2. Measure Delete
    final deleteStopwatch = Stopwatch()..start();
    await dataSource.deleteTrip(targetTripId);
    deleteStopwatch.stop();
    // ignore: avoid_print
    print(
      'Delete 1 trip ($numLaboursPerTrip labours): ${deleteStopwatch.elapsedMilliseconds} ms',
    );

    // Verify deletion
    final remainingLabours = await dataSource.getLaboursForTrip(targetTripId);
    expect(remainingLabours, isEmpty);

    // 3. Memory approximate
    final memoryUsageMB = ProcessInfo.currentRss / (1024 * 1024);
    // ignore: avoid_print
    print('Approximate memory (RSS): ${memoryUsageMB.toStringAsFixed(2)} MB');

    await workBox.close();
    await tripBox.close();
    await labourBox.close();
    await tripLabourBox.close();
    await tempDir.delete(recursive: true);
  }

  test(
    'Performance benchmarks across scales',
    () async {
      const numLaboursPerTrip = 20;

      // 10k items (500 trips)
      await runBenchmarkForSize(500, numLaboursPerTrip);

      // 100k items (5000 trips)
      await runBenchmarkForSize(5000, numLaboursPerTrip);

      // 500k items (25000 trips)
      await runBenchmarkForSize(25000, numLaboursPerTrip);

      // 1M items (50000 trips)
      await runBenchmarkForSize(50000, numLaboursPerTrip);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
