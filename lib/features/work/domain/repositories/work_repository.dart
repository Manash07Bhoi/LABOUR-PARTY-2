import 'package:dartz/dartz.dart';
import 'package:labour_party/core/error/failures.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';

abstract class WorkRepository {
  Future<Either<Failure, List<Work>>> getWorks();
  Future<Either<Failure, Work>> getWorkByDateAndSession(
    String date,
    String session,
  );
  Future<Either<Failure, void>> saveWork(Work work);

  Future<Either<Failure, List<Trip>>> getTripsForWork(String workId);
  Future<Either<Failure, List<Trip>>> getAllTrips();
  Future<Either<Failure, void>> saveTrip(Trip trip);
  Future<Either<Failure, void>> deleteTrip(String tripId);

  Future<Either<Failure, List<Labour>>> getLabours();
  Future<Either<Failure, void>> saveLabour(Labour labour);

  Future<Either<Failure, List<TripLabour>>> getLaboursForTrip(String tripId);
  Future<Either<Failure, List<TripLabour>>> getLaboursForTrips(List<String> tripIds);
  Future<Either<Failure, void>> saveTripLabour(TripLabour tripLabour);
  Future<Either<Failure, void>> saveTripLabours(List<TripLabour> tripLabours);
}
