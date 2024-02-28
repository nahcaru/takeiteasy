import 'dart:async' show Future;
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart';

class UserData {
  final User? user;
  int? themeModeIndex;
  String? crclumcd;
  final List<String> enrolledCourses = [];

  UserData({
    required this.user,
  });

  Future<void> init() async {
    if (user != null) {
      try {
        await _getUserDoc().get().then((ref) {
          if (ref.data()!['themeModeIndex'] != null) {
            themeModeIndex = ref.get('themeModeIndex');
          }
          if (ref.data()!['crclumcd'] != null) {
            crclumcd = ref.get('crclumcd');
          }
          if (ref.data()!['enrolledCourses'] != null) {
            enrolledCourses.addAll(ref.get('enrolledCourses').cast<String>());
          }
        });
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> setThemeMode(int themeModeIndex) async {
    this.themeModeIndex = themeModeIndex;
    if (user != null) {
      try {
        await _getUserDoc().update({'themeModeIndex': themeModeIndex});
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> setCurriculumCode(String crclumcd) async {
    this.crclumcd = crclumcd;
    if (user != null) {
      try {
        await _getUserDoc().update({'crclumcd': crclumcd});
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> addCourse(String kougicd) async {
    enrolledCourses.add(kougicd);
    if (user != null) {
      try {
        await _getUserDoc().update({'enrolledCourses': enrolledCourses});
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> removeCourse(String kougicd) async {
    enrolledCourses.remove(kougicd);
    if (user != null) {
      try {
        await _getUserDoc().update({'enrolledCourses': enrolledCourses});
      } catch (error) {
        //print(error);
      }
    }
  }

  DocumentReference<Map<String, dynamic>> _getUserDoc() {
    return FirebaseFirestore.instance.collection('users').doc(user!.uid);
  }
}
