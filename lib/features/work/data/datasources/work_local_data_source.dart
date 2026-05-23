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
  }) {
    _migrateLegacyTripLabours();
  }

  void _migrateLegacyTripLabours() {
    final legacyKeys = tripLabourBox.keys.where((k) => !k.toString().contains('_')).toList();
    if (legacyKeys.isEmpty) return;

    for (var k in legacyKeys) {
      final tl = tripLabourBox.get(k);
      if (tl != null) {
        final newKey = '${tl.tripId}_${tl.id}';
        tripLabourBox.put(newKey, tl);
        tripLabourBox.delete(k);
      }
    }
  }

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

    // Performance optimization: Option A - direct key access
    // Instead of scanning all values (O(N)), we scan keys using a prefix strategy.
    // Keys are stored in the format `${tripId}_${tripLabourId}`
    final prefix = '${tripId}_';
    final keysToDelete = tripLabourBox.keys
        .where((k) => k.toString().startsWith(prefix))
        .toList();

    await tripLabourBox.deleteAll(keysToDelete);
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
    // Prefix scan for fast retrieval
    final prefix = '${tripId}_';
    final matchingKeys = tripLabourBox.keys.where(
      (k) => k.toString().startsWith(prefix),
    );
    final List<TripLabourModel> results = [];

    for (final key in matchingKeys) {
      final val = tripLabourBox.get(key);
      if (val != null) results.add(val);
    }

    return results;
  }

  @override
  Future<void> saveTripLabour(TripLabourModel tripLabour) async {
    // Store using composite key strategy: tripId_id
    final compositeKey = '${tripLabour.tripId}_${tripLabour.id}';

    // Handle potential duplicate keys from legacy format.
    // If it exists under the old key, remove it first to migrate it to the composite key.
    if (tripLabourBox.containsKey(tripLabour.id)) {
      await tripLabourBox.delete(tripLabour.id);
    }

    await tripLabourBox.put(compositeKey, tripLabour);
  }
}
