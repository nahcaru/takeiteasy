class UserData {
  final int? themeModeIndex;
  final String? crclumcd;
  final List<String>? enrolledCourses;
  final Map<String, double>? tookCredits;

  UserData({
    this.themeModeIndex,
    this.crclumcd,
    this.enrolledCourses,
    this.tookCredits,
  });

  UserData copyWith(
          {int? themeModeIndex,
          String? crclumcd,
          List<String>? enrolledCourses,
          Map<String, double>? tookCredits}) =>
      UserData(
        themeModeIndex: themeModeIndex ?? this.themeModeIndex,
        crclumcd: crclumcd ?? this.crclumcd,
        enrolledCourses: enrolledCourses ?? this.enrolledCourses,
        tookCredits: tookCredits ?? this.tookCredits,
      );
}
