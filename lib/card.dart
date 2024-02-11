import 'package:flutter/material.dart';
import 'course.dart';

class CourseCard extends StatefulWidget {
  @override
  State<CourseCard> createState() => CourseCardState();
  const CourseCard({Key? key, required this.course}) : super(key: key);
  final Course course;
}

class CourseCardState extends State<CourseCard> {
  CourseCardState({Key? key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.course.name),
        subtitle: Text(widget.course.category),
        trailing: Icon(Icons.more_vert),
      ),
    );
  }
}
