class Course {
  String name;
  String code;
  String classs;
  String teacher;
  String room;
  String term;
  String period;
  dynamic credits;
  int grade;
  String category;
  String target;
  String about;
  bool enrolled = false;
  bool visible = true;

  Course.fromJson(Map<String, dynamic> json)
      : name = json['科目名'],
        code = json['講義コード'],
        classs = json['クラス'],
        teacher = json['担当者'],
        room = json['教室'],
        term = json['学期'],
        period = json['時限'],
        credits = json['単位数'],
        grade = json['年'],
        category = json['分類'],
        target = json['受講対象/再履修者科目名'],
        about = json['概要'];
}

// class CourseList {
//   List<Course> courses = [];

//   void addCourse(Course course) {
//     courses.add(course);
//   }

//   void removeCourse(Course course) {
//     courses.remove(course);
//   }
// }
