import 'package:flutter_test/flutter_test.dart';
import 'package:labour_party/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    group('getCurrentDateFormatted', () {
      test('formats normal date correctly', () {
        final date = DateTime(2023, 10, 15);
        expect(DateTimeUtils.getCurrentDateFormatted(date), '15 Oct 2023');
      });

      test('formats month boundaries correctly', () {
        final beginningOfMonth = DateTime(2024, 1, 1);
        expect(
          DateTimeUtils.getCurrentDateFormatted(beginningOfMonth),
          '01 Jan 2024',
        );

        final endOfMonth = DateTime(2024, 2, 29); // leap year
        expect(
          DateTimeUtils.getCurrentDateFormatted(endOfMonth),
          '29 Feb 2024',
        );
      });

      test('formats year boundaries correctly', () {
        final beginningOfYear = DateTime(2024, 1, 1);
        expect(
          DateTimeUtils.getCurrentDateFormatted(beginningOfYear),
          '01 Jan 2024',
        );

        final endOfYear = DateTime(2023, 12, 31);
        expect(DateTimeUtils.getCurrentDateFormatted(endOfYear), '31 Dec 2023');
      });

      test('adds leading zeros for single-digit days', () {
        final date = DateTime(2024, 5, 5);
        expect(DateTimeUtils.getCurrentDateFormatted(date), '05 May 2024');
      });

      test('returns deterministic output when specific date is provided', () {
        final date1 = DateTime(2022, 11, 20);
        final date2 = DateTime(2022, 11, 20);
        expect(
          DateTimeUtils.getCurrentDateFormatted(date1),
          DateTimeUtils.getCurrentDateFormatted(date2),
        );
      });
    });

    group('getCurrentSession', () {
      test('returns Morning for times between 04:00 and 11:59', () {
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 4, 0)),
          'Morning',
        ); // Boundary: exactly 04:00
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 8, 30)),
          'Morning',
        ); // Mid-morning
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 11, 59)),
          'Morning',
        ); // Boundary: exactly 11:59
      });

      test('returns Evening for times before 04:00', () {
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 0, 0)),
          'Evening',
        ); // Midnight
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 3, 59)),
          'Evening',
        ); // Boundary: right before morning
      });

      test('returns Evening for times at or after 12:00', () {
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 12, 0)),
          'Evening',
        ); // Boundary: exactly 12:00
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 17, 59)),
          'Evening',
        ); // Late afternoon
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 18, 0)),
          'Evening',
        ); // Evening
        expect(
          DateTimeUtils.getCurrentSession(DateTime(2024, 1, 1, 23, 59)),
          'Evening',
        ); // Boundary: right before midnight
      });
    });

    group('formatTime', () {
      test('formats AM times correctly', () {
        final time1 = DateTime(2024, 1, 1, 0, 0); // 12:00 AM
        expect(DateTimeUtils.formatTime(time1), '12:00 AM');

        final time2 = DateTime(2024, 1, 1, 9, 30); // 09:30 AM
        expect(DateTimeUtils.formatTime(time2), '09:30 AM');

        final time3 = DateTime(2024, 1, 1, 11, 59); // 11:59 AM
        expect(DateTimeUtils.formatTime(time3), '11:59 AM');
      });

      test('formats PM times correctly', () {
        final time1 = DateTime(2024, 1, 1, 12, 0); // 12:00 PM
        expect(DateTimeUtils.formatTime(time1), '12:00 PM');

        final time2 = DateTime(2024, 1, 1, 15, 45); // 03:45 PM
        expect(DateTimeUtils.formatTime(time2), '03:45 PM');

        final time3 = DateTime(2024, 1, 1, 23, 59); // 11:59 PM
        expect(DateTimeUtils.formatTime(time3), '11:59 PM');
      });

      test('adds leading zeros for hours correctly', () {
        final time1 = DateTime(2024, 1, 1, 1, 5); // 01:05 AM
        expect(DateTimeUtils.formatTime(time1), '01:05 AM');

        final time2 = DateTime(2024, 1, 1, 13, 10); // 01:10 PM
        expect(DateTimeUtils.formatTime(time2), '01:10 PM');
      });
    });
  });
}
