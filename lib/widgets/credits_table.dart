import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import '../providers/user_data_provider.dart';
import '../providers/course_list_provider.dart';

class CreditsTable extends ConsumerWidget {
  const CreditsTable({
    super.key,
    required this.isSpring,
  });

  final bool isSpring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserData> asyncValue = ref.watch(userDataNotifierProvider);
    final UserDataNotifier userDataNotifier =
        ref.read(userDataNotifierProvider.notifier);
    final CourseListNotifier courseListNotifier =
        ref.read(courseListNotifierProvider.notifier);
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
            category.value['修得済'] = credits;
          }
          category.value['前期'] = courseListNotifier
              .getCoursesByTerms(userData.enrolledCourses ?? [],
                  const ['前期', '前期前', '前期後', '前集中'])
              .where((course) =>
                  course.category[userData.crclumcd] == category.key)
              .fold<double>(
                  0.0,
                  (previousValue, element) =>
                      previousValue +
                      (element.credits[userData.crclumcd] ?? 0.0));
          category.value['後期'] = courseListNotifier
              .getCoursesByTerms(userData.enrolledCourses ?? [],
                  const ['後期', '後期前', '後期後', '後集中', '通年'])
              .where((course) =>
                  course.category[userData.crclumcd] == category.key)
              .fold<double>(
                  0.0,
                  (previousValue, element) =>
                      previousValue +
                      (element.credits[userData.crclumcd] ?? 0.0));
        }
        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(4.0)),
          children: [
            TableRow(children: [
              const TableCell(
                  child: Text(
                '単位数',
                textAlign: TextAlign.center,
              )),
              TableCell(
                  child: Text(
                isSpring ? '修得済' : '修得済+前期',
                textAlign: TextAlign.center,
              )),
              TableCell(
                  child: Text(
                isSpring ? '前期' : '後期+通年',
                textAlign: TextAlign.center,
              )),
              const TableCell(
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
                    child: isSpring
                        ? TextFormField(
                            initialValue: categories.values
                                .elementAt(i)['修得済']
                                ?.toString(),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "(0)",
                              filled:
                                  categories.values.elementAt(i)['修得済'] == null,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+(\.\d*)?')),
                            ],
                            onChanged: (String? value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  userDataNotifier.setCredits(
                                      categories.keys.elementAt(i), null);
                                } else {
                                  userDataNotifier.setCredits(
                                      categories.keys.elementAt(i),
                                      double.parse(value));
                                }
                              }
                            },
                          )
                        : Container(
                            height: 32,
                            alignment: Alignment.center,
                            child: Text(
                              ((categories.values.elementAt(i)['修得済'] ?? 0) +
                                      categories.values.elementAt(i)['前期']!)
                                  .toString(),
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  TableCell(
                      child: Text(
                    isSpring
                        ? categories.values.elementAt(i)['前期']!.toString()
                        : categories.values.elementAt(i)['後期']!.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )),
                  TableCell(
                      child: Text(
                    isSpring
                        ? ((categories.values.elementAt(i)['修得済'] ?? 0) +
                                categories.values.elementAt(i)['前期']!)
                            .toString()
                        : ((categories.values.elementAt(i)['修得済'] ?? 0) +
                                categories.values.elementAt(i)['前期']! +
                                categories.values.elementAt(i)['後期']!)
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
                  isSpring
                      ? categories.values
                          .fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + (element["修得済"] ?? 0.0))
                          .toString()
                      : categories.values
                          .fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue +
                                  (element["修得済"] ?? 0.0) +
                                  element["前期"]!)
                          .toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                )),
                TableCell(
                    child: Text(
                  isSpring
                      ? categories.values
                          .fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element["前期"]!)
                          .toString()
                      : categories.values
                          .fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue + element["後期"]!)
                          .toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                )),
                TableCell(
                    child: Text(
                  isSpring
                      ? categories.values
                          .fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue +
                                  (element["修得済"] ?? 0.0) +
                                  element["前期"]!)
                          .toString()
                      : categories.values
                          .fold<double>(
                              0,
                              (previousValue, element) =>
                                  previousValue +
                                  (element["修得済"] ?? 0.0) +
                                  element["前期"]! +
                                  element["後期"]!)
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
