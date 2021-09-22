const String userTable = "User";

class UserField {
  static final List<String> values = [id, name, level];
  static const String id = "id";
  static const String name = "name";
  static const String level = "level";
}

class User {
  final int? id;
  final String name;
  final int level;

  const User({this.id, required this.name, required this.level});

  User copy({int? id, String? name, int? level}) => User(
      id: id ?? this.id, name: name ?? this.name, level: level ?? this.level);

  static User fromJson(Map<String, Object?> json) => User(
      id: json[UserField.id] as int,
      name: json[UserField.name] as String,
      level: json[UserField.level] as int);

  Map<String, Object?> toJson() =>
      {UserField.id: id, UserField.name: name, UserField.level: level};

  @override
  String toString() {
    return "User {id: $id, name: $name, level: $level}";
  }
}
