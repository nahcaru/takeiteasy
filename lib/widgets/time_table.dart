import 'package:flutter/material.dart';
import '../models/course.dart';
import '../widgets/course_dialog.dart';

class CourseTable extends StatelessWidget {
  const CourseTable({
    super.key,
    required this.title,
    required this.courses,
  });

  final String title;
  final List<Course> courses;

  final List<String> days = const ['月', '火', '水', '木', '金', '土'];
  final List<String> times = const ['1', '2', '3', '4', '5'];

  @override
  Widget build(BuildContext context) {
    List<List<List<Course>>> table = List.generate(
        times.length, (index) => List.generate(days.length, (index) => []));
    for (Course course in courses) {
      for (String period in course.period) {
        int day = days.indexOf(period[0]);
        int time = times.indexOf(period[1]);
        table[time][day].add(course);
      }
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(4.0)),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(children: [
          TableCell(
              child: Text(
            title,
            textAlign: TextAlign.center,
          )),
          for (int j = 0; j < days.length; j++)
            TableCell(
                child: Text(
              days[j],
              textAlign: TextAlign.center,
            )),
        ]),
        for (int i = 0; i < times.length; i++)
          TableRow(
            children: [
              TableCell(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '${i + 1}時限',
                  textAlign: TextAlign.center,
                ),
              )),
              for (int j = 0; j < days.length; j++)
                TableCell(
                    child: TableCard(
                  data: table[i][j],
                )),
            ],
          ),
      ],
    );
  }
}

class CourseWrap extends StatelessWidget {
  const CourseWrap({
    super.key,
    required this.title,
    required this.courses,
  });

  final String title;
  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(4.0)),
      children: [
        TableRow(children: [
          TableCell(
              child: Text(
            title,
            textAlign: TextAlign.center,
          )),
        ]),
        TableRow(
          children: [
            TableCell(
                child: SizedBox(
              height: 240,
              child: Wrap(
                children: courses
                    .map((course) => TableCard(
                          data: [course],
                        ))
                    .toList(),
              ),
            )),
          ],
        ),
      ],
    );
  }
}

class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    required this.data,
  });

  final List<Course> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 58,
      );
    } else if (data.length == 1) {
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CourseDialog(data.first);
            },
          );
        },
        child: Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Text(
              data.first.name,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('科目が重複しています'),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        data.map((course) => course.name).join('\n'),
                      ),
                    ],
                  ),
                  scrollable: true,
                );
              });
        },
        child: Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Container(
            alignment: Alignment.center,
            height: 50,
            child: Text(
              '重複',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }
  }
}

class TimeTable extends StatelessWidget {
  const TimeTable({
    super.key,
    required this.isPortrait,
  });
  final bool isPortrait;
  final List<String> times = const [
    '9:20 ～ 11:00',
    '11:10 ～ 12:50',
    '13:40 ～ 15:20',
    '15:30 ～ 17:10',
    '17:20 ～ 19:00',
  ];
  @override
  Widget build(BuildContext context) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(4.0)),
        children: isPortrait
            ? [
                for (int i = 0; i < times.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: Text(
                          '${i + 1}時限',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TableCell(
                        child: Text(
                          times[i],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
              ]
            : [
                TableRow(
                  children: [
                    for (int i = 0; i < times.length; i++)
                      TableCell(
                        child: Text(
                          '${i + 1}時限',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                TableRow(
                  children: [
                    for (int i = 0; i < times.length; i++)
                      TableCell(
                        child: Text(
                          times[i],
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ]);
  }
}
