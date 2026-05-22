import 'package:dartz/dartz.dart';
import 'package:labour_party/core/error/failures.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/repositories/work_repository.dart';

class GetWorksUseCase {
  final WorkRepository repository;
  GetWorksUseCase(this.repository);
  Future<Either<Failure, List<Work>>> call() => repository.getWorks();
}

class GetWorkByDateAndSessionUseCase {
  final WorkRepository repository;
  GetWorkByDateAndSessionUseCase(this.repository);
  Future<Either<Failure, Work>> call(String date, String session) =>
      repository.getWorkByDateAndSession(date, session);
}

class SaveWorkUseCase {
  final WorkRepository repository;
  SaveWorkUseCase(this.repository);
  Future<Either<Failure, void>> call(Work work) => repository.saveWork(work);
}

class GetTripsForWorkUseCase {
  final WorkRepository repository;
  GetTripsForWorkUseCase(this.repository);
  Future<Either<Failure, List<Trip>>> call(String workId) =>
      repository.getTripsForWork(workId);
}

class GetAllTripsUseCase {
  final WorkRepository repository;
  GetAllTripsUseCase(this.repository);
  Future<Either<Failure, List<Trip>>> call() => repository.getAllTrips();
}

class SaveTripUseCase {
  final WorkRepository repository;
  SaveTripUseCase(this.repository);
  Future<Either<Failure, void>> call(Trip trip) => repository.saveTrip(trip);
}

class DeleteTripUseCase {
  final WorkRepository repository;
  DeleteTripUseCase(this.repository);
  Future<Either<Failure, void>> call(String tripId) =>
      repository.deleteTrip(tripId);
}

class GetLaboursUseCase {
  final WorkRepository repository;
  GetLaboursUseCase(this.repository);
  Future<Either<Failure, List<Labour>>> call() => repository.getLabours();
}

class SaveLabourUseCase {
  final WorkRepository repository;
  SaveLabourUseCase(this.repository);
  Future<Either<Failure, void>> call(Labour labour) =>
      repository.saveLabour(labour);
}

class GetLaboursForTripUseCase {
  final WorkRepository repository;
  GetLaboursForTripUseCase(this.repository);
  Future<Either<Failure, List<TripLabour>>> call(String tripId) =>
      repository.getLaboursForTrip(tripId);
}

class SaveTripLabourUseCase {
  final WorkRepository repository;
  SaveTripLabourUseCase(this.repository);
  Future<Either<Failure, void>> call(TripLabour tripLabour) =>
      repository.saveTripLabour(tripLabour);
}

class CalculateNextTripNumberUseCase {
  final WorkRepository repository;

  CalculateNextTripNumberUseCase(this.repository);

  Future<Either<Failure, int>> call(String date) async {
    int highestMorningTrip = 0;
    int highestEveningTrip = 0;

    final morningWorkResult = await repository.getWorkByDateAndSession(date, 'Morning');
    await morningWorkResult.fold((f) async {}, (w) async {
      final tResult = await repository.getTripsForWork(w.id);
      tResult.fold((f) {}, (trips) {
        if (trips.isNotEmpty) {
          highestMorningTrip = trips
              .map((t) => t.tripNumber)
              .reduce((a, b) => a > b ? a : b);
        }
      });
    });

    final eveningWorkResult = await repository.getWorkByDateAndSession(date, 'Evening');
    await eveningWorkResult.fold((f) async {}, (w) async {
      final tResult = await repository.getTripsForWork(w.id);
      tResult.fold((f) {}, (trips) {
        if (trips.isNotEmpty) {
          highestEveningTrip = trips
              .map((t) => t.tripNumber)
              .reduce((a, b) => a > b ? a : b);
        }
      });
    });

    return Right((highestEveningTrip > highestMorningTrip
            ? highestEveningTrip
            : highestMorningTrip) +
        1);
  }
}
