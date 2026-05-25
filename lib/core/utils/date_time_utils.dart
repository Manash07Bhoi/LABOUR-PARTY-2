import 'package:intl/intl.dart';

class DateTimeUtils {
  static DateTime parseDate(String dateStr) {
    try {
      return DateFormat('dd MMM yyyy').parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  static String getCurrentDateFormatted([DateTime? now]) {
    final timeToUse = now ?? DateTime.now();
    return DateFormat('dd MMM yyyy').format(timeToUse);
  }

  static String getCurrentSession([DateTime? now]) {
    final timeToUse = now ?? DateTime.now();
    final hour = timeToUse.hour;
    if (hour >= 4 && hour < 12) {
      return 'Morning';
    } else {
      return 'Evening';
    }
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}
