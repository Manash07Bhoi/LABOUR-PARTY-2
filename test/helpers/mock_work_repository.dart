import 'package:dartz/dartz.dart';
import 'package:labour_party/core/error/failures.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/repositories/work_repository.dart';

class MockWorkRepository implements WorkRepository {
  List<Work> works = [];
  List<Trip> trips = [];
  List<Labour> labours = [];
  List<TripLabour> tripLabours = [];

  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) async {
    trips.removeWhere((t) => t.id == tripId);
    tripLabours.removeWhere((tl) => tl.tripId == tripId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Trip>>> getAllTrips() async {
    return Right(trips);
  }

  @override
  Future<Either<Failure, List<Labour>>> getLabours() async {
    return Right(labours);
  }

  @override
  Future<Either<Failure, List<TripLabour>>> getLaboursForTrip(String tripId) async {
    return Right(tripLabours.where((tl) => tl.tripId == tripId).toList());
  }

  @override
  Future<Either<Failure, List<Trip>>> getTripsForWork(String workId) async {
    return Right(trips.where((t) => t.workId == workId).toList());
  }

  @override
  Future<Either<Failure, Work>> getWorkByDateAndSession(String date, String session) async {
    try {
      final work = works.firstWhere((w) => w.date == date && w.session == session);
      return Right(work);
    } catch (_) {
      return const Left(DatabaseFailure('Work not found'));
    }
  }

  @override
  Future<Either<Failure, List<Work>>> getWorks() async {
    return Right(works);
  }

  @override
  Future<Either<Failure, void>> saveLabour(Labour labour) async {
    labours.removeWhere((l) => l.id == labour.id);
    labours.add(labour);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveTrip(Trip trip) async {
    trips.removeWhere((t) => t.id == trip.id);
    trips.add(trip);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveTripLabour(TripLabour tripLabour) async {
    tripLabours.removeWhere((tl) => tl.id == tripLabour.id);
    tripLabours.add(tripLabour);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveTripLabours(List<TripLabour> newTripLabours) async {
    for (var tl in newTripLabours) {
      tripLabours.removeWhere((existing) => existing.id == tl.id);
      tripLabours.add(tl);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveWork(Work work) async {
    works.removeWhere((w) => w.id == work.id);
    works.add(work);
    return const Right(null);
  }
}
