import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'firebase_options.dart';
import 'user.dart';
import 'list.dart';
import 'table.dart';

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
  UserData userData = UserData(user: FirebaseAuth.instance.currentUser);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take it Easy (Unofficial)',
      theme: ThemeData(
        colorSchemeSeed: Colors.lightBlue,
        textTheme: GoogleFonts.mPlus1pTextTheme(ThemeData().textTheme),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.mPlus1pTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: userData.themeMode ?? ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomePage(
        userData: userData,
        setThemeMode: (ThemeMode themeMode) {
          setState(() {
            userData.setThemeMode(themeMode);
          });
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            theme: ThemeData(
              colorSchemeSeed: Colors.lightBlue,
              textTheme: GoogleFonts.mPlus1pTextTheme(ThemeData().textTheme),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              textTheme:
                  GoogleFonts.mPlus1pTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: ThemeMode.system,
            home: SignInScreen(providers: [
              EmailAuthProvider(),
            ]),
          );
        }
        return const MyApp();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key, required this.userData, required this.setThemeMode});
  final void Function(ThemeMode) setThemeMode;
  final UserData userData;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  bool extended = false;
  String? crclumcd;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool portrait = (screenSize.width / screenSize.height) < 1;

    return Scaffold(
      appBar: portrait
          ? AppBar(
              scrolledUnderElevation: 0,
              centerTitle: false,
              title: Text(
                'Take it Easy',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                const SizedBox(width: 15),
                Theme.of(context).brightness == Brightness.dark
                    ? IconButton(
                        tooltip: 'ライトモード',
                        onPressed: () => widget.setThemeMode(ThemeMode.light),
                        //onPressed: widget.userData.toggleThemeMode,
                        icon: const Icon(Icons.light_mode),
                      )
                    : IconButton(
                        tooltip: 'ダークモード',
                        onPressed: () => widget.setThemeMode(ThemeMode.dark),
                        //onPressed: widget.userData.toggleThemeMode,
                        icon: const Icon(Icons.dark_mode),
                      ),
                FirebaseAuth.instance.currentUser == null
                    ? IconButton(
                        tooltip: 'ログイン',
                        onPressed: () async {
                          await Navigator.of(context).pushReplacement(
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
                          NavigatorState nav = Navigator.of(context);
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
                const SizedBox(width: 15),
              ],
            )
          : null,
      bottomNavigationBar: portrait
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
                  label: '科目一覧',
                ),
                NavigationDestination(
                  icon: Icon(Icons.table_view),
                  label: '時間割',
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!portrait)
            MouseRegion(
              onEnter: (_) => setState(() => extended = true),
              onExit: (_) => setState(() => extended = false),
              child: NavigationRail(
                selectedIndex: currentPageIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                extended: extended,
                elevation: 1,
                leading: Column(
                  children: [
                    NavigationRailExpanded(
                      height: 44,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: (80 - 31.689971923828125) / 2,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                extended ? 'Take it Easy' : 'TiE',
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: (80 - 31.689971923828125) / 2),
                        ],
                      ),
                    ),
                    const NavigationRailExpanded(child: Divider()),
                  ],
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.list),
                    label: Text('科目一覧'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.table_view),
                    label: Text('時間割'),
                  ),
                ],
                trailing: Column(
                  children: [
                    const NavigationRailExpanded(child: Divider()),
                    Theme.of(context).brightness == Brightness.dark
                        ? NavigationRailButton(
                            icon: const Icon(Icons.light_mode),
                            buttonStyleButton: FilledButton.tonalIcon(
                              onPressed: () =>
                                  widget.setThemeMode(ThemeMode.light),
                              icon: const Icon(Icons.light_mode),
                              label: const Text('ライトモード'),
                            ),
                          )
                        : NavigationRailButton(
                            icon: const Icon(Icons.dark_mode),
                            buttonStyleButton: FilledButton.tonalIcon(
                              onPressed: () =>
                                  widget.setThemeMode(ThemeMode.dark),
                              icon: const Icon(Icons.dark_mode),
                              label: const Text('ダークモード'),
                            ),
                          ),
                    FirebaseAuth.instance.currentUser == null
                        ? NavigationRailButton(
                            icon: const Icon(Icons.login),
                            buttonStyleButton: OutlinedButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) {
                                    return const AuthGate();
                                  }),
                                );
                              },
                              icon: const Icon(Icons.login),
                              label: const Text('ログイン'),
                            ),
                          )
                        : NavigationRailButton(
                            icon: const Icon(Icons.logout),
                            buttonStyleButton: OutlinedButton.icon(
                              onPressed: () async {
                                NavigatorState nav = Navigator.of(context);
                                await FirebaseAuth.instance.signOut();
                                await nav.pushReplacement(
                                  MaterialPageRoute(builder: (context) {
                                    return const AuthGate();
                                  }),
                                );
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('ログアウト'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(index: currentPageIndex, children: [
              ListPage(userData: widget.userData),
              const Placeholder()
            ]),
          ),
        ],
      ),
    );
  }
}

class NavigationRailButton extends StatelessWidget {
  const NavigationRailButton(
      {super.key, this.icon, required this.buttonStyleButton});
  final Icon? icon;
  final ButtonStyleButton buttonStyleButton;
  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        if (animation.value == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: icon == null
                ? null
                : IconButton(
                    onPressed: buttonStyleButton.onPressed, icon: icon!),
          );
        } else {
          final Animation<double> labelFadeAnimation =
              animation.drive(CurveTween(curve: const Interval(0.0, 0.25)));
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: lerpDouble(80, 256, animation.value)!,
            ),
            child: ClipRect(
                child: Align(
              heightFactor: 1.0,
              widthFactor: animation.value,
              alignment: AlignmentDirectional.center,
              child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: FadeTransition(
                    alwaysIncludeSemantics: true,
                    opacity: labelFadeAnimation,
                    child: buttonStyleButton,
                  )),
            )),
          );
        }
      },
    );
  }
}

class NavigationRailExpanded extends StatelessWidget {
  const NavigationRailExpanded({super.key, this.height, this.child});
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? c) {
        return SizedBox(
          width: 80 + lerpDouble(0, 256 - 80, animation.value)!,
          height: height,
          child: child,
        );
      },
    );
  }
}
