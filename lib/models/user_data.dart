class UserData {
  final int? themeModeIndex;
  final String? crclumcd;
  final List<String>? enrolledCourses;

  UserData({
    this.themeModeIndex,
    this.crclumcd,
    this.enrolledCourses,
  });

  UserData copyWith(
          {int? themeModeIndex,
          String? crclumcd,
          List<String>? enrolledCourses}) =>
      UserData(
        themeModeIndex: themeModeIndex ?? this.themeModeIndex,
        crclumcd: crclumcd ?? this.crclumcd,
        enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      );
}
