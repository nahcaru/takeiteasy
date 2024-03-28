import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/link.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import '../providers/user_data_provider.dart';

class CourseCard extends ConsumerStatefulWidget {
  const CourseCard({super.key, required this.course});
  final Course course;

  @override
  ConsumerState<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<CourseCard> {
  @override
  Widget build(BuildContext context) {
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
              return AlertDialog(
                title: Text(widget.course.name),
                content: SelectionArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          '講義コード\n${widget.course.code}\n\n教室\n${widget.course.room.join('\n')}\n\n担当者\n${widget.course.lecturer.join('\n')}'),
                    ],
                  ),
                ),
                scrollable: true,
              );
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
                                '${widget.course.term} ${widget.course.period.join(',')} ${widget.course.class_}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Link(
                                uri: Uri(
                                    scheme: 'https',
                                    host: 'websrv.tcu.ac.jp',
                                    path: '/tcu_web_v3/slbssbdr.do',
                                    queryParameters: {
                                      'value(risyunen)': '2023',
                                      'value(semekikn)': '1',
                                      'value(kougicd)': widget.course.code,
                                      'value(crclumcd)': data.crclumcd,
                                    }),
                                target: LinkTarget.blank,
                                builder: (BuildContext context,
                                        FollowLink? followLink) =>
                                    InkWell(
                                  onTap: followLink,
                                  child: Text(
                                    widget.course.name,
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
                                  Text(
                                    widget.course.note,
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Text(
                                    widget.course.category[data.crclumcd] !=
                                            null
                                        ? '${widget.course.category[data.crclumcd]}・${widget.course.compulsoriness[data.crclumcd]} ${widget.course.credits[data.crclumcd] ?? '-'}単位'
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
                        (data.enrolledCourses?.contains(widget.course.code) ??
                                false)
                            ? IconButton.outlined(
                                onPressed: () => setState(() {
                                  notifier.removeCourse(widget.course.code);
                                }),
                                icon: const Icon(Icons.playlist_add_check),
                              )
                            : IconButton.filled(
                                onPressed: () => setState(() {
                                  notifier.addCourse(widget.course.code);
                                }),
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
                                widget.course.term,
                              ),
                              Text(
                                widget.course.period.join(','),
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
                              Text(
                                widget.course.class_,
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
                                      'value(kougicd)': widget.course.code,
                                      'value(crclumcd)': data.crclumcd,
                                    }),
                                target: LinkTarget.blank,
                                builder: (BuildContext context,
                                        FollowLink? followLink) =>
                                    InkWell(
                                  onTap: followLink,
                                  child: Text(
                                    widget.course.name,
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
                              Text(
                                widget.course.note,
                                style: Theme.of(context).textTheme.labelMedium,
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
                                widget.course.category[data.crclumcd] ?? 'シラバス',
                              ),
                              Text(
                                widget.course.compulsoriness[data.crclumcd] ??
                                    '未公開',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${widget.course.credits[data.crclumcd] ?? '-'}単位',
                              style: const TextStyle(fontFeatures: [
                                FontFeature.tabularFigures(),
                              ]),
                            ),
                          ),
                        ),
                        Flexible(flex: 1, child: Container()),
                        const SizedBox(
                          width: 8,
                        ),
                        (data.enrolledCourses?.contains(widget.course.code) ??
                                false)
                            ? OutlinedButton.icon(
                                onPressed: () => setState(() {
                                  notifier.removeCourse(widget.course.code);
                                }),
                                icon: const Icon(Icons.playlist_add_check),
                                label: const Text('取消'),
                              )
                            : FilledButton.icon(
                                onPressed: () => setState(() {
                                  notifier.addCourse(widget.course.code);
                                }),
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
