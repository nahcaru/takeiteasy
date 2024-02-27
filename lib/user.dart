import 'dart:async' show Future;
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserData {
  final User? user;
  ThemeMode? themeMode;
  String? crclumcd;
  final List<String> enrolledCourses = [];

  UserData({
    required this.user,
  }) {
    if (user != null) {
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .then((ref) {
          themeMode = ref.get('themeMode');
        });
      } catch (error) {
        //print(error);
      }
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .then((ref) {
          crclumcd = ref.get('crclumcd');
        });
      } catch (error) {
        //print(error);
      }
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .then((ref) {
          themeMode = ref.get('themeMode');
        });
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    this.themeMode = themeMode;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({'enrolledCourses': enrolledCourses});
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> setCurriculumCode(String crclumcd) async {
    this.crclumcd = crclumcd;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({'crclumcd': crclumcd});
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> addCourse(String kougicd) async {
    enrolledCourses.add(kougicd);

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({'enrolledCourses': enrolledCourses});
      } catch (error) {
        //print(error);
      }
    }
  }

  Future<void> removeCourse(String kougicd) async {
    enrolledCourses.remove(kougicd);

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({'enrolledCourses': enrolledCourses});
      } catch (error) {
        //print(error);
      }
    }
  }
}
