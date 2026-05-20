import 'package:hive_flutter/hive_flutter.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';

class HiveSetup {
  static const String workBox = 'work_box';
  static const String tripBox = 'trip_box';
  static const String labourBox = 'labour_box';
  static const String tripLabourBox = 'trip_labour_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(WorkModelAdapter());
    Hive.registerAdapter(TripModelAdapter());
    Hive.registerAdapter(LabourModelAdapter());
    Hive.registerAdapter(TripLabourModelAdapter());

    await Hive.openBox<WorkModel>(workBox);
    await Hive.openBox<TripModel>(tripBox);
    await Hive.openBox<LabourModel>(labourBox);
    await Hive.openBox<TripLabourModel>(tripLabourBox);
  }
}
