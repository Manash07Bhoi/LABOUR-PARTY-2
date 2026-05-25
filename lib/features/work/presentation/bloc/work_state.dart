import 'package:equatable/equatable.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';

sealed class WorkState extends Equatable {
  const WorkState();
  @override
  List<Object?> get props => [];
}

class WorkInitial extends WorkState {}

class WorkLoading extends WorkState {}

class DashboardLoaded extends WorkState {
  final Work? currentWork;
  final List<Trip> currentTrips;
  final int totalLabourCount;
  final int morningTripCount;
  final int eveningTripCount;
  final int totalTrips;
  final String searchQuery;

  const DashboardLoaded({
    this.currentWork,
    required this.currentTrips,
    required this.totalLabourCount,
    required this.morningTripCount,
    required this.eveningTripCount,
    required this.totalTrips,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    currentWork,
    currentTrips,
    totalLabourCount,
    morningTripCount,
    eveningTripCount,
    totalTrips,
  ];
}

class TripDetailsLoaded extends WorkState {
  final Work? work; // Added Work to TripDetailsLoaded
  final List<TripLabour> tripLabours;
  final List<Labour> labours;
  const TripDetailsLoaded({
    this.work,
    required this.tripLabours,
    required this.labours,
  });

  @override
  List<Object?> get props => [work, tripLabours, labours];
}

class WorkEmpty extends WorkState {
  final String message;
  const WorkEmpty(this.message);
  @override
  List<Object?> get props => [message];
}

class WorkError extends WorkState {
  final String message;
  const WorkError(this.message);
  @override
  List<Object?> get props => [message];
}

class WorkActionSuccess extends WorkState {}
