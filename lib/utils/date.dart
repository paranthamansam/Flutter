class Date {
  static String duration(DateTime startTime, DateTime endTime) {
    var difference = endTime.difference(startTime);
    return difference.inHours.toString().padLeft(2, '0') +
        ":" +
        (difference.inMinutes % 60).toString().padLeft(2, '0') +
        ":" +
        (difference.inSeconds % 60).toString().padLeft(2, '0');
  }
}
