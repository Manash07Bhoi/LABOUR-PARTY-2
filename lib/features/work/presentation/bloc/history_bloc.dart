import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labour_party/features/work/domain/entities/trip.dart';
import 'package:labour_party/features/work/domain/entities/work.dart';
import 'package:labour_party/features/work/domain/usecases/work_usecases.dart';
import 'package:labour_party/features/work/presentation/bloc/history_event.dart';
import 'package:labour_party/features/work/presentation/bloc/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetWorksUseCase getWorks;
  final GetTripsForWorkUseCase getTripsForWork;

  HistoryBloc({required this.getWorks, required this.getTripsForWork})
    : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    final worksResult = await getWorks();

    await worksResult.fold(
      (failure) async => emit(const HistoryError('Failed to load history')),
      (works) async {
        if (works.isEmpty) {
          emit(HistoryEmpty());
          return;
        }

        Map<String, Map<String, List<Trip>>> grouped = {};
        Map<String, Work> worksMap = {};
        int totalTrips = 0;

        // Grouping: Date -> Session -> Trips
        for (var work in works) {
          worksMap[work.id] = work;

          final tripsResult = await getTripsForWork(work.id);
          tripsResult.fold((f) {}, (trips) {
            if (trips.isNotEmpty) {
              totalTrips += trips.length;
              if (!grouped.containsKey(work.date)) {
                grouped[work.date] = {};
              }
              if (!grouped[work.date]!.containsKey(work.session)) {
                grouped[work.date]![work.session] = [];
              }
              grouped[work.date]![work.session]!.addAll(trips);
            }
          });
        }

        if (totalTrips == 0) {
          emit(HistoryEmpty());
        } else {
          emit(HistoryLoaded(groupedTrips: grouped, worksMap: worksMap));
        }
      },
    );
  }
}
