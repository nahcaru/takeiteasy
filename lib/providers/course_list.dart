import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import '../models/user_data.dart';

final courseMap =
    AsyncNotifierProvider<CourseMapNotifier, Map<String, List<Course>>>(() {
  return CourseMapNotifier();
});

class CourseMapNotifier extends AsyncNotifier<Map<String, List<Course>>> {
  @override
  FutureOr<Map<String, List<Course>>> build() async {
    Map<String, List<Course>> courses = {};
    String jsonText = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = await json.decode(jsonText);
    for (String key in jsonData.keys) {
      courses[key] = [];
      for (Map<String, dynamic> element in jsonData[key]) {
        courses[key]!.add(Course.fromJson(element));
      }
    }
    return courses;
  }
}

final courseListNotifierProvider =
    NotifierProvider<CourseListNotifier, List<Course>>(() {
  return CourseListNotifier();
});

class CourseListNotifier extends Notifier<List<Course>> {
  final List<Course> _courseList = [];
  @override
  List<Course> build() {
    _courseList.clear();
    Map<String, List<Course>>? courses = ref.watch(courseMap).value;
    String? crclumcd = ref.watch(userDataNotifierProvider).value?.crclumcd;
    Map<String, List<String>> codes = {
      '情科': [
        's21310',
        's21311',
        's22210',
        's22211',
        's23310',
        's23311',
        's24310',
        's24311'
      ],
      '知能': [
        's21320',
        's21321',
        's22220',
        's22221',
        's23320',
        's23321',
        's24320',
        's24321'
      ],
    };
    if (crclumcd != null && courses != null) {
      for (String key in codes.keys) {
        if (codes[key]!.contains(crclumcd)) {
          for (Course course in courses[key]!) {
            if (course.target.any((target) => crclumcd.startsWith(target))) {
              _courseList.add(course);
            }
          }
          for (Course course in courses['共通']!) {
            if (course.target.any((target) => crclumcd.startsWith(target))) {
              _courseList.add(course);
            }
          }
        }
      }
    }
    return _courseList;
  }

  void search(String text) {
    state = _courseList
        .where(
            (course) => course.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }
}
