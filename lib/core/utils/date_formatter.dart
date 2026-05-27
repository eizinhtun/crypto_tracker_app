import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String readable(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    return DateFormat.yMMMd().add_jm().format(dateTime.toLocal());
  }
}
