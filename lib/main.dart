import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take it Easy (Unofficial)',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        textTheme: GoogleFonts.mPlus1pTextTheme(
            ThemeData(brightness: Brightness.light).textTheme),
        navigationBarTheme:
            const NavigationBarThemeData(backgroundColor: Colors.transparent),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.mPlus1pTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
        navigationBarTheme:
            const NavigationBarThemeData(backgroundColor: Colors.transparent),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Take it Easy (Unofficial)',
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return SignInScreen(providers: [
            EmailAuthProvider(),
          ]);
        }
        // Render your application if authenticated
        return const MyApp();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  //const MyHomePage({super.key, required this.title});
  final VoidCallback onToggleTheme;
  const MyHomePage({Key? key, required this.title, required this.onToggleTheme})
      : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filtered = [];
  List<String> tookClasses = [];
  List<double> tookCredits = [];
  List<String> weekdays = ['月', '火', '水', '木', '金', '土'];
  List<String> times = ['1', '2', '3', '4', '5', '6'];
  List<List<String>> formerClassNames = [];
  List<List<String>> latterClassNames = [];
  List<String> intensiveClassNames = [];
  List<List<String>> formerClasses = [];
  List<List<String>> latterClasses = [];
  List<String> intensiveClasses = [];
  List<bool> areDepartmentsSelected = [];
  final List<String> departments = ['共通', '情科', '知能'];
  List<bool> areGradesSelected = [];
  final List<String> grades = ['1', '2', '3', '4'];
  List<bool> areTermsSelected = [];
  final List<String> terms = ['後期前', '後期後', '後期', '後集中', '通年'];
  List<bool> areCategoriesSelected = [];
  final List<String> categories = [
    '教養',
    '体育',
    '外国語',
    'PBL',
    '情報工学基盤',
    '専門',
    '教職',
    'その他'
  ];
  List<bool> areCompulsoriesSelected = [];
  final List<String> compulsories = ['必修', '選択必修', '選択'];
  final TextEditingController _searchController = TextEditingController();
  final String urlString =
      'https://websrv.tcu.ac.jp/tcu_web_v3/slbssbdr.do?value%28risyunen%29=2023&value%28semekikn%29=1&value%28kougicd%29=';

  @override
  void initState() {
    super.initState();
    loadData();
    setTable();
    areDepartmentsSelected = List.filled(departments.length, true);
    areGradesSelected = List.filled(grades.length, true);
    areTermsSelected = List.filled(terms.length, true);
    areCategoriesSelected = List.filled(categories.length, true);
    areCompulsoriesSelected = List.filled(compulsories.length, true);
    tookCredits = List.filled(categories.length, 0);
    _searchController.addListener(filterData);
  }

  @override
  void dispose() {
    _searchController.removeListener(filterData);
    _searchController.dispose();
    super.dispose();
  }

  void loadData() async {
    String jsonText = await rootBundle.loadString('assets/data.json');
    List<dynamic> jsonData = json.decode(jsonText);
    data = jsonData.cast<Map<String, dynamic>>().toList();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((ref) {
          List<dynamic> userData = ref.get('tookClasses');
          tookClasses = userData.map((element) => element.toString()).toList();
        });
      } catch (error) {
        //print(error);
      }
    }
    setState(() {
      filtered = data;
    });
  }

  void filterData() {
    filtered = data.where((item) {
      if (areDepartmentsSelected[departments.indexOf(item['学科'])] != true) {
        return false;
      }
      if (areGradesSelected[grades.indexOf(item['年'].toString())] != true) {
        return false;
      }
      if (item['学期'] != '') {
        if (areTermsSelected[terms.indexOf(item['学期'])] != true) {
          return false;
        }
      }
      bool matched = false;
      for (int i = 0; i < categories.length - 1; i++) {
        if (item['分類'].toString().contains(categories[i])) {
          matched = true;
          if (!areCategoriesSelected[i]) {
            return false;
          }
        }
      }
      if (!areCategoriesSelected.last) {
        if (!matched) {
          return false;
        }
      }

      matched = false;
      for (int i = compulsories.length - 2; 0 <= i; i--) {
        if (item['分類'].toString().contains(compulsories[i])) {
          matched = true;
          if (!areCompulsoriesSelected[i]) {
            return false;
          }
        }
      }
      if (!areCompulsoriesSelected.last) {
        if (!matched) {
          return false;
        }
      }

      if (!item['科目名']
          .toLowerCase()
          .toString()
          .contains(_searchController.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
    setState(() {});
  }

  void setTable() {
    formerClassNames = [];
    latterClassNames = [];
    formerClasses = [];
    latterClasses = [];
    for (int i = 0; i < times.length; i++) {
      List<String> formerNamesRow = [];
      List<String> latterNamesRow = [];
      List<String> formerRow = [];
      List<String> latterRow = [];
      for (int j = 0; j < weekdays.length; j++) {
        String formerNamesCell = '';
        String latterNamesCell = '';
        String formerCell = '';
        String latterCell = '';
        for (String id in tookClasses) {
          Map<String, dynamic> item =
              data.firstWhere((element) => element['講義コード'] == id);
          if (item['時限'].contains('${weekdays[j]}${times[i]}')) {
            switch (item['学期']) {
              case '後期':
                formerNamesCell += '${item['科目名']}\n';
                latterNamesCell += '${item['科目名']}\n';
                formerCell = item['講義コード'];
                latterCell = item['講義コード'];
                break;
              case '後期前':
                formerNamesCell += '${item['科目名']}\n';
                formerCell = item['講義コード'];
                break;
              case '後期後':
                latterNamesCell += '${item['科目名']}\n';
                latterCell = item['講義コード'];

                break;

              default:
            }
          }
        }
        formerNamesRow.add(formerNamesCell);
        latterNamesRow.add(latterNamesCell);
        formerRow.add(formerCell);
        latterRow.add(latterCell);
      }
      formerClassNames.add(formerNamesRow);
      latterClassNames.add(latterNamesRow);
      formerClasses.add(formerRow);
      latterClasses.add(latterRow);
    }
    intensiveClassNames = [];
    intensiveClasses = [];
    for (String id in tookClasses) {
      Map<String, dynamic> item =
          data.firstWhere((element) => element['講義コード'] == id);
      if (item['学期'] == '後集中') {
        intensiveClassNames.add(item['科目名']);
        intensiveClasses.add(item['講義コード']);
      }
    }
  }

  void setCredit() {
    tookCredits = List.filled(categories.length, 0);
    for (String id in tookClasses) {
      Map<String, dynamic> item =
          data.firstWhere((element) => element['講義コード'] == id);
      for (int i = 0; i < categories.length - 1; i++) {
        if (item['分類'].contains(categories[i])) {
          //tookCredits[i] += int.parse(item['単位数'].toString());
          tookCredits[i] += item['単位数'];
        }
      }
    }
    for (int i = 0; i < categories.length - 1; i++) {
      tookCredits.last += tookCredits[i];
    }
  }

  PopupMenuButton<String> filterButton(
      List<String> items, List<bool> areItemsSelected) {
    return PopupMenuButton<String>(
        elevation: 12,
        color: Theme.of(context).canvasColor,
        tooltip: 'フィルター',
        icon:
            Icon(Icons.filter_alt_outlined, color: IconTheme.of(context).color),
        itemBuilder: (BuildContext context) {
          return items.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            return PopupMenuItem<String>(
              value: item,
              padding: EdgeInsets.zero,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(item),
                  value: areItemsSelected[index],
                  onChanged: (bool? value) {
                    setState(() {
                      areItemsSelected[index] = value!;
                      filterData();
                    });
                  },
                );
              }),
            );
          }).toList();
        });
  }

  Table timeTable(String title, List<List<String>> nameData, bool isFormer) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          borderRadius: BorderRadius.circular(10)),
      children: [
        TableRow(children: [
          TableCell(
              child: Text(
            title,
            textAlign: TextAlign.center,
          )),
          for (int j = 0; j < weekdays.length; j++)
            TableCell(
                child: Text(
              weekdays[j],
              textAlign: TextAlign.center,
            )),
        ]),
        for (int i = 0; i < times.length; i++)
          TableRow(
            children: [
              TableCell(
                  child: Text(
                '${i + 1}限',
                textAlign: TextAlign.center,
              )),
              for (int j = 0; j < weekdays.length; j++)
                TableCell(
                  child: (nameData[i][j] == '')
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          height: 50,
                        )
                      : InkWell(
                          onTap: () {
                            Map<String, dynamic> item = data.firstWhere(
                                (element) => isFormer
                                    ? element['講義コード'] == formerClasses[i][j]
                                    : element['講義コード'] == latterClasses[i][j]);
                            String info =
                                (item['クラス'] + ' ' + item['備考']).trim();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return (nameData[i][j]
                                        .trimRight()
                                        .contains('\n'))
                                    ? AlertDialog(
                                        title: const Text('科目が重複しています'),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(nameData[i][j]),
                                          ],
                                        ),
                                        scrollable: true,
                                      )
                                    : AlertDialog(
                                        title: (info == '')
                                            ? Text(item['科目名'])
                                            : Text('($info) ${item['科目名']}'),
                                        content: SelectionArea(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
                                            ],
                                          ),
                                        ),
                                        scrollable: true,
                                      );
                              },
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(5),
                            height: 50,
                            decoration: BoxDecoration(
                                color:
                                    (nameData[i][j].trimRight().contains('\n'))
                                        ? Colors.red.withAlpha(64)
                                        : Colors.lightBlue.withAlpha(64),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: Text(
                              nameData[i][j].trimRight(),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double ratio = (screenSize.width / screenSize.height);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            title: const Text(
              'TCU-TiE ver.2023/11/21',
              style: TextStyle(
                color: Colors.lightBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            flexibleSpace: Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                (ratio < 1)
                    ? Container()
                    : Container(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 200,
                          child: NavigationBar(
                            onDestinationSelected: (int index) {
                              setState(() {
                                setTable();
                                setCredit();
                                currentPageIndex = index;
                              });
                            },
                            selectedIndex: currentPageIndex,
                            destinations: const [
                              NavigationDestination(
                                icon: Icon(Icons.list),
                                label: '授業一覧',
                              ),
                              NavigationDestination(
                                icon: Icon(Icons.calendar_month),
                                label: '時間割',
                              ),
                            ],
                          ),
                        ),
                      ),
                Expanded(
                  child: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Theme.of(context).brightness == Brightness.dark
                                  ? IconButton(
                                      tooltip: 'ライトモード',
                                      onPressed: widget.onToggleTheme,
                                      icon: const Icon(Icons.light_mode),
                                    )
                                  : IconButton(
                                      tooltip: 'ダークモード',
                                      onPressed: widget.onToggleTheme,
                                      icon: const Icon(Icons.dark_mode),
                                    ),
                              FirebaseAuth.instance.currentUser == null
                                  ? IconButton(
                                      tooltip: 'ログイン',
                                      onPressed: () async {
                                        await Navigator.of(context)
                                            .pushReplacement(
                                          MaterialPageRoute(builder: (context) {
                                            return const AuthGate();
                                          }),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.login,
                                      ),
                                    )
                                  : IconButton(
                                      tooltip: 'ログアウト',
                                      onPressed: () async {
                                        NavigatorState nav =
                                            Navigator.of(context);
                                        await FirebaseAuth.instance.signOut();
                                        await nav.pushReplacement(
                                          MaterialPageRoute(builder: (context) {
                                            return const AuthGate();
                                          }),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.logout,
                                      ),
                                    ),
                            ])),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: (ratio < 1)
              ? NavigationBar(
                  onDestinationSelected: (int index) {
                    setState(() {
                      setTable();
                      setCredit();
                      currentPageIndex = index;
                    });
                  },
                  selectedIndex: currentPageIndex,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.list),
                      label: '授業一覧',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month),
                      label: '時間割',
                    ),
                  ],
                )
              : Container(
                  height: 0,
                ),
          body: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (ratio < 1)
                          ? Column(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        prefixIcon: const Icon(Icons.search)),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Text('学科'),
                                    filterButton(
                                        departments, areDepartmentsSelected),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text('学年'),
                                    filterButton(grades, areGradesSelected),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text('学期'),
                                    filterButton(terms, areTermsSelected),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text('分類'),
                                    filterButton(
                                        categories, areCategoriesSelected),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text('必選'),
                                    filterButton(
                                        compulsories, areCompulsoriesSelected),
                                  ],
                                ),
                              ),
                            ])
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: SizedBox(
                                    width: 300,
                                    child: TextField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                          isDense: true,
                                          isCollapsed: true,
                                          hintText: '検索',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          prefixIcon: const Icon(Icons.search)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Text('学科'),
                                filterButton(
                                    departments, areDepartmentsSelected),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text('学年'),
                                filterButton(grades, areGradesSelected),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text('学期'),
                                filterButton(terms, areTermsSelected),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text('分類'),
                                filterButton(categories, areCategoriesSelected),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text('必選'),
                                filterButton(
                                    compulsories, areCompulsoriesSelected),
                              ],
                            ),
                      const Divider(
                        height: 0,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> item = filtered[index];
                              String info =
                                  (item['クラス'] + ' ' + item['備考']).trim();
                              return InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: SelectionArea(
                                          child: (info == '')
                                              ? Text(item['科目名'])
                                              : Text('($info) ${item['科目名']}'),
                                        ),
                                        content: SelectionArea(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
                                            ],
                                          ),
                                        ),
                                        scrollable: true,
                                      );
                                    },
                                  );
                                },
                                child: Card(
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      children: [
                                        if (ratio < 1)
                                          DefaultTextStyle.merge(
                                            style:
                                                const TextStyle(fontSize: 12),
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(item['学科']),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text('${item['年']}年'),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(item['学期']),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(item['時限']),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                if (info != '')
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      info,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        Row(
                                          children: [
                                            tookClasses.contains(item['講義コード'])
                                                ? IconButton(
                                                    icon: Icon(
                                                        Icons.library_add_check,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black),
                                                    onPressed: () async {
                                                      setState(() {
                                                        tookClasses.remove(
                                                            item['講義コード']);
                                                      });
                                                      User? user = FirebaseAuth
                                                          .instance.currentUser;
                                                      if (user != null) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(user.uid)
                                                            .set({
                                                          'tookClasses':
                                                              tookClasses
                                                        });
                                                      }
                                                    },
                                                  )
                                                : IconButton(
                                                    icon: const Icon(
                                                        Icons
                                                            .library_add_outlined,
                                                        color:
                                                            Colors.blueAccent),
                                                    onPressed: () async {
                                                      setState(() {
                                                        tookClasses
                                                            .add(item['講義コード']);
                                                      });
                                                      User? user = FirebaseAuth
                                                          .instance.currentUser;
                                                      if (user != null) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(user.uid)
                                                            .set({
                                                          'tookClasses':
                                                              tookClasses
                                                        });
                                                      }
                                                    },
                                                  ),
                                            if (1 <= ratio)
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(item['学科']),
                                                    Text('${item['年']}年'),
                                                  ],
                                                ),
                                              ),
                                            if (1 <= ratio)
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(item['学期']),
                                                    Text(item['時限']),
                                                  ],
                                                ),
                                              ),
                                            Expanded(
                                              flex: 8,
                                              child: (ratio < 1)
                                                  ? FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text.rich(TextSpan(
                                                        text: item['科目名'],
                                                        style: const TextStyle(
                                                          color:
                                                              Colors.blueAccent,
                                                          fontSize: 18,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                launchUrl(Uri.parse(
                                                                    urlString +
                                                                        item[
                                                                            '講義コード']));
                                                              },
                                                      )),
                                                    )
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (info != '')
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              info,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        Text.rich(TextSpan(
                                                          text: item['科目名'],
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .blueAccent,
                                                            fontSize: 18,
                                                          ),
                                                          recognizer:
                                                              TapGestureRecognizer()
                                                                ..onTap = () {
                                                                  launchUrl(Uri.parse(
                                                                      urlString +
                                                                          item[
                                                                              '講義コード']));
                                                                },
                                                        )),
                                                        if (item[
                                                                '受講対象/再履修者科目名'] !=
                                                            '')
                                                          FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              item[
                                                                  '受講対象/再履修者科目名'],
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      item['分類'] + ' ',
                                                    ),
                                                  ),
                                                  Text('${item['単位数']}単位'),
                                                ],
                                              ),
                                            ),
                                            if (1 <= ratio)
                                              Expanded(
                                                  flex: 12,
                                                  child: Text(
                                                    item['概要'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 4,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  )),
                                          ],
                                        ),
                                        if (ratio < 1 &&
                                            item['受講対象/再履修者科目名'] != '')
                                          Row(
                                            children: [
                                              Expanded(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5),
                                                    child: Text(
                                                      item['受講対象/再履修者科目名'],
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        (ratio < 1)
                            ? Column(
                                children: [
                                  timeTable('前半', formerClassNames, true),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  timeTable('後半', latterClassNames, false),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child:
                                        timeTable('前半', formerClassNames, true),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: timeTable(
                                        '後半', latterClassNames, false),
                                  ),
                                ],
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: TableBorder.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(10)),
                          children: [
                            const TableRow(children: [
                              TableCell(
                                  child: Text(
                                '集中',
                                textAlign: TextAlign.center,
                              )),
                            ]),
                            TableRow(
                              children: [
                                TableCell(
                                  child: (intensiveClassNames.isEmpty)
                                      ? Container(
                                          margin: const EdgeInsets.all(5),
                                          height: 50,
                                        )
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      intensiveClassNames
                                                          .length;
                                                  i++)
                                                InkWell(
                                                  onTap: () {
                                                    Map<String, dynamic>
                                                        item = data.firstWhere(
                                                            (element) =>
                                                                element[
                                                                    '講義コード'] ==
                                                                intensiveClasses[
                                                                    i]);
                                                    String info = (item['クラス'] +
                                                            ' ' +
                                                            item['備考'])
                                                        .trim();
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: SelectionArea(
                                                            child: (info == '')
                                                                ? Text(
                                                                    item['科目名'])
                                                                : Text(
                                                                    '($info) ${item['科目名']}'),
                                                          ),
                                                          content:
                                                              SelectionArea(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    '講義コード\n${item['講義コード']}\n\n教室\n${item['教室']}\n\n担当者\n${item['担当者']}'),
                                                              ],
                                                            ),
                                                          ),
                                                          scrollable: true,
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: Colors.lightBlue
                                                            .withAlpha(64),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    15))),
                                                    child: Center(
                                                      child: Text(
                                                        intensiveClassNames[i],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (1 <= ratio) Expanded(child: Container()),
                            Expanded(
                              child: Table(
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                border: TableBorder.all(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                children: [
                                  TableRow(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor),
                                      children: const [
                                        TableCell(
                                            child: Text(
                                          '分類',
                                          textAlign: TextAlign.center,
                                        )),
                                        TableCell(
                                            child: Text(
                                          '単位数',
                                          textAlign: TextAlign.center,
                                        )),
                                      ]),
                                  for (int i = 0;
                                      i < categories.length - 1;
                                      i++)
                                    TableRow(
                                      children: [
                                        TableCell(
                                            child: Text(
                                          categories[i],
                                          textAlign: TextAlign.center,
                                        )),
                                        TableCell(
                                            child: Text(
                                          tookCredits[i].toString(),
                                          textAlign: TextAlign.center,
                                        )),
                                      ],
                                    ),
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor),
                                    children: [
                                      const TableCell(
                                          child: Text(
                                        '合計',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      TableCell(
                                          child: Text(
                                        tookCredits.last.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (1 <= ratio) Expanded(child: Container()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ][currentPageIndex]),
    );
  }
}
