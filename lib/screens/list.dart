import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import '../providers/course_list_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/filters.dart';

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});
  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  ButtonTheme _choiceBox(String? crclumcd) {
    const Map<String, String> options = {
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

  SearchAnchor _searchBox(
    List<Course> options,
  ) {
    final SearchController searchController = SearchController();
    return SearchAnchor.bar(
      searchController: searchController,
      onSubmitted: (value) {
        ref.read(courseListNotifierProvider.notifier).search(value);
        if (searchController.isOpen) {
          searchController.closeView(value);
        }
      },
      barHintText: '検索',
      barTrailing: [
        if (searchController.text.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                    searchController.clear();
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
                  searchController.closeView(course.name);
                },
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final List<Course> courseList = ref.watch(courseListNotifierProvider);
    final Size screenSize = MediaQuery.of(context).size;
    final bool isPortrait = ((screenSize.width - 280) / screenSize.height) < 1;
    return asyncValue.when(
        data: (data) => NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) => [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  toolbarHeight: 0,
                  expandedHeight: isPortrait ? 136 : 54,
                  scrolledUnderElevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: isPortrait
                        ? Column(children: [
                            _choiceBox(data.crclumcd),
                            const SizedBox(
                              height: 8,
                            ),
                            _searchBox(
                              courseList,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            const SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Filters(isPortrait: true),
                            ),
                          ])
                        : Align(
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _choiceBox(data.crclumcd),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    _searchBox(
                                      courseList,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
              body: Row(
                children: [
                  if (!isPortrait)
                    const Row(
                      children: [
                        SizedBox(
                            width: 200,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: SingleChildScrollView(
                                  primary: false,
                                  child: Filters(isPortrait: false)),
                            )),
                        VerticalDivider(
                          width: 0,
                        ),
                      ],
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: courseList.length,
                      itemBuilder: (BuildContext context, index) =>
                          CourseCard(course: courseList[index]),
                    ),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('ユーザーデータの取得に失敗しました')));
  }
}
