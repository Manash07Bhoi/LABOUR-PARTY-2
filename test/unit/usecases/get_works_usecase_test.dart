import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/core/error/failures.dart';
import 'package:labour_party/features/work/domain/entities/labour.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/trip_labour.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/repositories/work_repository.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';

class WorkRepositorySpy implements WorkRepository {
  int getWorksCallCount = 0;
  Either<Failure, List<Work>> getWorksResult = const Right([]);

  @override
  Future<Either<Failure, List<Work>>> getWorks() async {
    getWorksCallCount++;
    return getWorksResult;
  }

  // --- Unused methods ---
  @override
  Future<Either<Failure, void>> deleteTripLabour(String id) async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, List<Trip>>> getAllTrips() =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, List<Labour>>> getLabours() =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, List<TripLabour>>> getLaboursForTrip(String tripId) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, List<TripLabour>>> getLaboursForTrips(
    List<String> tripIds,
  ) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<Trip>>> getTripsForWork(String workId) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Work>> getWorkByDateAndSession(
    String date,
    String session,
  ) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> saveLabour(Labour labour) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, void>> saveTrip(Trip trip) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, void>> saveTripLabour(TripLabour tripLabour) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, void>> saveTripLabours(
    List<TripLabour> newTripLabours,
  ) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> saveWork(Work work) =>
      throw UnimplementedError();
}

void main() {
  late GetWorksUseCase usecase;
  late WorkRepositorySpy repositorySpy;

  setUp(() {
    repositorySpy = WorkRepositorySpy();
    usecase = GetWorksUseCase(repositorySpy);
  });

  group('GetWorksUseCase', () {
    final List<Work> tWorks = [
      Work(
        id: '1',
        date: '2023-10-01',
        session: 'Morning',
        workType: 'Sand',
        place: 'Site A',
        createdAt: DateTime(2023, 10, 1),
        updatedAt: DateTime(2023, 10, 1),
      ),
      Work(
        id: '2',
        date: '2023-10-01',
        session: 'Evening',
        workType: 'Stone',
        place: 'Site B',
        createdAt: DateTime(2023, 10, 1),
        updatedAt: DateTime(2023, 10, 1),
      ),
    ];

    test('Scenario A: returns works from repository', () async {
      // arrange
      repositorySpy.getWorksResult = Right(tWorks);

      // act
      final result = await usecase();

      // assert
      expect(result, Right(tWorks));
    });

    test('Scenario B: returns empty list', () async {
      // arrange
      repositorySpy.getWorksResult = const Right(<Work>[]);

      // act
      final result = await usecase();

      // assert
      expect(result, const Right<Failure, List<Work>>([]));
    });

    test('Scenario C: propagates repository failure', () async {
      // arrange
      const tFailure = DatabaseFailure('Database error');
      repositorySpy.getWorksResult = const Left(tFailure);

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(tFailure));
    });

    test('Scenario D: calls repository exactly once', () async {
      // arrange
      repositorySpy.getWorksResult = const Right([]);

      // act
      await usecase();

      // assert
      expect(repositorySpy.getWorksCallCount, 1);
    });

    test('Scenario E: UseCase does not mutate returned collection', () async {
      // arrange
      repositorySpy.getWorksResult = Right(tWorks);

      // act
      final result = await usecase();

      // assert
      result.fold((failure) => fail('Should not return a failure'), (works) {
        expect(identical(works, tWorks), isTrue);
      });
    });
  });
}
