import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/link.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import '../providers/user_data_provider.dart';

class CourseDialog extends ConsumerWidget {
  final Course course;

  const CourseDialog(this.course, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final UserDataNotifier notifier =
        ref.read(userDataNotifierProvider.notifier);
    return asyncValue.when(
      data: (data) => AlertDialog(
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        title: Link(
          uri: Uri(
              scheme: 'https',
              host: 'websrv.tcu.ac.jp',
              path: '/tcu_web_v3/slbssbdr.do',
              queryParameters: {
                'value(risyunen)': '2024',
                'value(semekikn)': '1',
                'value(kougicd)': course.code,
                'value(crclumcd)': data.crclumcd,
              }),
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) => InkWell(
            onTap: followLink,
            child: Text(
              course.altTarget.any((target) =>
                      target != "" &&
                      (data.crclumcd?.startsWith(target) ?? false))
                  ? course.altName
                  : course.name,
            ),
          ),
        ),
        content: Align(
          alignment: Alignment.centerLeft,
          child: SelectionArea(
            child: Table(
              children: [
                TableRow(
                  children: [
                    const Text('学期'),
                    Text(course.term),
                  ],
                ),
                if (course.early)
                  const TableRow(
                    children: [
                      Text('9:00開始'),
                      Text('9:00 ～ 10:40'),
                    ],
                  ),
                TableRow(
                  children: [
                    const Text('曜日・時限'),
                    Text(course.period.join('\n')),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('対象学年'),
                    Text(course.grade.toString()),
                  ],
                ),
                if (course.class_ != "")
                  TableRow(
                    children: [
                      const Text('クラス'),
                      Text(course.class_),
                    ],
                  ),
                TableRow(
                  children: [
                    const Text('分類'),
                    Text(course.category[data.crclumcd] ?? '-'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('必修/選択'),
                    Text(course.compulsoriness[data.crclumcd] ?? '-'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('単位数'),
                    Text('${course.credits[data.crclumcd] ?? '-'}'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('担当者'),
                    Text(course.lecturer.join('\n')),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('講義コード'),
                    Text(course.code),
                  ],
                ),
                if (course.room.first != "")
                  TableRow(
                    children: [
                      const Text('教室'),
                      Text(course.room.join('\n')),
                    ],
                  ),
                if (course.note != "")
                  TableRow(
                    children: [
                      const Text('備考'),
                      Text(course.note),
                    ],
                  ),
              ],
            ),
          ),
        ),
        scrollable: true,
        actions: [
          (data.enrolledCourses?.contains(course.code) ?? false)
              ? TextButton(
                  onPressed: () {
                    notifier.removeCourse(course.code);
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                )
              : TextButton(
                  onPressed: () {
                    notifier.addCourse(course.code);
                    Navigator.of(context).pop();
                  },
                  child: const Text('登録'),
                ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
