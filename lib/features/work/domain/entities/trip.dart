import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final String workId;
  final int tripNumber;
  final String tractor;
  final String driverName;
  final DateTime createdAt;
  final String place;
  final String workType;
  final String notes;
  final DateTime updatedAt;
  final String status;

  const Trip({
    required this.id,
    required this.workId,
    required this.tripNumber,
    required this.tractor,
    required this.driverName,
    required this.createdAt,
    this.place = '',
    this.workType = 'Sand (Bali)',
    this.notes = '',
    DateTime? updatedAt,
    this.status = 'Completed',
  }) : updatedAt = updatedAt ?? createdAt;

  @override
  List<Object> get props => [
    id,
    workId,
    tripNumber,
    tractor,
    driverName,
    createdAt,
    place,
    workType,
    notes,
    updatedAt,
    status,
  ];
}
