import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Filter;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'filter.dart';
import 'card.dart';
import 'course.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.courseList});
  @override
  State<ListPage> createState() => _ListPageState();
  final List<Course> courseList;
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> tookClasses = [];
  final List<Option> departments = [
    Option(name: '共通'),
    Option(name: '情科'),
    Option(name: '知能'),
  ];
  final List<Option> grades = [
    Option(name: '1'),
    Option(name: '2'),
    Option(name: '3'),
    Option(name: '4')
  ];
  final List<Option> terms = [
    Option(name: '後期前'),
    Option(name: '後期後'),
    Option(name: '後期'),
    Option(name: '後集中'),
    Option(name: '通年')
  ];
  final List<Option> categories = [
    Option(name: '教養'),
    Option(name: '体育'),
    Option(name: '外国語'),
    Option(name: 'PBL'),
    Option(name: '情報工学基盤'),
    Option(name: '専門'),
    Option(name: '教職'),
    Option(name: 'その他')
  ];
  final List<Option> compulsories = [
    Option(name: '必修'),
    Option(name: '選択必修'),
    Option(name: '選択')
  ];
  final String urlString =
      'https://websrv.tcu.ac.jp/tcu_web_v3/slbssbdr.do?value%28risyunen%29=2023&value%28semekikn%29=1&value%28kougicd%29=';

  @override
  void initState() {
    super.initState();
    //_searchController.addListener(filterData);
  }

  @override
  void dispose() {
    //_searchController.removeListener(filterData);
    //_searchController.dispose();
    super.dispose();
  }

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

  Padding searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: 300,
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          controller: _searchController,
          decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              hintText: '検索',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              prefixIcon: const Icon(Icons.search)),
        ),
      ),
    );
  }

  Row filters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
        ),
        const Text('学科'),
        FilterButton(
            options: departments,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('学年'),
        FilterButton(
            options: grades,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('学期'),
        FilterButton(
            options: terms,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('分類'),
        FilterButton(
            options: categories,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('必選'),
        FilterButton(
            options: compulsories,
            onChanged: (bool? value) {
              setState(() {
                //filterData();
              });
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double ratio = (screenSize.width / screenSize.height);
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (ratio < 1)
                  ? Column(children: [
                      searchBox(),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: filters(),
                      ),
                    ])
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        searchBox(),
                        filters(),
                      ],
                    ),
              const Divider(
                height: 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    itemCount: widget.courseList.length,
                    itemBuilder: (context, index) {
                      Course course = widget.courseList[index];
                      return CourseCard(course: course);
                    },
                  ),
                ),
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
