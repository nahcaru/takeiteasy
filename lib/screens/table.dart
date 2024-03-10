import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import '../providers/course_list_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/time_table.dart';

class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  // void setCredit() {
  //   tookCredits = List.filled(categories.length, 0);
  //   for (String id in tookClasses) {
  //     Map<String, dynamic> item =
  //         data.firstWhere((element) => element['講義コード'] == id);
  //     for (int i = 0; i < categories.length - 1; i++) {
  //       if (item['分類'].contains(categories[i])) {
  //         //tookCredits[i] += int.parse(item['単位数'].toString());
  //         tookCredits[i] += item['単位数'];
  //       }
  //     }
  //   }
  //   for (int i = 0; i < categories.length - 1; i++) {
  //     tookCredits.last += tookCredits[i];
  //   }
  // }

  // Table timeTable(String title, List<Course> courses) {
  //   return Table(
  //     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  //     border: TableBorder.all(
  //         color: Theme.of(context).brightness == Brightness.dark
  //             ? Colors.white
  //             : Colors.black,
  //         borderRadius: BorderRadius.circular(10)),
  //     children: [
  //       TableRow(children: [
  //         TableCell(
  //             child: Text(
  //           title,
  //           textAlign: TextAlign.center,
  //         )),
  //         for (int j = 0; j < weekdays.length; j++)
  //           TableCell(
  //               child: Text(
  //             weekdays[j],
  //             textAlign: TextAlign.center,
  //           )),
  //       ]),
  //       for (int i = 0; i < times.length; i++)
  //         TableRow(
  //           children: [
  //             TableCell(
  //                 child: Text(
  //               '${i + 1}限',
  //               textAlign: TextAlign.center,
  //             )),
  //             for (int j = 0; j < weekdays.length; j++)
  //               TableCell(
  //                 child: (nameData[i][j] == '')
  //                     ? Container(
  //                         margin: const EdgeInsets.all(5),
  //                         height: 50,
  //                       )
  //                     : InkWell(
  //                         onTap: () {
  //                           Map<String, dynamic> item = data.firstWhere(
  //                               (element) => isFormer
  //                                   ? element['講義コード'] == formerClasses[i][j]
  //                                   : element['講義コード'] == latterClasses[i][j]);
  //                           String info =
  //                               (item['クラス'] + ' ' + item['備考']).trim();
  //                           showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return (nameData[i][j]
  //                                       .trimRight()
  //                                       .contains('\n'))
  //                                   ? AlertDialog(
  //                                       title: const Text('科目が重複しています'),
  //                                       content: Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.start,
  //                                         children: [
  //                                           Text(nameData[i][j]),
  //                                         ],
  //                                       ),
  //                                       scrollable: true,
  //                                     )
  //                                   : AlertDialog(
  //                                       title: (info == '')
  //                                           ? Text(item['科目名'])
  //                                           : Text('($info) ${item['科目名']}'),
  //                                       content: SelectionArea(
  //                                         child: Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.start,
  //                                           children: [
  //                                             Text(
  //                                                 '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                       scrollable: true,
  //                                     );
  //                             },
  //                           );
  //                         },
  //                         child: Container(
  //                           alignment: Alignment.center,
  //                           margin: const EdgeInsets.all(5),
  //                           height: 50,
  //                           decoration: BoxDecoration(
  //                               color:
  //                                   (nameData[i][j].trimRight().contains('\n'))
  //                                       ? Colors.red.withAlpha(64)
  //                                       : Colors.lightBlue.withAlpha(64),
  //                               borderRadius: const BorderRadius.all(
  //                                   Radius.circular(15))),
  //                           child: Text(
  //                             nameData[i][j].trimRight(),
  //                             textAlign: TextAlign.center,
  //                             maxLines: 2,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),
  //                       ),
  //               ),
  //           ],
  //         ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isPortrait = ((screenSize.width - 80) / screenSize.height) < 1;
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final CourseListNotifier notifier =
        ref.watch(courseListNotifierProvider.notifier);
    return asyncValue.when(
      data: (data) => Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  isPortrait
                      ? Column(
                          children: [
                            TimeTable(
                                title: '前半',
                                courses: notifier.getCoursesByTerms(
                                    data.enrolledCourses,
                                    ['前期', '前期前', '後期', '後期前'])),
                            const SizedBox(
                              height: 20,
                            ),
                            TimeTable(
                                title: '後半',
                                courses: notifier.getCoursesByTerms(
                                    data.enrolledCourses,
                                    ['前期', '前期後', '後期', '後期後'])),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TimeTable(
                                  title: '前半',
                                  courses: notifier.getCoursesByTerms(
                                      data.enrolledCourses,
                                      ['前期', '前期前', '後期', '後期前'])),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: TimeTable(
                                  title: '後半',
                                  courses: notifier.getCoursesByTerms(
                                      data.enrolledCourses,
                                      ['前期', '前期後', '後期', '後期後'])),
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Table(
                  //   defaultVerticalAlignment:
                  //       TableCellVerticalAlignment.middle,
                  //   border: TableBorder.all(
                  //       color:
                  //           Theme.of(context).brightness == Brightness.dark
                  //               ? Colors.white
                  //               : Colors.black,
                  //       borderRadius: BorderRadius.circular(10)),
                  //   children: [
                  //     const TableRow(children: [
                  //       TableCell(
                  //           child: Text(
                  //         '集中',
                  //         textAlign: TextAlign.center,
                  //       )),
                  //     ]),
                  //     TableRow(
                  //       children: [
                  //         TableCell(
                  //           child: (intensiveClassNames.isEmpty)
                  //               ? Container(
                  //                   margin: const EdgeInsets.all(5),
                  //                   height: 50,
                  //                 )
                  //               : SingleChildScrollView(
                  //                   scrollDirection: Axis.horizontal,
                  //                   child: Row(
                  //                     children: [
                  //                       for (int i = 0;
                  //                           i < intensiveClassNames.length;
                  //                           i++)
                  //                         InkWell(
                  //                           onTap: () {
                  //                             Map<String, dynamic> item =
                  //                                 data.firstWhere(
                  //                                     (element) =>
                  //                                         element[
                  //                                             '講義コード'] ==
                  //                                         intensiveClasses[
                  //                                             i]);
                  //                             String info = (item['クラス'] +
                  //                                     ' ' +
                  //                                     item['備考'])
                  //                                 .trim();
                  //                             showDialog(
                  //                               context: context,
                  //                               builder:
                  //                                   (BuildContext context) {
                  //                                 return AlertDialog(
                  //                                   title: SelectionArea(
                  //                                     child: (info == '')
                  //                                         ? Text(
                  //                                             item['科目名'])
                  //                                         : Text(
                  //                                             '($info) ${item['科目名']}'),
                  //                                   ),
                  //                                   content: SelectionArea(
                  //                                     child: Row(
                  //                                       mainAxisAlignment:
                  //                                           MainAxisAlignment
                  //                                               .start,
                  //                                       children: [
                  //                                         Text(
                  //                                             '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
                  //                                       ],
                  //                                     ),
                  //                                   ),
                  //                                   scrollable: true,
                  //                                 );
                  //                               },
                  //                             );
                  //                           },
                  //                           child: Container(
                  //                             margin:
                  //                                 const EdgeInsets.all(5),
                  //                             height: 50,
                  //                             decoration: BoxDecoration(
                  //                                 color: Colors.lightBlue
                  //                                     .withAlpha(64),
                  //                                 borderRadius:
                  //                                     const BorderRadius
                  //                                         .all(
                  //                                         Radius.circular(
                  //                                             15))),
                  //                             child: Center(
                  //                               child: Text(
                  //                                 intensiveClassNames[i],
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     if (1 <= ratio) Expanded(child: Container()),
                  //     Expanded(
                  //       child: Table(
                  //         defaultVerticalAlignment:
                  //             TableCellVerticalAlignment.middle,
                  //         border: TableBorder.all(
                  //             color: Theme.of(context).brightness ==
                  //                     Brightness.dark
                  //                 ? Colors.white
                  //                 : Colors.black,
                  //             borderRadius: BorderRadius.circular(10)),
                  //         children: [
                  //           TableRow(
                  //               decoration: BoxDecoration(
                  //                   color: Theme.of(context).cardColor),
                  //               children: const [
                  //                 TableCell(
                  //                     child: Text(
                  //                   '分類',
                  //                   textAlign: TextAlign.center,
                  //                 )),
                  //                 TableCell(
                  //                     child: Text(
                  //                   '単位数',
                  //                   textAlign: TextAlign.center,
                  //                 )),
                  //               ]),
                  //           for (int i = 0; i < categories.length - 1; i++)
                  //             TableRow(
                  //               children: [
                  //                 TableCell(
                  //                     child: Text(
                  //                   categories[i],
                  //                   textAlign: TextAlign.center,
                  //                 )),
                  //                 TableCell(
                  //                     child: Text(
                  //                   tookCredits[i].toString(),
                  //                   textAlign: TextAlign.center,
                  //                 )),
                  //               ],
                  //             ),
                  //           TableRow(
                  //             decoration: BoxDecoration(
                  //                 color: Theme.of(context).cardColor),
                  //             children: [
                  //               const TableCell(
                  //                   child: Text(
                  //                 '合計',
                  //                 textAlign: TextAlign.center,
                  //                 style: TextStyle(
                  //                     fontWeight: FontWeight.bold),
                  //               )),
                  //               TableCell(
                  //                   child: Text(
                  //                 tookCredits.last.toString(),
                  //                 textAlign: TextAlign.center,
                  //                 style: const TextStyle(
                  //                     fontWeight: FontWeight.bold),
                  //               )),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     if (1 <= ratio) Expanded(child: Container()),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}
