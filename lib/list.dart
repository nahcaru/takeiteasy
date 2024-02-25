import 'package:flutter/services.dart' show rootBundle;
import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Filter;
import 'package:firebase_auth/firebase_auth.dart';
import 'filter.dart';
import 'card.dart';
import 'course.dart';

class ListPage extends StatefulWidget {
  //const ListPage({super.key, required this.courseList});
  const ListPage({super.key, required this.crclumcd});
  @override
  State<ListPage> createState() => _ListPageState();
  final String? crclumcd;
}

class _ListPageState extends State<ListPage> {
  Map<String, List<Course>> courses = {};
  List<Course> filtered = [];
  String? crclumcd;
  final List<FilterOption> grades = [
    FilterOption(name: '1'),
    FilterOption(name: '2'),
    FilterOption(name: '3'),
    FilterOption(name: '4')
  ];
  final List<FilterOption> terms = [
    FilterOption(name: '後期前'),
    FilterOption(name: '後期後'),
    FilterOption(name: '後期'),
    FilterOption(name: '後集中'),
    FilterOption(name: '通年')
  ];
  final List<FilterOption> categories = [
    FilterOption(name: '教養'),
    FilterOption(name: '体育'),
    FilterOption(name: '外国語'),
    FilterOption(name: 'PBL'),
    FilterOption(name: '情報工学基盤'),
    FilterOption(name: '専門'),
    FilterOption(name: '教職'),
    FilterOption(name: 'その他')
  ];
  final List<FilterOption> compulsories = [
    FilterOption(name: '必修'),
    FilterOption(name: '選択必修'),
    FilterOption(name: '選択')
  ];

  @override
  void initState() {
    super.initState();
    if (widget.crclumcd != null) {
      crclumcd = widget.crclumcd;
    }
    loadJson();
  }

  Future<void> loadJson() async {
    String jsonText = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = await json.decode(jsonText);
    for (String key in jsonData.keys) {
      courses[key] = [];
      for (var element in jsonData[key]) {
        courses[key]!.add(Course.fromJson(element));
      }
    }
  }

  void filterCourse() {
    filtered = [];
    Map<String, dynamic> codes = {
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

    if (crclumcd != null) {
      for (String key in codes.keys) {
        if (codes[key]!.contains(crclumcd)) {
          for (Course course in courses[key]!) {
            if (course.target.any((target) => crclumcd!.startsWith(target))) {
              filtered.add(course);
            }
          }
          for (Course course in courses['共通']!) {
            if (course.target.any((target) => crclumcd!.startsWith(target))) {
              filtered.add(course);
            }
          }
        }
      }
    }
  }
  // void filterData() {
  //   filtered = data.where((item) {
  //     if (departmentFilter.isItemSelected(item['学科']) != true) {
  //       return false;
  //     }
  //     if (areGradesSelected[grades.indexOf(item['年'].toString())] != true) {
  //       return false;
  //     }
  //     if (item['学期'] != '') {
  //       if (areTermsSelected[terms.indexOf(item['学期'])] != true) {
  //         return false;
  //       }
  //     }
  //     bool matched = false;
  //     for (int i = 0; i < categories.length - 1; i++) {
  //       if (item['分類'].toString().contains(categories[i])) {
  //         matched = true;
  //         if (!areCategoriesSelected[i]) {
  //           return false;
  //         }
  //       }
  //     }
  //     if (!areCategoriesSelected.last) {
  //       if (!matched) {
  //         return false;
  //       }
  //     }

  //     matched = false;
  //     for (int i = compulsories.length - 2; 0 <= i; i--) {
  //       if (item['分類'].toString().contains(compulsories[i])) {
  //         matched = true;
  //         if (!areCompulsoriesSelected[i]) {
  //           return false;
  //         }
  //       }
  //     }
  //     if (!areCompulsoriesSelected.last) {
  //       if (!matched) {
  //         return false;
  //       }
  //     }

  //     if (!item['科目名']
  //         .toLowerCase()
  //         .toString()
  //         .contains(_searchController.text.toLowerCase())) {
  //       return false;
  //     }
  //     return true;
  //   }).toList();
  //   setState(() {});
  // }

  ChoiceBox _choiceBox() {
    return ChoiceBox(
        options: const [
          {'name': '情科21(一般)', 'code': 's21310'},
          {'name': '情科21(国際)', 'code': 's21311'},
          {'name': '情科22(一般)', 'code': 's22210'},
          {'name': '情科22(国際)', 'code': 's22211'},
          {'name': '情科23(一般)', 'code': 's23310'},
          {'name': '情科23(国際)', 'code': 's23311'},
          {'name': '情科24(一般)', 'code': 's24310'},
          {'name': '情科24(国際)', 'code': 's24311'},
          {'name': '知能21(一般)', 'code': 's21320'},
          {'name': '知能21(国際)', 'code': 's21321'},
          {'name': '知能22(一般)', 'code': 's22220'},
          {'name': '知能22(国際)', 'code': 's22221'},
          {'name': '知能23(一般)', 'code': 's23320'},
          {'name': '知能23(国際)', 'code': 's23321'},
          {'name': '知能24(一般)', 'code': 's24320'},
          {'name': '知能24(国際)', 'code': 's24321'},
        ],
        onSelected: (code) {
          setState(() {
            crclumcd = code;
          });
          filterCourse();
        });
  }

  Row _filters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('学年'),
        FilterButton(
            options: grades,
            onChanged: (bool? value) {
              filterCourse();
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('学期'),
        FilterButton(
            options: terms,
            onChanged: (bool? value) {
              filterCourse();
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('分類'),
        FilterButton(
            options: categories,
            onChanged: (bool? value) {
              filterCourse();
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('必選'),
        FilterButton(
            options: compulsories,
            onChanged: (bool? value) {
              filterCourse();
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool portrait = (screenSize.width / screenSize.height) < 1;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          toolbarHeight: 0,
          expandedHeight: portrait ? 140 : 60,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: portrait
                ? Column(children: [
                    _choiceBox(),
                    const SizedBox(
                      height: 10,
                    ),
                    SearchBox(
                      options: filtered,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _filters(),
                    ),
                  ])
                : Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _choiceBox(),
                            const SizedBox(
                              width: 20,
                            ),
                            SearchBox(
                              options: filtered,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            _filters(),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CourseCard(
                course: filtered[index],
                crclumcd: crclumcd,
              ),
            ),
            childCount: filtered.length,
          ),
        ),
      ],
    );
  }
}
