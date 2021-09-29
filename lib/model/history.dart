class History {
  DateTime startTime;
  DateTime endTime;
  String duration;
  Category category;
  History(this.startTime, this.endTime, this.duration, this.category);

  String getCategoryDisplayName() {
    String displayName = "None";
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
        displayName = "Sleep";
    }
    return displayName;
  }
}

enum Category { none, left, right, sleep }
