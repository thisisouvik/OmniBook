String formatMoney(num value) {
  return '\$${value.toStringAsFixed(0)}';
}

String formatDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes mins';
  }
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  if (remaining == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remaining}m';
}

String formatTime(DateTime time) {
  var hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) {
    hour = 12;
  }
  return '$hour:$minute $suffix';
}

String formatDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String weekdayShort(int weekday) {
  const values = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return values[weekday - 1];
}
