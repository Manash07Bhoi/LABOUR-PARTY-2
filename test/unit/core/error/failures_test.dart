import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/core/error/failures.dart';

void main() {
  const tMessage = 'Test error message';
  const tDifferentMessage = 'Different error message';

  group('DatabaseFailure', () {
    test('props contains expected values', () {
      const failure = DatabaseFailure(tMessage);
      expect(failure.props, [tMessage]);
    });

    test('message property is stable (immutable representation)', () {
      const failure = DatabaseFailure(tMessage);
      expect(failure.message, tMessage);
    });
  });

  group('ValidationFailure', () {
    test('props contains expected values', () {
      const failure = ValidationFailure(tMessage);
      expect(failure.props, [tMessage]);
    });

    test('message property is stable (immutable representation)', () {
      const failure = ValidationFailure(tMessage);
      expect(failure.message, tMessage);
    });
  });

  group('Equality', () {
    test('returns equal when same type and same message', () {
      const failure1 = DatabaseFailure(tMessage);
      const failure2 = DatabaseFailure(tMessage);

      expect(failure1, equals(failure2));
    });

    test('returns not equal when same type but different messages', () {
      const failure1 = DatabaseFailure(tMessage);
      const failure2 = DatabaseFailure(tDifferentMessage);

      expect(failure1, isNot(equals(failure2)));
    });

    test('returns not equal when different types but same message', () {
      const dbFailure = DatabaseFailure(tMessage);
      const valFailure = ValidationFailure(tMessage);

      expect(dbFailure, isNot(equals(valFailure)));
    });
  });

  group('Hashing', () {
    test('identical hashCode when objects are equal', () {
      const failure1 = DatabaseFailure(tMessage);
      const failure2 = DatabaseFailure(tMessage);

      expect(failure1.hashCode, equals(failure2.hashCode));
    });

    test('different hashCode when objects are not equal', () {
      const failure1 = DatabaseFailure(tMessage);
      const failure2 = DatabaseFailure(tDifferentMessage);

      expect(failure1.hashCode, isNot(equals(failure2.hashCode)));
    });
  });
}
