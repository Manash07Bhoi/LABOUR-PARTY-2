import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:labour_party/features/work/data/datasources/work_local_data_source.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  late Box<WorkModel> workBox;
  late Box<TripModel> tripBox;
  late Box<LabourModel> labourBox;
  late Box<TripLabourModel> tripLabourBox;
  late WorkLocalDataSourceImpl dataSource;
  const uuid = Uuid();
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_benchmark');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(WorkModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TripModelAdapter());
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(LabourModelAdapter());
    if (!Hive.isAdapterRegistered(3))
      Hive.registerAdapter(TripLabourModelAdapter());

    workBox = await Hive.openBox<WorkModel>('benchmark_work_box');
    tripBox = await Hive.openBox<TripModel>('benchmark_trip_box');
    labourBox = await Hive.openBox<LabourModel>('benchmark_labour_box');
    tripLabourBox = await Hive.openBox<TripLabourModel>(
      'benchmark_trip_labour_box',
    );

    dataSource = WorkLocalDataSourceImpl(
      workBox: workBox,
      tripBox: tripBox,
      labourBox: labourBox,
      tripLabourBox: tripLabourBox,
    );
  });

  tearDown(() async {
    await workBox.close();
    await tripBox.close();
    await labourBox.close();
    await tripLabourBox.close();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> runBenchmark(int count) async {
    print('\n--- BENCHMARK: ' + count.toString() + ' RECORDS ---');

    // Prepare entities
    final models = List.generate(count, (index) {
      return TripLabourModel(
        id: uuid.v4(),
        tripId: 'trip-1',
        labourId: 'labour-' + index.toString(),
        isPresent: true,
      );
    });

    // 1. OLD APPROACH (Loop inserts)
    await tripLabourBox.clear();
    final stopwatchOld = Stopwatch()..start();
    for (final model in models) {
      await dataSource.saveTripLabour(model);
    }
    stopwatchOld.stop();
    final timeOldMs = stopwatchOld.elapsedMilliseconds;
    print('OLD (Loop Inserts): ' + timeOldMs.toString() + 'ms');

    // 2. NEW APPROACH (putAll)
    // For baseline we just simulate using putAll directly on box
    await tripLabourBox.clear();
    final stopwatchNew = Stopwatch()..start();
    final map = {for (var e in models) e.id: e};
    await tripLabourBox.putAll(map);
    stopwatchNew.stop();
    final timeNewMs = stopwatchNew.elapsedMilliseconds;
    print('NEW (putAll)      : ' + timeNewMs.toString() + 'ms');

    if (timeOldMs > 0) {
      final improvement = ((timeOldMs - timeNewMs) / timeOldMs * 100)
          .toStringAsFixed(1);
      print('Improvement       : ' + improvement + '%');
    }
  }

  test('TripLabour Write Benchmark', () async {
    print('==================================================');
    print('TRIP LABOUR WRITE BENCHMARK');
    print('==================================================');

    final scenarios = [10, 50, 100, 500, 1000];

    for (final count in scenarios) {
      await runBenchmark(count);
    }
    print('\n==================================================');
  });
}
