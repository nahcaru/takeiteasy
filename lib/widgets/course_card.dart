import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/link.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import '../providers/user_data_provider.dart';
import '../widgets/course_dialog.dart';

class CourseCard extends ConsumerWidget {
  const CourseCard({super.key, required this.course});
  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final UserDataNotifier notifier =
        ref.read(userDataNotifierProvider.notifier);
    final Size screenSize = MediaQuery.of(context).size;
    final bool isPortrait = ((screenSize.width - 280) / screenSize.height) < 1;
    return asyncValue.when(
      data: (data) => InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CourseDialog(course);
            },
          );
        },
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: isPortrait
                    ? [
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${course.term} ${course.period.join(',')} ${course.class_}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Link(
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
                                builder: (BuildContext context,
                                        FollowLink? followLink) =>
                                    InkWell(
                                  onTap: followLink,
                                  child: Text(
                                    course.altTarget.any((target) =>
                                            target != "" &&
                                            (data.crclumcd
                                                    ?.startsWith(target) ??
                                                false))
                                        ? course.altName
                                        : course.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  if (course.early || course.note != '')
                                    Text(
                                      '(',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  if (course.early)
                                    Text(
                                      '9:00開始',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  if (course.note != '')
                                    Text(
                                      course.note,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  if (course.early || course.note != '')
                                    Text(
                                      ')',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Text(
                                    course.category[data.crclumcd] != null
                                        ? '${course.category[data.crclumcd]}・${course.compulsoriness[data.crclumcd]} ${course.credits[data.crclumcd] ?? '-'}単位'
                                        : 'シラバス未公開',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        (data.enrolledCourses?.contains(course.code) ?? false)
                            ? IconButton.outlined(
                                onPressed: () =>
                                    notifier.removeCourse(course.code),
                                icon: const Icon(Icons.playlist_add_check),
                              )
                            : IconButton.filled(
                                onPressed: () =>
                                    notifier.addCourse(course.code),
                                icon: const Icon(Icons.playlist_add_outlined),
                              ),
                      ]
                    : [
                        SizedBox(
                          width: 64,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.term,
                              ),
                              Text(
                                course.period.join(','),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(flex: 1, child: Container()),
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              course.class_ != ''
                                  ? Text(
                                      course.class_,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    )
                                  : const SizedBox(
                                      height: 16,
                                    ),
                              Link(
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
                                builder: (BuildContext context,
                                        FollowLink? followLink) =>
                                    InkWell(
                                  onTap: followLink,
                                  child: Text(
                                    course.altTarget.any((target) =>
                                            target != "" &&
                                            (data.crclumcd
                                                    ?.startsWith(target) ??
                                                false))
                                        ? course.altName
                                        : course.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  if (course.early || course.note != '')
                                    Text(
                                      '(',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  if (course.early)
                                    Text(
                                      '9:00開始',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  if (course.early && course.note != '')
                                    const SizedBox(
                                      width: 8,
                                    ),
                                  if (course.note != '')
                                    Text(
                                      course.note,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  if (course.early || course.note != '')
                                    Text(
                                      ')',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  if (!course.early && course.note == '')
                                    const SizedBox(height: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.category[data.crclumcd] ?? 'シラバス',
                              ),
                              Text(
                                course.compulsoriness[data.crclumcd] ?? '未公開',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${course.credits[data.crclumcd] ?? '-'}単位',
                            ),
                          ),
                        ),
                        Flexible(flex: 1, child: Container()),
                        const SizedBox(
                          width: 8,
                        ),
                        (data.enrolledCourses?.contains(course.code) ?? false)
                            ? OutlinedButton.icon(
                                onPressed: () =>
                                    notifier.removeCourse(course.code),
                                icon: const Icon(Icons.playlist_add_check),
                                label: const Text('取消'),
                              )
                            : FilledButton.icon(
                                onPressed: () =>
                                    notifier.addCourse(course.code),
                                icon: const Icon(Icons.playlist_add_outlined),
                                label: const Text('登録'),
                              ),
                      ],
              )),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
