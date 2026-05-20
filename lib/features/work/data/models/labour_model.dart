import 'package:hive/hive.dart';

part 'labour_model.g.dart';

@HiveType(typeId: 2)
class LabourModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? phoneOptional;
  @HiveField(3)
  final DateTime createdAt;

  LabourModel({
    required this.id,
    required this.name,
    this.phoneOptional,
    required this.createdAt,
  });
}
