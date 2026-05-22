import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:labour_party/core/database/hive_setup.dart';
import 'package:labour_party/features/work/data/datasources/work_local_data_source.dart';
import 'package:labour_party/features/work/data/models/labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_labour_model.dart';
import 'package:labour_party/features/work/data/models/trip_model.dart';
import 'package:labour_party/features/work/data/models/work_model.dart';
import 'package:labour_party/features/work/data/repositories/work_repository_impl.dart';
import 'package:labour_party/features/work/domain/repositories/work_repository.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:labour_party/features/work/presentation/bloc/work_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(
    () => WorkBloc(
      getWorks: sl(),
      getWorkByDateAndSession: sl(),
      saveWork: sl(),
      getTripsForWork: sl(),
      saveTrip: sl(),
      deleteTrip: sl(),
      getLaboursForTrip: sl(),
      calculateNextTripNumber: sl(),
      saveTripLabour: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetWorksUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkByDateAndSessionUseCase(sl()));
  sl.registerLazySingleton(() => SaveWorkUseCase(sl()));
  sl.registerLazySingleton(() => GetTripsForWorkUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTripsUseCase(sl()));
  sl.registerLazySingleton(() => SaveTripUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTripUseCase(sl()));
  sl.registerLazySingleton(() => GetLaboursUseCase(sl()));
  sl.registerLazySingleton(() => SaveLabourUseCase(sl()));
  sl.registerLazySingleton(() => GetLaboursForTripUseCase(sl()));
  sl.registerLazySingleton(() => SaveTripLabourUseCase(sl()));
  sl.registerLazySingleton(() => CalculateNextTripNumberUseCase(sl()));

  // Repository
  sl.registerLazySingleton<WorkRepository>(
    () => WorkRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WorkLocalDataSource>(
    () => WorkLocalDataSourceImpl(
      workBox: sl(),
      tripBox: sl(),
      labourBox: sl(),
      tripLabourBox: sl(),
    ),
  );

  // Core - External
  sl.registerLazySingleton<Box<WorkModel>>(
    () => Hive.box<WorkModel>(HiveSetup.workBox),
  );
  sl.registerLazySingleton<Box<TripModel>>(
    () => Hive.box<TripModel>(HiveSetup.tripBox),
  );
  sl.registerLazySingleton<Box<LabourModel>>(
    () => Hive.box<LabourModel>(HiveSetup.labourBox),
  );
  sl.registerLazySingleton<Box<TripLabourModel>>(
    () => Hive.box<TripLabourModel>(HiveSetup.tripLabourBox),
  );
}
