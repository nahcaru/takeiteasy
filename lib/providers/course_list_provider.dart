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
  bool _enrolledOnly = false;
  final Map<String, Map<String, bool>> _filters = {
    '学年': {'1年': false, '2年': false, '3年': false, '4年': false},
    '学期': {'前期前': false, '前期後': false, '前期': false, '前集中': false, '通年': false},
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
  bool _internationalSpecified = false;
  final List<String> _internationalSpecifiedCourses = const [
    'Test Taking Skills(3a)',
    'Test Taking Skills(3b)',
    'Critical Reading(2a)',
    'Critical Reading(2b)',
    'Critical Reading(3a)',
    'Critical Reading(3b)',
    'Critical Listening(2a)',
    'Critical Listening(2b)',
    'Critical Listening(3a)',
    'Critical Listening(3b)',
    'Communication Strategies(2a)',
    'Communication Strategies(2b)',
    'Communication Strategies(3a)',
    'Communication Strategies(3b)',
    'Academic English(2a)',
    'Academic English(2b)',
    'Academic English(3a)',
    'Academic English(3b)',
    'Global Culture(2a)',
    'Global Culture(2b)',
    'Language Sciences(2a)',
    'Language Sciences(2b)',
  ];
  bool _blankOnly = false;

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
            if (course.target
                .any((target) => target != '' && crclumcd.startsWith(target))) {
              _courses.add(course);
            }
          }
          for (Course course in courseMap['共通']!) {
            if (course.target
                .any((target) => target != '' && crclumcd.startsWith(target))) {
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
    const daysOrder = ['月', '火', '水', '木', '金', '土', ''];
    const termOrder = [
      '前期',
      '前期前',
      '前期後',
      '前集中',
      '後期',
      '後期前',
      '後期後',
      '後集中',
      '通年',
    ];
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
          int timeComparison = aTime.compareTo(bTime);
          if (timeComparison != 0) {
            return timeComparison;
          } else {
            return termOrder
                .indexOf(a.term)
                .compareTo(termOrder.indexOf(b.term));
          }
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

  void setEnrolledOnly(bool value) {
    _enrolledOnly = value;
  }

  void setInternationalSpecified(bool value) {
    _internationalSpecified = value;
  }

  void setBlankOnly(bool value) {
    _blankOnly = value;
  }

  void search(String text) {
    _searchText = text;
    applyFilter();
  }

  void setFilters(Map<String, Map<String, bool>> filters) {
    _filters.clear();
    _filters.addAll(filters);
  }

  void applyFilter() {
    state = filter();
  }

  List<Course> filter() {
    List<Course> targetCourses = suggestion(_searchText);
    if (_enrolledOnly) {
      List<String>? enrolledCourses = ref.watch(userDataNotifierProvider
          .select((asyncValue) => asyncValue.value?.enrolledCourses));
      targetCourses = targetCourses
          .where((course) => enrolledCourses?.contains(course.code) ?? false)
          .toList();
    }
    List<String>? enrolledCourses = ref.watch(userDataNotifierProvider
        .select((asyncValue) => asyncValue.value?.enrolledCourses));
    List<String> formerTerms = const ['前期', '前期前', '後期', '後期前'];
    List<String> latterTerms = const ['前期', '前期後', '後期', '後期後'];
    Set<String>? formerEnrolledPeriods =
        getCoursesByTerms(enrolledCourses ?? [], formerTerms)
            .map((course) => course.period)
            .expand((element) => element)
            .toSet();
    Set<String>? latterEnrolledPeriods =
        getCoursesByTerms(enrolledCourses ?? [], latterTerms)
            .map((course) => course.period)
            .expand((element) => element)
            .toSet();
    if (_blankOnly) {
      targetCourses = targetCourses.where((course) {
        if (formerTerms.contains(course.term)) {
          return course.period
              .every((period) => !formerEnrolledPeriods.contains(period));
        } else if (latterTerms.contains(course.term)) {
          return course.period
              .every((period) => !latterEnrolledPeriods.contains(period));
        } else {
          return true;
        }
      }).toList();
    }
    if (_internationalSpecified) {
      targetCourses = targetCourses
          .where(
              (course) => _internationalSpecifiedCourses.contains(course.name))
          .toList();
    }
    return targetCourses.where((course) {
      bool gradeFilter = (_filters['学年']!['${course.grade}年'] ?? false) ||
          _filters['学年']!.values.every((element) => element == false);
      bool termFilter = (_filters['学期']![course.term] ?? false) ||
          _filters['学期']!.values.every((element) => element == false);
      String? crclumcd = ref.watch(userDataNotifierProvider
          .select((asyncValue) => asyncValue.value?.crclumcd));
      bool categoryFilter =
          (_filters['分類']![course.category[crclumcd]] ?? false) ||
              _filters['分類']!.values.every((element) => element == false);
      bool compulsorinessFilter;
      if (course.compulsoriness[crclumcd] == '必修') {
        compulsorinessFilter = _filters['必選']!['必修']!;
      } else if (course.compulsoriness[crclumcd]?.contains('選択必修') ?? false) {
        compulsorinessFilter = _filters['必選']!['選択必修']!;
      } else if (course.compulsoriness[crclumcd] != null) {
        compulsorinessFilter = _filters['必選']!['選択']!;
      } else {
        compulsorinessFilter = false;
      }
      compulsorinessFilter = compulsorinessFilter ||
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
