import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takeiteasy/models/course.dart';
import 'package:takeiteasy/models/user_data.dart';
import 'package:takeiteasy/providers/user_data_provider.dart';

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
