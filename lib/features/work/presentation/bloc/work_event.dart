import 'package:equatable/equatable.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';

sealed class WorkEvent extends Equatable {
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

class AddQuickTripEvent extends WorkEvent {
  final String date;
  final String session;
  const AddQuickTripEvent({required this.date, required this.session});
  @override
  List<Object?> get props => [date, session];
}

class NavigateToConfirmNextTripEvent extends WorkEvent {
  final String date;
  final String session;

  const NavigateToConfirmNextTripEvent({
    required this.date,
    required this.session,
  });

  @override
  List<Object?> get props => [date, session];
}

class SaveNextTripEvent extends WorkEvent {
  final Trip trip;
  final List<TripLabour> tripLabours;

  const SaveNextTripEvent({required this.trip, required this.tripLabours});

  @override
  List<Object?> get props => [trip, tripLabours];
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

class LoadTripDetailsEvent extends WorkEvent {
  final String tripId;
  const LoadTripDetailsEvent(this.tripId);
  @override
  List<Object?> get props => [tripId];
}

class SaveFullWorkTripEvent extends WorkEvent {
  final Work work;
  final Trip trip;
  final List<TripLabour> tripLabours;
  final List<Labour> labours;

  const SaveFullWorkTripEvent({
    required this.work,
    required this.trip,
    required this.tripLabours,
    required this.labours,
  });
  @override
  List<Object?> get props => [work, trip, tripLabours, labours];
}

class SaveTripLabourEvent extends WorkEvent {
  final TripLabour tripLabour;
  final Labour labour;
  const SaveTripLabourEvent({required this.tripLabour, required this.labour});
  @override
  List<Object?> get props => [tripLabour, labour];
}

class SaveLabourEvent extends WorkEvent {
  final Labour labour;
  const SaveLabourEvent({required this.labour});
  @override
  List<Object?> get props => [labour];
}

class UpdateTripLabourEvent extends WorkEvent {
  final TripLabour tripLabour;
  const UpdateTripLabourEvent({required this.tripLabour});
  @override
  List<Object?> get props => [tripLabour];
}

class DeleteTripLabourEvent extends WorkEvent {
  final String id;
  final String tripId;
  const DeleteTripLabourEvent({required this.id, required this.tripId});
  @override
  List<Object?> get props => [id, tripId];
}

class SearchDashboardEvent extends WorkEvent {
  final String query;
  const SearchDashboardEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterDashboardEvent extends WorkEvent {
  final Map<String, dynamic> filters;
  const FilterDashboardEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}
