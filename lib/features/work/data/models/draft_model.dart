import 'package:hive/hive.dart';

part 'draft_model.g.dart';

@HiveType(typeId: 4)
class DraftModel extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String session;

  @HiveField(2)
  final String workType;

  @HiveField(3)
  final String place;

  @HiveField(4)
  final String tractor;

  @HiveField(5)
  final String driverName;

  @HiveField(6)
  final String encodedLabours; // JSON encoded list of LabourFormModel

  DraftModel({
    required this.date,
    required this.session,
    required this.workType,
    required this.place,
    required this.tractor,
    required this.driverName,
    required this.encodedLabours,
  });
}
