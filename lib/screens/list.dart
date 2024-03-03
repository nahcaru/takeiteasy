import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import '../widgets/filter.dart';
import '../widgets/card.dart';
import '../models/course.dart';
import '../providers/course_list.dart';

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});
  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  final SearchController _searchController = SearchController();
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

  ButtonTheme _choiceBox(String? crclumcd) {
    Map<String, String> options = {
      '情科21(一般)': 's21310',
      '情科21(国際)': 's21311',
      '情科22(一般)': 's22210',
      '情科22(国際)': 's22211',
      '情科23(一般)': 's23310',
      '情科23(国際)': 's23311',
      '情科24(一般)': 's24310',
      '情科24(国際)': 's24311',
      '知能21(一般)': 's21320',
      '知能21(国際)': 's21321',
      '知能22(一般)': 's22220',
      '知能22(国際)': 's22221',
      '知能23(一般)': 's23320',
      '知能23(国際)': 's23321',
      '知能24(一般)': 's24320',
      '知能24(国際)': 's24321'
    };
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownMenu<String>(
        initialSelection: crclumcd,
        menuHeight: 300,
        onSelected: (value) {
          if (value != null) {
            ref.read(userDataNotifierProvider.notifier).setCrclumcd(value);
          }
        },
        hintText: 'カリキュラム',
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          isCollapsed: true,
          border: OutlineInputBorder(),
          constraints: BoxConstraints(maxHeight: 40),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        dropdownMenuEntries: options.entries
            .map((option) => DropdownMenuEntry<String>(
                value: option.value, label: option.key))
            .toList(),
      ),
    );
  }

  SearchAnchor _searchBox(List<Course> options) {
    return SearchAnchor.bar(
      searchController: _searchController,
      onSubmitted: (value) {
        ref.read(courseListNotifierProvider.notifier).search(value);
        if (_searchController.isOpen) {
          _searchController.closeView(value);
        }
      },
      barHintText: '検索',
      barTrailing: [
        if (_searchController.text.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                    _searchController.clear();
                  }))
      ],
      constraints: const BoxConstraints(
        minHeight: 40,
        maxWidth: 300,
      ),
      suggestionsBuilder: (context, controller) => options
          .where((course) =>
              course.name.toLowerCase().contains(controller.text.toLowerCase()))
          .map((course) => ListTile(
                title: Text(course.name),
                onTap: () {
                  ref
                      .read(courseListNotifierProvider.notifier)
                      .search(course.name);

                  _searchController.closeView(course.name);
                },
              ))
          .toList(),
    );
  }

  Row _filters(String? crclumcd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('学年'),
        FilterButton(
            options: grades,
            onChanged: (bool? value) {
              //filterCourse(crclumcd);
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('学期'),
        FilterButton(
            options: terms,
            onChanged: (bool? value) {
              //filterCourse(crclumcd);
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('分類'),
        FilterButton(
            options: categories,
            onChanged: (bool? value) {
              //filterCourse(crclumcd);
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('必選'),
        FilterButton(
            options: compulsories,
            onChanged: (bool? value) {
              //filterCourse(crclumcd);
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserData> userDataAsyncValue =
        ref.watch(userDataNotifierProvider);
    final List<Course> courseList = ref.watch(courseListNotifierProvider);
    final Size screenSize = MediaQuery.of(context).size;
    final bool portrait = (screenSize.width / screenSize.height) < 1;
    return userDataAsyncValue.when(
        data: (data) => CustomScrollView(
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
                            _choiceBox(data.crclumcd),
                            const SizedBox(
                              height: 10,
                            ),
                            _searchBox(
                              courseList,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _filters(data.crclumcd),
                            ),
                          ])
                        : Align(
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _choiceBox(data.crclumcd),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    _searchBox(
                                      courseList,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    _filters(data.crclumcd),
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
                        course: courseList[index],
                      ),
                    ),
                    childCount: courseList.length,
                  ),
                ),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('ユーザーデータの取得に失敗しました')));
  }
}
