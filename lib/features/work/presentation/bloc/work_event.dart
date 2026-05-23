import 'package:equatable/equatable.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';

abstract class WorkEvent extends Equatable {
  const WorkEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboardDataEvent extends WorkEvent {
  final String date;
  final String session;
  const LoadDashboardDataEvent(this.date, this.session);
  @override
  List<Object?> get props => [date, session];
}

class LoadTripDetailsEvent extends WorkEvent {
  final String tripId;
  const LoadTripDetailsEvent(this.tripId);
  @override
  List<Object?> get props => [tripId];
}

class AddQuickTripEvent extends WorkEvent {
  final String date;
  final String session;
  const AddQuickTripEvent({required this.date, required this.session});
  @override
  List<Object?> get props => [date, session];
}

class RemoveLatestTripEvent extends WorkEvent {
  const RemoveLatestTripEvent();
}

class DeleteSpecificTripEvent extends WorkEvent {
  final String tripId;
  const DeleteSpecificTripEvent(this.tripId);
  @override
  List<Object?> get props => [tripId];
}

class SaveFullWorkTripEvent extends WorkEvent {
  final Work work;
  final Trip trip;
  final List<TripLabour> tripLabours;

  const SaveFullWorkTripEvent({
    required this.work,
    required this.trip,
    required this.tripLabours,
  });

  @override
  List<Object?> get props => [work, trip, tripLabours];
}
