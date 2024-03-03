import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import 'dart:async' show Future;

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
          child: ListTile(
              title: Text(widget.course.name),
              subtitle: Text(widget.course.category[data.crclumcd] ?? ''),
              trailing:
                  (data.enrolledCourses?.contains(widget.course.code) ?? false)
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
                        )),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

//   child: ListView.builder(
                //     itemCount: filtered.length,
                //     itemBuilder: (context, index) {
                //       Map<String, dynamic> item = filtered[index];
                //       String info = (item['クラス'] + ' ' + item['備考']).trim();
                //       return InkWell(
                //         onTap: () {
                //           showDialog(
                //             context: context,
                //             builder: (BuildContext context) {
                //               return AlertDialog(
                //                 title: SelectionArea(
                //                   child: (info == '')
                //                       ? Text(item['科目名'])
                //                       : Text('($info) ${item['科目名']}'),
                //                 ),
                //                 content: SelectionArea(
                //                   child: Row(
                //                     mainAxisAlignment: MainAxisAlignment.start,
                //                     children: [
                //                       Text(
                //                           '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
                //                     ],
                //                   ),
                //                 ),
                //                 scrollable: true,
                //               );
                //             },
                //           );
                //         },
                //         child: Card(
                //           child: Container(
                //             padding: const EdgeInsets.all(5),
                //             child: Column(
                //               children: [
                //                 if (ratio < 1)
                //                   DefaultTextStyle.merge(
                //                     style: const TextStyle(fontSize: 12),
                //                     child: Row(
                //                       children: [
                //                         const SizedBox(
                //                           width: 5,
                //                         ),
                //                         Text(item['学科']),
                //                         const SizedBox(
                //                           width: 5,
                //                         ),
                //                         Text('${item['年']}年'),
                //                         const SizedBox(
                //                           width: 5,
                //                         ),
                //                         Text(item['学期']),
                //                         const SizedBox(
                //                           width: 5,
                //                         ),
                //                         Text(item['時限']),
                //                         const SizedBox(
                //                           width: 5,
                //                         ),
                //                         if (info != '')
                //                           FittedBox(
                //                             fit: BoxFit.scaleDown,
                //                             child: Text(
                //                               info,
                //                             ),
                //                           ),
                //                       ],
                //                     ),
                //                   ),
                //                 Row(
                //                   children: [
                //                     tookClasses.contains(item['講義コード'])
                //                         ? IconButton(
                //                             icon: Icon(Icons.library_add_check,
                //                                 color: Theme.of(context)
                //                                             .brightness ==
                //                                         Brightness.dark
                //                                     ? Colors.white
                //                                     : Colors.black),
                //                             onPressed: () async {
                //                               setState(() {
                //                                 tookClasses
                //                                     .remove(item['講義コード']);
                //                               });
                //                               User? user = FirebaseAuth
                //                                   .instance.currentUser;
                //                               if (user != null) {
                //                                 await FirebaseFirestore.instance
                //                                     .collection('users')
                //                                     .doc(user.uid)
                //                                     .set({
                //                                   'tookClasses': tookClasses
                //                                 });
                //                               }
                //                             },
                //                           )
                //                         : IconButton(
                //                             icon: const Icon(
                //                                 Icons.library_add_outlined,
                //                                 color: Colors.blueAccent),
                //                             onPressed: () async {
                //                               setState(() {
                //                                 tookClasses.add(item['講義コード']);
                //                               });
                //                               User? user = FirebaseAuth
                //                                   .instance.currentUser;
                //                               if (user != null) {
                //                                 await FirebaseFirestore.instance
                //                                     .collection('users')
                //                                     .doc(user.uid)
                //                                     .set({
                //                                   'tookClasses': tookClasses
                //                                 });
                //                               }
                //                             },
                //                           ),
                //                     if (1 <= ratio)
                //                       Expanded(
                //                         flex: 1,
                //                         child: Column(
                //                           mainAxisAlignment:
                //                               MainAxisAlignment.center,
                //                           children: [
                //                             Text(item['学科']),
                //                             Text('${item['年']}年'),
                //                           ],
                //                         ),
                //                       ),
                //                     if (1 <= ratio)
                //                       Expanded(
                //                         flex: 3,
                //                         child: Column(
                //                           mainAxisAlignment:
                //                               MainAxisAlignment.center,
                //                           children: [
                //                             Text(item['学期']),
                //                             Text(item['時限']),
                //                           ],
                //                         ),
                //                       ),
                //                     Expanded(
                //                       flex: 8,
                //                       child: (ratio < 1)
                //                           ? FittedBox(
                //                               fit: BoxFit.scaleDown,
                //                               alignment: Alignment.centerLeft,
                //                               child: Text.rich(TextSpan(
                //                                 text: item['科目名'],
                //                                 style: const TextStyle(
                //                                   color: Colors.blueAccent,
                //                                   fontSize: 18,
                //                                 ),
                //                                 recognizer:
                //                                     TapGestureRecognizer()
                //                                       ..onTap = () {
                //                                         launchUrl(Uri.parse(
                //                                             urlString +
                //                                                 item['講義コード']));
                //                                       },
                //                               )),
                //                             )
                //                           : Column(
                //                               mainAxisAlignment:
                //                                   MainAxisAlignment.center,
                //                               crossAxisAlignment:
                //                                   CrossAxisAlignment.start,
                //                               children: [
                //                                 if (info != '')
                //                                   FittedBox(
                //                                     fit: BoxFit.scaleDown,
                //                                     child: Text(
                //                                       info,
                //                                       style: const TextStyle(
                //                                         fontSize: 12,
                //                                       ),
                //                                     ),
                //                                   ),
                //                                 Text.rich(TextSpan(
                //                                   text: item['科目名'],
                //                                   style: const TextStyle(
                //                                     color: Colors.blueAccent,
                //                                     fontSize: 18,
                //                                   ),
                //                                   recognizer:
                //                                       TapGestureRecognizer()
                //                                         ..onTap = () {
                //                                           launchUrl(Uri.parse(
                //                                               urlString +
                //                                                   item[
                //                                                       '講義コード']));
                //                                         },
                //                                 )),
                //                                 if (item['受講対象/再履修者科目名'] != '')
                //                                   FittedBox(
                //                                     fit: BoxFit.scaleDown,
                //                                     child: Text(
                //                                       item['受講対象/再履修者科目名'],
                //                                       style: const TextStyle(
                //                                         fontSize: 12,
                //                                       ),
                //                                     ),
                //                                   ),
                //                               ],
                //                             ),
                //                     ),
                //                     Expanded(
                //                       flex: 4,
                //                       child: Column(
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.center,
                //                         children: [
                //                           FittedBox(
                //                             fit: BoxFit.scaleDown,
                //                             child: Text(
                //                               item['分類'] + ' ',
                //                             ),
                //                           ),
                //                           Text('${item['単位数']}単位'),
                //                         ],
                //                       ),
                //                     ),
                //                     if (1 <= ratio)
                //                       Expanded(
                //                           flex: 12,
                //                           child: Text(
                //                             item['概要'],
                //                             overflow: TextOverflow.ellipsis,
                //                             maxLines: 4,
                //                             style: const TextStyle(
                //                               fontSize: 10,
                //                             ),
                //                           )),
                //                   ],
                //                 ),
                //                 if (ratio < 1 && item['受講対象/再履修者科目名'] != '')
                //                   Row(
                //                     children: [
                //                       Expanded(
                //                         child: FittedBox(
                //                           fit: BoxFit.scaleDown,
                //                           alignment: Alignment.centerLeft,
                //                           child: Padding(
                //                             padding: const EdgeInsets.symmetric(
                //                                 horizontal: 5),
                //                             child: Text(
                //                               item['受講対象/再履修者科目名'],
                //                               style:
                //                                   const TextStyle(fontSize: 12),
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),