import 'package:flutter/material.dart';
import 'package:takeiteasy/models/course.dart';

class TimeTable extends StatelessWidget {
  const TimeTable({
    super.key,
    required this.title,
    required this.courses,
  });

  final String title;
  final List<Course>? courses;

  @override
  Widget build(BuildContext context) {
    List<String> days = ['月', '火', '水', '木', '金', '土'];
    List<String> times = ['1', '2', '3', '4', '5', '6'];
    List<List<List<Course>>> table = List.generate(
        times.length, (index) => List.generate(days.length, (index) => []));
    if (courses != null) {
      for (Course course in courses!) {
        for (String period in course.period) {
          int day = days.indexOf(period[0]);
          int time = times.indexOf(period[1]);
          table[time][day].add(course);
        }
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
                  child: Text(
                '${i + 1}限',
                textAlign: TextAlign.center,
              )),
              for (int j = 0; j < days.length; j++)
                TableCell(
                    child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TableCard(
                    data: table[i][j],
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
        onTap: () {},
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
        onTap: () {},
        child: Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Container(
            alignment: Alignment.center,
            height: 50,
            child: Text(
              data.first.name,
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
