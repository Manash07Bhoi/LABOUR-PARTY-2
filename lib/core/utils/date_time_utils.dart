import 'package:intl/intl.dart';

class DateTimeUtils {
  static String getCurrentDateFormatted() {
    return DateFormat('dd MMM yyyy').format(DateTime.now());
  }

  static String getCurrentSession() {
    final hour = DateTime.now().hour;
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
