import sys

def process(content):
    # Oh! `MockWorkRepository`'s `saveTripLabours` does:
    # tripLabours.removeWhere((tl) => tl.tripId == tripId);
    # which deletes all old ones locally!
    # So if we do a soft delete `saveTripLabour` and then `saveTripLabours`, the second one wipes the first one out!
    # Let's fix MockWorkRepository to be like Hive: putAll updates existing or inserts new, it doesn't wipe others.
    
    search_str = """  Future<Either<Failure, void>> saveTripLabours(
    List<TripLabour> newTripLabours,
  ) async {
    if (newTripLabours.isNotEmpty) {
      final tripId = newTripLabours.first.tripId;
      tripLabours.removeWhere((tl) => tl.tripId == tripId);
    }
    for (var tl in newTripLabours) {
      tripLabours.removeWhere((existing) => existing.id == tl.id);
      tripLabours.add(tl);
    }
    return const Right(null);
  }"""
    
    replacement = """  Future<Either<Failure, void>> saveTripLabours(
    List<TripLabour> newTripLabours,
  ) async {
    for (var tl in newTripLabours) {
      tripLabours.removeWhere((existing) => existing.id == tl.id);
      tripLabours.add(tl);
    }
    return const Right(null);
  }"""
    
    if search_str in content:
        content = content.replace(search_str, replacement)
    
    return content

with open("test/helpers/mock_work_repository.dart", "r") as f:
    content = f.read()

new_content = process(content)

with open("test/helpers/mock_work_repository.dart", "w") as f:
    f.write(new_content)
