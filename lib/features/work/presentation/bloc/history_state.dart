import 'package:equatable/equatable.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final Map<String, Map<String, List<Trip>>>
  groupedTrips; // Date -> Session -> Trips
  final Map<String, Work> worksMap; // WorkId -> Work

  const HistoryLoaded({required this.groupedTrips, required this.worksMap});

  @override
  List<Object?> get props => [groupedTrips, worksMap];
}

class HistoryEmpty extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
