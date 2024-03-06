import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_list_provider.dart';

class FilterButton extends StatefulWidget {
  const FilterButton({
    super.key,
    required this.items,
    this.onChanged,
  });
  final Map<String, bool> items;
  final void Function(bool?)? onChanged;
  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) =>
              IconButton(
        tooltip: 'フィルター',
        icon: const Icon(Icons.filter_alt_outlined),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: widget.items.entries
          .map((entry) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(entry.key),
                value: entry.value,
                onChanged: (bool? value) {
                  setState(() {
                    widget.items[entry.key] = value!;
                  });
                  widget.onChanged!(value);
                },
              ))
          .toList(),
    );
  }
}

class Filters extends ConsumerWidget {
  const Filters({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, bool> grades = {
      '1': true,
      '2': true,
      '3': true,
      '4': true
    };
    final Map<String, bool> terms = {
      '後期前': true,
      '後期後': true,
      '後期': true,
      '後集中': true,
      '通年': true
    };
    final Map<String, bool> categories = {
      '教養': true,
      '体育': true,
      '外国語': true,
      'PBL': true,
      '情報工学基盤': true,
      '専門': true,
      '教職': true,
      'その他': true
    };
    final Map<String, bool> compulsorinesses = {
      '必修': true,
      '選択必修': true,
      '選択': true
    };
    final CourseListNotifier notifier =
        ref.read(courseListNotifierProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('学年'),
        FilterButton(
            items: grades,
            onChanged: (bool? value) {
              notifier.filter(
                grades: grades,
                terms: terms,
                categories: categories,
                compulsorinesses: compulsorinesses,
              );
            }),
        const SizedBox(
          width: 5,
        ),
        const Text('学期'),
        FilterButton(
          items: terms,
          onChanged: (bool? value) {
            notifier.filter(
              grades: grades,
              terms: terms,
              categories: categories,
              compulsorinesses: compulsorinesses,
            );
          },
        ),
        const SizedBox(
          width: 5,
        ),
        const Text('分類'),
        FilterButton(
          items: categories,
          onChanged: (bool? value) {
            notifier.filter(
              grades: grades,
              terms: terms,
              categories: categories,
              compulsorinesses: compulsorinesses,
            );
          },
        ),
        const SizedBox(
          width: 5,
        ),
        const Text('必修'),
        FilterButton(
          items: compulsorinesses,
          onChanged: (bool? value) {
            notifier.filter(
              grades: grades,
              terms: terms,
              categories: categories,
              compulsorinesses: compulsorinesses,
            );
          },
        ),
      ],
    );
  }
}
