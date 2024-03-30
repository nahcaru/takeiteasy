import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import '../providers/course_list_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/credits_table.dart';
import '../widgets/time_table.dart';

class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isPortrait = ((screenSize.width - 80) / screenSize.height) < 1;
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final CourseListNotifier notifier =
        ref.read(courseListNotifierProvider.notifier);
    return asyncValue.when(
      data: (data) => Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TimeTable(isPortrait: isPortrait),
                  const SizedBox(
                    height: 16,
                  ),
                  isPortrait
                      ? Column(
                          children: [
                            CourseTable(
                                title: '前半',
                                courses: notifier.getCoursesByTerms(
                                    data.enrolledCourses ?? [],
                                    const ['前期', '前期前', '後期', '後期前'])),
                            const SizedBox(
                              height: 16,
                            ),
                            CourseTable(
                                title: '後半',
                                courses: notifier.getCoursesByTerms(
                                    data.enrolledCourses ?? [],
                                    const ['前期', '前期後', '後期', '後期後'])),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: CourseTable(
                                  title: '前半',
                                  courses: notifier.getCoursesByTerms(
                                      data.enrolledCourses ?? [],
                                      const ['前期', '前期前', '後期', '後期前'])),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: CourseTable(
                                  title: '後半',
                                  courses: notifier.getCoursesByTerms(
                                      data.enrolledCourses ?? [],
                                      const ['前期', '前期後', '後期', '後期後'])),
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 16,
                  ),
                  isPortrait
                      ? Column(
                          children: [
                            CourseWrap(
                                title: '通年・集中',
                                courses: notifier.getCoursesByTerms(
                                    data.enrolledCourses ?? [],
                                    const ['通年', '前集中', '後集中'])),
                            const SizedBox(
                              height: 16,
                            ),
                            CreditsTable(
                                data: notifier.getCoursesByCodes(
                                    data.enrolledCourses ?? [])),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: CourseWrap(
                                  title: '通年・集中',
                                  courses: notifier.getCoursesByTerms(
                                      data.enrolledCourses ?? [],
                                      const ['通年', '前集中', '後集中'])),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: CreditsTable(
                                    data: notifier.getCoursesByCodes(
                                        data.enrolledCourses ?? []))),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
