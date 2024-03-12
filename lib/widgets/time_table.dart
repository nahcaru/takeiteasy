import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../models/user_data.dart';
import '../providers/user_data_provider.dart';

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
                child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: 240,
                child: Wrap(
                  children: courses
                      .map((course) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TableCard(
                              data: [course],
                            ),
                          ))
                      .toList(),
                ),
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

class CreditsTable extends ConsumerWidget {
  const CreditsTable({
    super.key,
    required this.data,
  });

  final List<Course> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final UserDataNotifier notifier =
        ref.watch(userDataNotifierProvider.notifier);
    final Map<String, Map<String, double>> categories = {
      '教養科目': {},
      '体育科目': {},
      '外国語科目': {},
      'PBL科目': {},
      '情報工学基盤': {},
      '専門': {},
      '教職科目': {},
    };
    return asyncValue.when(
      data: (userData) {
        for (MapEntry<String, Map<String, double>> category
            in categories.entries) {
          double? credits = userData.tookCredits?[category.key];
          if (credits != null) {
            category.value['取得済み'] = credits;
          }

          category.value['新規'] = data
              .where((course) =>
                  course.category[userData.crclumcd] == category.key)
              .fold<double>(
                  0.0,
                  (previousValue, element) =>
                      previousValue + element.credits[userData.crclumcd]!);
        }
        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(4.0)),
          children: [
            const TableRow(children: [
              TableCell(
                  child: Text(
                '単位数',
                textAlign: TextAlign.center,
              )),
              TableCell(
                  child: Text(
                '取得済み',
                textAlign: TextAlign.center,
              )),
              TableCell(
                  child: Text(
                '新規',
                textAlign: TextAlign.center,
              )),
              TableCell(
                  child: Text(
                '合計',
                textAlign: TextAlign.center,
              )),
            ]),
            for (int i = 0; i < categories.length; i++)
              TableRow(
                children: [
                  TableCell(
                      child: Text(
                    categories.keys.elementAt(i),
                    textAlign: TextAlign.center,
                  )),
                  TableCell(
                    child: TextFormField(
                      initialValue:
                          categories.values.elementAt(i)['取得済み']?.toString(),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: "0",
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+(\.\d*)?')),
                      ],
                      onChanged: (String? value) {
                        if (value != null && value.isNotEmpty) {
                          notifier.setCredits(categories.keys.elementAt(i),
                              double.parse(value));
                        }
                      },
                    ),
                  ),
                  TableCell(
                      child: Text(
                    categories.values.elementAt(i)['新規']!.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )),
                  TableCell(
                      child: Text(
                    ((categories.values.elementAt(i)['取得済み'] ?? 0) +
                            categories.values.elementAt(i)['新規']!)
                        .toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            TableRow(
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.surface),
              children: [
                TableCell(
                  child: Text(
                    '合計',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                TableCell(
                    child: Text(
                  categories.values
                      .fold<double>(
                          0,
                          (previousValue, element) =>
                              previousValue + (element["取得済み"] ?? 0.0))
                      .toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                )),
                TableCell(
                    child: Text(
                  categories.values
                      .fold<double>(
                          0,
                          (previousValue, element) =>
                              previousValue + element["新規"]!)
                      .toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                )),
                TableCell(
                    child: Text(
                  categories.values
                      .fold<double>(
                          0,
                          (previousValue, element) =>
                              previousValue +
                              (element["取得済み"] ?? 0.0) +
                              element["新規"]!)
                      .toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                )),
              ],
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
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
