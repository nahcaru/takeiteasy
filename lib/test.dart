import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Course {
  String name;
  String term;
  String grade;
  String category;

  Course(
      {required this.name,
      required this.term,
      required this.grade,
      required this.category});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Course Filter'),
        ),
        body: CourseFilter(),
      ),
    );
  }
}

class CourseFilter extends StatefulWidget {
  @override
  _CourseFilterState createState() => _CourseFilterState();
}

class _CourseFilterState extends State<CourseFilter> {
  List<Course> allCourses = [
    Course(name: 'Course1', term: 'Spring', grade: 'A', category: 'Science'),
    Course(name: 'Course2', term: 'Fall', grade: 'B', category: 'Math'),
    // Add more courses as needed
  ];

  List<String> selectedTerms = [];
  List<String> selectedGrades = [];
  List<String> selectedCategories = [];

  List<Course> getFilteredCourses() {
    return allCourses.where((course) {
      return (selectedTerms.isEmpty || selectedTerms.contains(course.term)) &&
          (selectedGrades.isEmpty || selectedGrades.contains(course.grade)) &&
          (selectedCategories.isEmpty ||
              selectedCategories.contains(course.category));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterList('Term',
            allCourses.map((course) => course.term).toSet(), selectedTerms),
        _buildFilterList('Grade',
            allCourses.map((course) => course.grade).toSet(), selectedGrades),
        _buildFilterList(
            'Category',
            allCourses.map((course) => course.category).toSet(),
            selectedCategories),
        Expanded(
          child: ListView.builder(
            itemCount: getFilteredCourses().length,
            itemBuilder: (context, index) {
              final course = getFilteredCourses()[index];
              return ListTile(
                title: Text(course.name),
                subtitle: Text(
                    'Term: ${course.term}, Grade: ${course.grade}, Category: ${course.category}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterList(
      String title, Set<String> options, List<String> selectedValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: options
              .map((option) => CheckboxListTile(
                    title: Text(option),
                    value: selectedValues.contains(option),
                    onChanged: (value) {
                      setState(() {
                        if (value != null && value) {
                          selectedValues.add(option);
                        } else {
                          selectedValues.remove(option);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}
