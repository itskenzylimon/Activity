
class Task {
  String name;
  String body;
  int level;
  User user;

  Task({
    required this.name,
    required this.body,
    required this.level,
    required this.user,
  });

  Task.fromMap(Map<String?, dynamic> map)
      : name = map['name'],
        body = map['body'],
        level = map['level'],
        user = map['user'];

  Map<String, dynamic> toMap() => {
    'name': name,
    'body': body,
    'level': level,
    'user': user,
  };
}

class User {
  String name;
  String? email;

  User({
    required this.name,
    this.email,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
  };

}
