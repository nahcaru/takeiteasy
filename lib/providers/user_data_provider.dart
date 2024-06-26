import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_data.dart';

final authProvider = StateProvider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authenticatorProvider = StateNotifierProvider<AuthController, User?>(
  (ref) => AuthController(initialUser: FirebaseAuth.instance.currentUser),
);

class AuthController extends StateNotifier<User?> {
  AuthController({User? initialUser}) : super(initialUser) {
    _auth.userChanges().listen((user) {
      state = user;
    });
  }

  final _auth = FirebaseAuth.instance;
}

final fireStoreProvider = StateProvider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userDataNotifierProvider =
    AsyncNotifierProvider<UserDataNotifier, UserData>(() {
  return UserDataNotifier();
});

class UserDataNotifier extends AsyncNotifier<UserData> {
  @override
  FutureOr<UserData> build() async {
    User? user = ref.watch(authenticatorProvider);
    int? themeModeIndex;
    String? crclumcd;
    List<String>? enrolledCourses;
    Map<String, double>? tookCredits;
    if (user != null) {
      try {
        await ref
            .watch(fireStoreProvider)
            .collection('users')
            .doc(user.uid)
            .get()
            .then((ref) {
          Map<String, dynamic>? data = ref.data();
          if (data != null) {
            if (data.containsKey('themeModeIndex')) {
              themeModeIndex = ref.get('themeModeIndex');
            }
            if (data.containsKey('crclumcd')) {
              crclumcd = ref.get('crclumcd');
            }
            if (data.containsKey('enrolledCourses')) {
              enrolledCourses = [];
              enrolledCourses!
                  .addAll(ref.get('enrolledCourses').cast<String>());
            }
            if (data.containsKey('tookCredits')) {
              tookCredits = {};
              tookCredits!
                  .addAll(ref.get('tookCredits').cast<String, double>());
            }
          }
        });
      } catch (error) {
        //print(error);
      }
    }
    return UserData(
        themeModeIndex: themeModeIndex,
        crclumcd: crclumcd,
        enrolledCourses: enrolledCourses,
        tookCredits: tookCredits);
  }

  Future<void> _updateData(Map<String, dynamic> data) async {
    User? user = ref.watch(authenticatorProvider);
    if (user != null) {
      try {
        await ref
            .watch(fireStoreProvider)
            .collection('users')
            .doc(user.uid)
            .update(data);
      } catch (error) {
        await ref
            .watch(fireStoreProvider)
            .collection('users')
            .doc(user.uid)
            .set(data);
      }
    }
  }

  Future<void> setThemeMode(int themeModeIndex) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _updateData({'themeModeIndex': themeModeIndex});
      return state.value!.copyWith(themeModeIndex: themeModeIndex);
    });
  }

  Future<void> setCrclumcd(String crclumcd) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _updateData({'crclumcd': crclumcd});
      return state.value!.copyWith(crclumcd: crclumcd);
    });
  }

  Future<void> addCourse(String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      List<String> enrolledCourses = state.value?.enrolledCourses ?? [];
      enrolledCourses.add(code);
      _updateData({'enrolledCourses': enrolledCourses});
      return state.value!.copyWith(enrolledCourses: enrolledCourses);
    });
  }

  Future<void> removeCourse(String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      List<String>? enrolledCourses = state.value?.enrolledCourses;
      enrolledCourses!.remove(code);
      _updateData({'enrolledCourses': enrolledCourses});
      return state.value!.copyWith(enrolledCourses: enrolledCourses);
    });
  }

  Future<void> setCredits(String key, double? value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      Map<String, double> tookCredits = state.value?.tookCredits ?? {};
      if (value == null) {
        tookCredits.remove(key);
      } else {
        tookCredits[key] = value;
      }
      _updateData({'tookCredits': tookCredits});
      return state.value!.copyWith(tookCredits: tookCredits);
    });
  }
}
