class Course {
  final List<String> period;
  final String term;
  final int grade;
  final String class_;
  final String name;
  final List<String> lecturer;
  final String code;
  final List<String> room;
  final List<String> target;
  final bool early;
  final String altName;
  final List<String> altTarget;
  final Map<String, String> category;
  final Map<String, String> compulsory;
  final Map<String, double> credits;

  Course.fromJson(Map<String, dynamic> json)
      : period = List.from(json['period']),
        term = json['term'],
        grade = json['grade'],
        class_ = json['class'],
        name = json['name'],
        lecturer = List.from(json['lecturer']),
        code = json['code'],
        room = List.from(json['room']),
        target = List.from(json['target']),
        early = json['early'],
        altName = json['altName'],
        altTarget = List.from(json['altTarget']),
        category = Map.from(json['category']),
        compulsory = Map.from(json['compulsory']),
        credits = Map.from(json['credits']);
}
