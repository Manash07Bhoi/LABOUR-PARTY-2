import 'package:dartz/dartz.dart';
import 'package:labour_party/core/error/failures.dart';
import 'package:labour_party/features/work/data/datasources/work_local_data_source.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/repositories/work_repository.dart';

class WorkRepositoryImpl implements WorkRepository {
  final WorkLocalDataSource localDataSource;

  WorkRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Work>>> getWorks() async {
    try {
      final models = await localDataSource.getWorks();
      final entities = models
          .map(
            (m) => Work(
              id: m.id,
              date: m.date,
              session: m.session,
              workType: m.workType,
              place: m.place,
              createdAt: m.createdAt,
              updatedAt: m.updatedAt,
            ),
          )
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch works: $e'));
    }
  }

  @override
  Future<Either<Failure, Work>> getWorkByDateAndSession(
    String date,
    String session,
  ) async {
    try {
      final m = await localDataSource.getWorkByDateAndSession(date, session);
      if (m != null) {
        return Right(
          Work(
            id: m.id,
            date: m.date,
            session: m.session,
            workType: m.workType,
            place: m.place,
            createdAt: m.createdAt,
            updatedAt: m.updatedAt,
          ),
        );
      } else {
        return const Left(DatabaseFailure('Work not found'));
      }
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch work: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveWork(Work work) async {
    try {
      final model = WorkModel(
        id: work.id,
        date: work.date,
        session: work.session,
        workType: work.workType,
        place: work.place,
        createdAt: work.createdAt,
        updatedAt: work.updatedAt,
      );
      await localDataSource.saveWork(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save work: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getAllTrips() async {
    try {
      final models = await localDataSource.getAllTrips();
      final entities = models
          .map(
            (m) => Trip(
              id: m.id,
              workId: m.workId,
              tripNumber: m.tripNumber,
              tractor: m.tractor,
              driverName: m.driverName,
              createdAt: m.createdAt,
            ),
          )
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch all trips: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getTripsForWork(String workId) async {
    try {
      final models = await localDataSource.getTripsForWork(workId);
      final entities = models
          .map(
            (m) => Trip(
              id: m.id,
              workId: m.workId,
              tripNumber: m.tripNumber,
              tractor: m.tractor,
              driverName: m.driverName,
              createdAt: m.createdAt,
            ),
          )
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch trips: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTrip(Trip trip) async {
    try {
      final model = TripModel(
        id: trip.id,
        workId: trip.workId,
        tripNumber: trip.tripNumber,
        tractor: trip.tractor,
        driverName: trip.driverName,
        createdAt: trip.createdAt,
      );
      await localDataSource.saveTrip(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save trip: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) async {
    try {
      await localDataSource.deleteTrip(tripId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete trip: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Labour>>> getLabours() async {
    try {
      final models = await localDataSource.getLabours();
      final entities = models
          .map(
            (m) => Labour(
              id: m.id,
              name: m.name,
              phoneOptional: m.phoneOptional,
              createdAt: m.createdAt,
            ),
          )
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch labours: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLabour(Labour labour) async {
    try {
      final model = LabourModel(
        id: labour.id,
        name: labour.name,
        phoneOptional: labour.phoneOptional,
        createdAt: labour.createdAt,
      );
      await localDataSource.saveLabour(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save labour: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TripLabour>>> getLaboursForTrip(
    String tripId,
  ) async {
    try {
      final models = await localDataSource.getLaboursForTrip(tripId);
      final entities = models
          .map(
            (m) => TripLabour(
              id: m.id,
              tripId: m.tripId,
              labourId: m.labourId,
              isPresent: m.isPresent,
            ),
          )
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch trip labours: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TripLabour>>> getLaboursForTrips(
    List<String> tripIds,
  ) async {
    try {
      final models = await localDataSource.getLaboursForTrips(tripIds);
      final entities = models
          .map(
            (m) => TripLabour(
              id: m.id,
              tripId: m.tripId,
              labourId: m.labourId,
              isPresent: m.isPresent,
            ),
          )
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch trip labours: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTripLabour(TripLabour tripLabour) async {
    try {
      final model = TripLabourModel(
        id: tripLabour.id,
        tripId: tripLabour.tripId,
        labourId: tripLabour.labourId,
        isPresent: tripLabour.isPresent,
      );
      await localDataSource.saveTripLabour(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save trip labour: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTripLabours(
    List<TripLabour> tripLabours,
  ) async {
    try {
      final models = tripLabours
          .map(
            (tl) => TripLabourModel(
              id: tl.id,
              tripId: tl.tripId,
              labourId: tl.labourId,
              isPresent: tl.isPresent,
            ),
          )
          .toList();

      await localDataSource.saveTripLabours(models);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save trip labours: $e'));
    }
  }
}
