import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';

import '../models/course.dart';
import 'user_data_provider.dart';

final courseMap =
    AsyncNotifierProvider<CourseMapNotifier, Map<String, List<Course>>>(() {
  return CourseMapNotifier();
});

class CourseMapNotifier extends AsyncNotifier<Map<String, List<Course>>> {
  @override
  FutureOr<Map<String, List<Course>>> build() async {
    final Map<String, List<Course>> courses = {};
    final String jsonText = await rootBundle.loadString('assets/data.json');
    final Map<String, dynamic> jsonData = await json.decode(jsonText);
    for (String key in jsonData.keys) {
      courses[key] = [];
      for (Map<String, dynamic> element in jsonData[key]) {
        courses[key]!.add(Course.fromJson(element));
      }
    }
    return courses;
  }
}

final testNotifierProvider = NotifierProvider<TestNotifier, String>(() {
  return TestNotifier();
});

class TestNotifier extends Notifier<String> {
  @override
  String build() {
    final Map<String, List<Course>>? courses = ref.watch(courseMap).value;
    final String? crclumcd = ref.watch(userDataNotifierProvider
        .select((asyncValue) => asyncValue.value?.crclumcd));
    print('testNotifierProvider:${crclumcd ?? 'null'}');
    return crclumcd ?? 'null';
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
    final Map<String, List<Course>>? courses = ref.watch(courseMap).value;
    final String? crclumcd = ref.watch(userDataNotifierProvider
        .select((asyncValue) => asyncValue.value?.crclumcd));
    print('courseListNotifierProvider:${crclumcd ?? 'null'}');
    const Map<String, List<String>> codes = {
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
    return sortPeriods(_courseList);
  }

  List<Course> sortPeriods(List<Course> instances) {
    const daysOrder = ['月', '火', '水', '木', '金', '土', '日', ''];
    instances.sort((a, b) {
      String aPeriod = a.period.firstOrNull ?? '';
      String bPeriod = b.period.firstOrNull ?? '';
      if (aPeriod == '' && bPeriod == '') {
        return 0;
      } else if (aPeriod == '') {
        return 1;
      } else if (bPeriod == '') {
        return -1;
      } else {
        String aDay = aPeriod[0];
        String bDay = bPeriod[0];
        int dayComparison =
            daysOrder.indexOf(aDay).compareTo(daysOrder.indexOf(bDay));
        if (dayComparison != 0) {
          return dayComparison;
        } else {
          int aTime = int.tryParse(aPeriod[1]) ?? 0;
          int bTime = int.tryParse(bPeriod[1]) ?? 0;
          return aTime.compareTo(bTime);
        }
      }
    });

    return instances;
  }

  List<Course> suggestion(String text) {
    return _courseList
        .where(
            (course) => course.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  void search(String text) {
    state = suggestion(text);
  }

  void filter({
    required Map<String, bool> grades,
    required Map<String, bool> terms,
    required Map<String, bool> categories,
    required Map<String, bool> compulsorinesses,
  }) {
    state = _courseList.where((course) {
      bool gradeFilter = grades[course.grade.toString()] ?? false;
      bool termFilter = terms[course.term] ?? false;
      String? crclumcd = ref.watch(userDataNotifierProvider).value?.crclumcd;
      bool categoryFilter = categories[course.category[crclumcd]] ?? false;
      bool compulsorinessFilter =
          compulsorinesses[course.compulsoriness[crclumcd]] ?? false;
      return gradeFilter &&
          termFilter &&
          categoryFilter &&
          compulsorinessFilter;
    }).toList();
  }

  List<Course> getCoursesByCodes(List<String> codes) {
    return _courseList
        .where((element) => codes.contains(element.code))
        .toList();
  }

  List<Course> getCoursesByTerms(List<String> codes, List<String> terms) {
    return getCoursesByCodes(codes)
        .where((element) => terms.contains(element.term))
        .toList();
  }
}
