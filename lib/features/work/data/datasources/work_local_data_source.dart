import 'package:hive/hive.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';

abstract class WorkLocalDataSource {
  Future<List<WorkModel>> getWorks();
  Future<WorkModel?> getWorkByDateAndSession(String date, String session);
  Future<void> saveWork(WorkModel work);

  Future<List<TripModel>> getTripsForWork(String workId);
  Future<List<TripModel>> getAllTrips();
  Future<void> saveTrip(TripModel trip);
  Future<void> deleteTrip(String tripId);

  Future<List<LabourModel>> getLabours();
  Future<void> saveLabour(LabourModel labour);

  Future<List<TripLabourModel>> getLaboursForTrip(String tripId);
  Future<List<TripLabourModel>> getLaboursForTrips(List<String> tripIds);
  Future<void> saveTripLabour(TripLabourModel tripLabour);
}

class WorkLocalDataSourceImpl implements WorkLocalDataSource {
  final Box<WorkModel> workBox;
  final Box<TripModel> tripBox;
  final Box<LabourModel> labourBox;
  final Box<TripLabourModel> tripLabourBox;

  WorkLocalDataSourceImpl({
    required this.workBox,
    required this.tripBox,
    required this.labourBox,
    required this.tripLabourBox,
  });

  @override
  Future<List<WorkModel>> getWorks() async {
    return workBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<WorkModel?> getWorkByDateAndSession(
    String date,
    String session,
  ) async {
    try {
      return workBox.values.firstWhere(
        (work) => work.date == date && work.session == session,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveWork(WorkModel work) async {
    await workBox.put(work.id, work);
  }

  @override
  Future<List<TripModel>> getAllTrips() async {
    return tripBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<TripModel>> getTripsForWork(String workId) async {
    return tripBox.values.where((trip) => trip.workId == workId).toList()
      ..sort((a, b) => a.tripNumber.compareTo(b.tripNumber));
  }

  @override
  Future<void> saveTrip(TripModel trip) async {
    await tripBox.put(trip.id, trip);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await tripBox.delete(tripId);
    final tripLaboursToDelete = tripLabourBox.values
        .where((tl) => tl.tripId == tripId)
        .map((tl) => tl.id)
        .toList();
    await tripLabourBox.deleteAll(tripLaboursToDelete);
  }

  @override
  Future<List<LabourModel>> getLabours() async {
    return labourBox.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> saveLabour(LabourModel labour) async {
    await labourBox.put(labour.id, labour);
  }

  @override
  Future<List<TripLabourModel>> getLaboursForTrip(String tripId) async {
    return tripLabourBox.values.where((tl) => tl.tripId == tripId).toList();
  }

  @override
  Future<List<TripLabourModel>> getLaboursForTrips(List<String> tripIds) async {
    final tripIdSet = tripIds.toSet();
    return tripLabourBox.values.where((tl) => tripIdSet.contains(tl.tripId)).toList();
  }

  @override
  Future<void> saveTripLabour(TripLabourModel tripLabour) async {
    await tripLabourBox.put(tripLabour.id, tripLabour);
  }
}
