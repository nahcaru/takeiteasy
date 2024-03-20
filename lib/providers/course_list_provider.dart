import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import 'user_data_provider.dart';

final courseMapNotifierProvider =
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

final courseListNotifierProvider =
    NotifierProvider<CourseListNotifier, List<Course>>(() {
  return CourseListNotifier();
});

class CourseListNotifier extends Notifier<List<Course>> {
  final List<Course> _courses = [];
  String _searchText = '';
  final Map<String, Map<String, bool>> _filters = {
    '学年': {'1年': false, '2年': false, '3年': false, '4年': false},
    '学期': {'後期前': false, '後期後': false, '後期': false, '後集中': false, '通年': false},
    '分類': {
      '教養科目': false,
      '体育科目': false,
      '外国語科目': false,
      'PBL科目': false,
      '情報工学基盤': false,
      '専門': false,
      '教職科目': false,
    },
    '必選': {'必修': false, '選択必修': false, '選択': false}
  };

  @override
  List<Course> build() {
    _courses.clear();
    final Map<String, List<Course>>? courseMap =
        ref.watch(courseMapNotifierProvider).value;
    final String? crclumcd = ref.watch(userDataNotifierProvider
        .select((asyncValue) => asyncValue.value?.crclumcd));
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
    if (crclumcd != null && courseMap != null) {
      for (String key in codes.keys) {
        if (codes[key]!.contains(crclumcd)) {
          for (Course course in courseMap[key]!) {
            if (course.target.any((target) => crclumcd.startsWith(target))) {
              _courses.add(course);
            }
          }
          for (Course course in courseMap['共通']!) {
            if (course.target.any((target) => crclumcd.startsWith(target))) {
              _courses.add(course);
            }
          }
        }
      }
    }
    sortPeriods();
    return filter();
  }

  void sortPeriods() {
    const daysOrder = ['月', '火', '水', '木', '金', '土', '日', ''];
    _courses.sort((a, b) {
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
  }

  List<Course> suggestion(String text) {
    return _courses
        .where(
            (course) => course.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  void search(String text) {
    _searchText = text;
    state = filter();
  }

  void setFilters(Map<String, Map<String, bool>> filters) {
    _filters.clear();
    _filters.addAll(filters);
    state = filter();
  }

  List<Course> filter() {
    return suggestion(_searchText).where((course) {
      bool gradeFilter = _filters['学年']!['${course.grade}年']! ||
          _filters['学年']!.values.every((element) => element == false);
      bool termFilter = _filters['学期']![course.term]! ||
          _filters['学期']!.values.every((element) => element == false);
      String? crclumcd = ref.watch(userDataNotifierProvider
          .select((asyncValue) => asyncValue.value?.crclumcd));
      bool categoryFilter =
          (_filters['分類']![course.category[crclumcd]] ?? false) ||
              _filters['分類']!.values.every((element) => element == false);
      bool compulsorinessFilter =
          (_filters['必選']![course.compulsoriness[crclumcd]] ?? false) ||
              _filters['必選']!.values.every((element) => element == false);
      return gradeFilter &&
          termFilter &&
          categoryFilter &&
          compulsorinessFilter;
    }).toList();
  }

  List<Course> getCoursesByCodes(List<String> codes) {
    return _courses.where((element) => codes.contains(element.code)).toList();
  }

  List<Course> getCoursesByTerms(List<String> codes, List<String> terms) {
    return getCoursesByCodes(codes)
        .where((element) => terms.contains(element.term))
        .toList();
  }
}
