import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final String workId;
  final int tripNumber;
  final String tractor;
  final String driverName;
  final DateTime createdAt;

  const Trip({
    required this.id,
    required this.workId,
    required this.tripNumber,
    required this.tractor,
    required this.driverName,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
    id,
    workId,
    tripNumber,
    tractor,
    driverName,
    createdAt,
  ];
}
