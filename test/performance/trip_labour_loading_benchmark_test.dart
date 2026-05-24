import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:labour_party/features/work/data/datasources/work_local_data_source.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

void main() {
  late WorkLocalDataSourceImpl dataSource;
  late Box<WorkModel> workBox;
  late Box<TripModel> tripBox;
  late Box<LabourModel> labourBox;
  late Box<TripLabourModel> tripLabourBox;

  final uuid = const Uuid();

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp(
      'hive_benchmark_test',
    );
    Hive.init(tempDir.path);
    Hive.registerAdapter(WorkModelAdapter());
    Hive.registerAdapter(TripModelAdapter());
    Hive.registerAdapter(LabourModelAdapter());
    Hive.registerAdapter(TripLabourModelAdapter());
  });

  setUp(() async {
    workBox = await Hive.openBox<WorkModel>('work_box_bench');
    tripBox = await Hive.openBox<TripModel>('trip_box_bench');
    labourBox = await Hive.openBox<LabourModel>('labour_box_bench');
    tripLabourBox = await Hive.openBox<TripLabourModel>(
      'trip_labour_box_bench',
    );

    dataSource = WorkLocalDataSourceImpl(
      workBox: workBox,
      tripBox: tripBox,
      labourBox: labourBox,
      tripLabourBox: tripLabourBox,
    );
  });

  tearDown(() async {
    await workBox.clear();
    await tripBox.clear();
    await labourBox.clear();
    await tripLabourBox.clear();

    await workBox.close();
    await tripBox.close();
    await labourBox.close();
    await tripLabourBox.close();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  Future<void> seedData(int tripCount) async {
    final workId = uuid.v4();
    final trips = List.generate(
      tripCount,
      (index) => TripModel(
        id: uuid.v4(),
        workId: workId,
        tripNumber: index + 1,
        tractor: 'Tractor $index',
        driverName: 'Driver $index',
        createdAt: DateTime.now(),
      ),
    );

    final tripLabours = <TripLabourModel>[];
    for (var trip in trips) {
      for (int j = 0; j < 5; j++) {
        // 5 labours per trip
        tripLabours.add(
          TripLabourModel(
            id: uuid.v4(),
            tripId: trip.id,
            labourId: uuid.v4(),
            isPresent: j % 2 == 0,
          ),
        );
      }
    }

    for (var t in trips) {
      await dataSource.saveTrip(t);
    }
    for (var tl in tripLabours) {
      await dataSource.saveTripLabour(tl);
    }
  }

  test('Benchmark Loading Labours N+1 vs Batch', () async {
    final counts = [10, 50, 100, 500];

    for (final count in counts) {
      await tripBox.clear();
      await tripLabourBox.clear();
      await seedData(count);

      final trips = await dataSource.getAllTrips();

      // Old way (N+1)
      final n1Stopwatch = Stopwatch()..start();
      int totalLabourCountN1 = 0;
      for (var trip in trips) {
        final labours = await dataSource.getLaboursForTrip(trip.id);
        totalLabourCountN1 += labours.where((l) => l.isPresent).length;
      }
      n1Stopwatch.stop();

      print(
        'Trips: $count | N+1 Time: ${n1Stopwatch.elapsedMilliseconds} ms | Labours: $totalLabourCountN1',
      );

      // Batch way
      final batchStopwatch = Stopwatch()..start();
      int totalLabourCountBatch = 0;
      final tripIds = trips.map((t) => t.id).toList();
      final labours = await dataSource.getLaboursForTrips(tripIds);
      totalLabourCountBatch = labours.where((l) => l.isPresent).length;
      batchStopwatch.stop();

      print(
        'Trips: $count | Batch Time: ${batchStopwatch.elapsedMilliseconds} ms | Labours: $totalLabourCountBatch',
      );

      expect(totalLabourCountN1, totalLabourCountBatch);
    }
  });
}
