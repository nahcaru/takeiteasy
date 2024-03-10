import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
      webOnlyWindowName: '_blank',
    )) {
      //throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final UserDataNotifier notifier =
        ref.watch(userDataNotifierProvider.notifier);
    final Size screenSize = MediaQuery.of(context).size;
    final bool isPortrait = ((screenSize.width - 280) / screenSize.height) < 1;
    return asyncValue.when(
      data: (data) => Card(
        child: InkWell(
          onTap: () => _launchUrl(Uri(
              scheme: 'https',
              host: 'websrv.tcu.ac.jp',
              path: '/tcu_web_v3/slbssbdr.do',
              queryParameters: {
                'value(risyunen)': '2023',
                'value(semekikn)': '1',
                'value(kougicd)': widget.course.code,
                'value(crclumcd)': data.crclumcd,
              })),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
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
                    width: 10,
                  ),
                  Flexible(flex: 1, child: Container()),
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.class_,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(widget.course.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                          widget.course.note,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
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
                          widget.course.category[data.crclumcd] ?? '',
                        ),
                        Text(
                          widget.course.compulsoriness[data.crclumcd] ?? '',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${widget.course.credits[data.crclumcd] ?? '-'}単位',
                      ),
                    ),
                  ),
                  Flexible(flex: 1, child: Container()),
                  const SizedBox(
                    width: 10,
                  ),
                  (data.enrolledCourses?.contains(widget.course.code) ?? false)
                      ? isPortrait
                          ? IconButton.outlined(
                              onPressed: () => setState(() {
                                notifier.removeCourse(widget.course.code);
                              }),
                              icon: const Icon(Icons.playlist_add_check),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => setState(() {
                                notifier.removeCourse(widget.course.code);
                              }),
                              icon: const Icon(Icons.playlist_add_check),
                              label: const Text('取消'),
                            )
                      : isPortrait
                          ? IconButton.filled(
                              onPressed: () => setState(() {
                                notifier.addCourse(widget.course.code);
                              }),
                              icon: const Icon(Icons.playlist_add_outlined),
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
