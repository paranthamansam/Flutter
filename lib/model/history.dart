const String historyTable = "historyTable";

class History {
  int? id;
  DateTime startTime;
  DateTime endTime;
  String duration;
  Category category;
  History(
      {this.id,
      required this.startTime,
      required this.endTime,
      required this.duration,
      required this.category});

  static String getCategoryDisplayName(Category category) {
    String displayName;
    switch (category) {
      case Category.left:
        displayName = "Left";
        break;
      case Category.right:
        displayName = "Right";
        break;
      case Category.sleep:
        displayName = "Sleep";
        break;
      default:
        displayName = "---";
    }
    return displayName;
  }

  Map<String, Object?> toJson() => {
        HistoryField.id: id,
        HistoryField.start: startTime.toIso8601String(),
        HistoryField.end: endTime.toIso8601String(),
        HistoryField.duration: duration,
        HistoryField.category: getCategoryDisplayName(category),
      };

  History copy({
    int? id,
    DateTime? start,
    DateTime? end,
    String? duration,
    String? category,
  }) =>
      History(
          id: id ?? this.id,
          startTime: start ?? startTime,
          endTime: end ?? endTime,
          duration: duration ?? this.duration,
          category:
              category != null ? getHistoryEnum(category) : this.category);

  static Category getHistoryEnum(String category) {
    return Category.values.firstWhere(
        (e) => e.toString() == 'Category.${category.toLowerCase()}');
  }

  static History fromJson(Map<String, Object?> json) => History(
      id: json[HistoryField.id] as int,
      startTime: DateTime.parse(json[HistoryField.start] as String),
      endTime: DateTime.parse(json[HistoryField.end] as String),
      duration: json[HistoryField.duration] as String,
      category: getHistoryEnum(json[HistoryField.category] as String));
}

class HistoryField {
  static final List<String> values = [id, start, end, duration, category];
  static const String id = "id";
  static const String start = "start";
  static const String end = "end";
  static const String duration = "duration";
  static const String category = "category";
}

enum Category { none, left, right, sleep }
