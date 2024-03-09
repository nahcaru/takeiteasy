import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'env/env.dart';
import 'firebase_options.dart';
import 'models/user_data.dart';
import 'providers/user_data_provider.dart';
import 'screens/list.dart';
import 'screens/table.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage(), routes: [
      GoRoute(
        path: 'login',
        builder: (context, state) => const AuthGate(),
      )
    ])
  ],
);

void main() async {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([
    GoogleProvider(clientId: Env.webGoogleClientId),
  ]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserData> state = ref.watch(userDataNotifierProvider);
    return MaterialApp.router(
      title: 'Take it Easy (Unofficial)',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00A7EB),
        textTheme: GoogleFonts.mPlus1pTextTheme(ThemeData().textTheme),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0044EB),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.mPlus1pTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.values[state.value?.themeModeIndex ?? 0],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      locale: const Locale('ja', 'JP'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FirebaseUILocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: SignInScreen(
        providers: [
          EmailAuthProvider(),
          GoogleProvider(
            clientId: Env.webGoogleClientId,
          )
        ],
        actions: [
          AuthStateChangeAction<SignedIn>((context, _) {
            context.go('/');
          }),
        ],
        // ...
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int currentPageIndex = 0;
  bool extended = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showProgressDialog());
  }

  void _showProgressDialog() {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    ref.watch(userDataNotifierProvider).whenData((_) => context.pop());
  }

  void login() {
    context.go('/login');
  }

  Future<void> logout() async {
    await ref.watch(authProvider).signOut().then((_) => _showProgressDialog());
  }

  void setThemeMode(int themeModeIndex) {
    ref.read(userDataNotifierProvider.notifier).setThemeMode(themeModeIndex);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isPortrait = (screenSize.width / screenSize.height) < 1;
    final bool loggedIn = ref.watch(authProvider).currentUser != null;
    return Scaffold(
      appBar: isPortrait
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
                        onPressed: () => setThemeMode(ThemeMode.light.index),
                        icon: const Icon(Icons.light_mode),
                      )
                    : IconButton(
                        tooltip: 'ダークモード',
                        onPressed: () => setThemeMode(ThemeMode.dark.index),
                        icon: const Icon(Icons.dark_mode),
                      ),
                loggedIn
                    ? IconButton(
                        tooltip: 'ログアウト',
                        onPressed: () => logout(),
                        icon: const Icon(
                          Icons.logout,
                        ),
                      )
                    : IconButton(
                        tooltip: 'ログイン',
                        onPressed: () async => login(),
                        icon: const Icon(
                          Icons.login,
                        ),
                      ),
                const SizedBox(width: 15),
              ],
            )
          : null,
      bottomNavigationBar: isPortrait
          ? NavigationBar(
              onDestinationSelected: (int index) => setState(() {
                currentPageIndex = index;
              }),
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
          if (!isPortrait)
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
                    const SizedBox(height: 8.0),
                    const NavigationRailExpanded(child: Divider()),
                    Theme.of(context).brightness == Brightness.dark
                        ? NavigationRailButton(
                            icon: const Icon(Icons.light_mode),
                            buttonStyleButton: FilledButton.tonalIcon(
                              onPressed: () =>
                                  setThemeMode(ThemeMode.light.index),
                              icon: const Icon(Icons.light_mode),
                              label: const Text('ライトモード'),
                            ),
                          )
                        : NavigationRailButton(
                            icon: const Icon(Icons.dark_mode),
                            buttonStyleButton: FilledButton.tonalIcon(
                              onPressed: () =>
                                  setThemeMode(ThemeMode.dark.index),
                              icon: const Icon(Icons.dark_mode),
                              label: const Text('ダークモード'),
                            ),
                          ),
                    loggedIn
                        ? NavigationRailButton(
                            icon: const Icon(Icons.logout),
                            buttonStyleButton: OutlinedButton.icon(
                              onPressed: () => logout(),
                              icon: const Icon(Icons.logout),
                              label: const Text('ログアウト'),
                            ),
                          )
                        : NavigationRailButton(
                            icon: const Icon(Icons.login),
                            buttonStyleButton: OutlinedButton.icon(
                              onPressed: () => login(),
                              icon: const Icon(Icons.login),
                              label: const Text('ログイン'),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
                index: currentPageIndex,
                children: const [ListScreen(), TableScreen()]),
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
          width: lerpDouble(80, 256, animation.value)!,
          height: height,
          child: child,
        );
      },
    );
  }
}
