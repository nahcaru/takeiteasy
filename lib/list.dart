import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Filter;
import 'package:firebase_auth/firebase_auth.dart';
import 'filter.dart';
import 'dropdown.dart';
import 'card.dart';
import 'course.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.courseList});
  @override
  State<ListPage> createState() => _ListPageState();
  final List<Course> courseList;
}

class _ListPageState extends State<ListPage> {
  List<String> tookClasses = [];
  final List<ChoiceOption> curriculums = [
    ChoiceOption(name: '情科21(一般)', code: 's21210'),
    ChoiceOption(name: '情科21(国際)', code: 's21211'),
    ChoiceOption(name: '情科22(一般)', code: 's22210'),
    ChoiceOption(name: '情科22(国際)', code: 's22211'),
    ChoiceOption(name: '情科23(一般)', code: 's23210'),
    ChoiceOption(name: '情科23(国際)', code: 's23211'),
    ChoiceOption(name: '情科24(一般)', code: 's24210'),
    ChoiceOption(name: '情科24(国際)', code: 's24211'),
    ChoiceOption(name: '知能21(一般)', code: 's21220'),
    ChoiceOption(name: '知能21(国際)', code: 's21221'),
    ChoiceOption(name: '知能22(一般)', code: 's22220'),
    ChoiceOption(name: '知能22(国際)', code: 's22221'),
    ChoiceOption(name: '知能23(一般)', code: 's23220'),
    ChoiceOption(name: '知能23(国際)', code: 's23221'),
    ChoiceOption(name: '知能24(一般)', code: 's24220'),
    ChoiceOption(name: '知能24(国際)', code: 's24221'),
  ];
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
  final String urlString =
      'https://websrv.tcu.ac.jp/tcu_web_v3/slbssbdr.do?value%28risyunen%29=2023&value%28semekikn%29=1&value%28kougicd%29=';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Course> filtered() {
    return widget.courseList.where((item) {
      if (grades.firstWhere((element) {
            return element.name == item.grade.toString();
          }).value ==
          false) {
        return false;
      }
      if (item.term != '') {
        if (terms.firstWhere((element) {
              return element.name == item.term;
            }).value ==
            false) {
          return false;
        }
      }
      return true;
    }).toList();
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

  Row filters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('学年'),
        FilterButton(
            options: grades,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('学期'),
        FilterButton(
            options: terms,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('分類'),
        FilterButton(
            options: categories,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('必選'),
        FilterButton(
            options: compulsories,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
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
                    ChoiceBox(options: curriculums, onSelected: (code) {}),
                    const SizedBox(
                      height: 10,
                    ),
                    SearchBox(
                      options: widget.courseList,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: filters(),
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
                            ChoiceBox(
                                options: curriculums, onSelected: (code) {}),
                            const SizedBox(
                              width: 20,
                            ),
                            SearchBox(
                              options: widget.courseList,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            filters(),
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
              child: CourseCard(course: filtered()[index]),
            ),
            childCount: filtered().length,
          ),
        ),
      ],
    );
  }
}
