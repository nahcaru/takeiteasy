import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'firebase_options.dart';
import 'list.dart';
import 'table.dart';
import 'course.dart';

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
  List<Course> courseList = [];

  @override
  void initState() {
    super.initState();
    loadAsset();
  }

  Future<void> loadAsset() async {
    String jsonText = await rootBundle.loadString('assets/data.json');
    List<dynamic> jsonData = json.decode(jsonText);
    List<Map<String, dynamic>> data =
        jsonData.cast<Map<String, dynamic>>().toList();
    for (var element in data) {
      courseList.add(Course.fromJson(element));
    }
  }

  void loadData() async {
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   try {
    //     await FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(user.uid)
    //         .get()
    //         .then((ref) {
    //       List<dynamic> userData = ref.get('tookClasses');
    //       //tookClasses = userData.map((element) => element.toString()).toList();
    //     });
    //   } catch (error) {
    //     //print(error);
    //   }
    // }
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
            title: Text(
              widget.title,
              style: const TextStyle(
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
            ListPage(courseList: courseList),
            Placeholder()
            //TablePage(),
          ][currentPageIndex]),
    );
  }
}
