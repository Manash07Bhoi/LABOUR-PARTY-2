import 'package:equatable/equatable.dart';

class TripLabour extends Equatable {
  final String id;
  final String tripId;
  final String labourId;
  final bool isPresent;

  const TripLabour({
    required this.id,
    required this.tripId,
    required this.labourId,
    required this.isPresent,
  });

  @override
  List<Object> get props => [id, tripId, labourId, isPresent];
}
