class Course {
  String name;
  String period;
  String credits;
  int targetGrade;
  String category;
  bool enrolled = false;
  bool visible = true;

  Course.fromJson(Map<String, dynamic> json)
      : name = json['科目名'],
        period = json['時限'],
        credits = json['単位数'],
        targetGrade = json['年'],
        category = json['分類'];
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
