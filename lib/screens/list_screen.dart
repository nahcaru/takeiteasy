import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import '../providers/course_list_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/choice_box.dart';
import '../widgets/course_card.dart';
import '../widgets/filters.dart';
import '../widgets/search_box.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  expandedHeight: isPortrait ? 136 : 56,
                  scrolledUnderElevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: isPortrait
                        ? Column(children: [
                            ChoiceBox(crclumcd: data.crclumcd),
                            const SizedBox(
                              height: 8,
                            ),
                            const SearchBox(),
                            const SizedBox(
                              height: 8,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Filters(
                                  crclumcd: data.crclumcd, isPortrait: true),
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
                                    ChoiceBox(crclumcd: data.crclumcd),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    const SearchBox(),
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
                    Row(
                      children: [
                        SizedBox(
                            width: 200,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: SingleChildScrollView(
                                  primary: false,
                                  child: Filters(
                                      crclumcd: data.crclumcd,
                                      isPortrait: false)),
                            )),
                        const VerticalDivider(
                          width: 0,
                        ),
                      ],
                    ),
                  Expanded(
                    child: courseList.isEmpty
                        ? Center(
                            child: data.crclumcd == null
                                ? const Text('カリキュラムを選択してください')
                                : const Text('該当する授業がありません'))
                        : ListView.builder(
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
