import 'package:equatable/equatable.dart';

class Work extends Equatable {
  final String id;
  final String date;
  final String session;
  final String workType;
  final String place;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Work({
    required this.id,
    required this.date,
    required this.session,
    required this.workType,
    required this.place,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
    id,
    date,
    session,
    workType,
    place,
    createdAt,
    updatedAt,
  ];
}
