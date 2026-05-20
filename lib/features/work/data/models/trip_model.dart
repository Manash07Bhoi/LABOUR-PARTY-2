import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 1)
class TripModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String workId;
  @HiveField(2)
  final int tripNumber;
  @HiveField(3)
  final String tractor;
  @HiveField(4)
  final String driverName;
  @HiveField(5)
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.workId,
    required this.tripNumber,
    required this.tractor,
    required this.driverName,
    required this.createdAt,
  });
}
