import 'package:hive/hive.dart';

part 'trip_labour_model.g.dart';

@HiveType(typeId: 3)
class TripLabourModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String tripId;
  @HiveField(2)
  final String labourId;
  @HiveField(3)
  final bool isPresent;

  TripLabourModel({
    required this.id,
    required this.tripId,
    required this.labourId,
    required this.isPresent,
  });
}
