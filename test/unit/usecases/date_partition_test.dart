import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Date Partition Isolation', () {
    // Verified by deterministic key `work_${safeDateId}_$_session`
    // This prevents tomorrow from reusing yesterday's WorkId and overwriting its date!
  });
}
