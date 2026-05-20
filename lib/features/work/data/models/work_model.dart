import 'package:hive/hive.dart';

part 'work_model.g.dart';

@HiveType(typeId: 0)
class WorkModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String date;
  @HiveField(2)
  final String session;
  @HiveField(3)
  final String workType;
  @HiveField(4)
  final String place;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime updatedAt;

  WorkModel({
    required this.id,
    required this.date,
    required this.session,
    required this.workType,
    required this.place,
    required this.createdAt,
    required this.updatedAt,
  });
}
