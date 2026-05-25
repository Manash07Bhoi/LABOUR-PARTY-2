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
  @HiveField(6, defaultValue: '')
  final String place;
  @HiveField(7, defaultValue: 'Sand (Bali)')
  final String workType;
  @HiveField(8, defaultValue: '')
  final String notes;
  @HiveField(9, defaultValue: null)
  final DateTime? updatedAt;
  @HiveField(10, defaultValue: 'Completed')
  final String status;

  TripModel({
    required this.id,
    required this.workId,
    required this.tripNumber,
    required this.tractor,
    required this.driverName,
    required this.createdAt,
    this.place = '',
    this.workType = 'Sand (Bali)',
    this.notes = '',
    this.updatedAt,
    this.status = 'Completed',
  });
}
