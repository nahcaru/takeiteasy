import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_list_provider.dart';
import '../models/course.dart';

class FilterButton extends StatefulWidget {
  const FilterButton({
    super.key,
    required this.title,
    required this.items,
    this.onChanged,
  });
  final String title;
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
        tooltip: '${widget.title}で絞り込む',
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
    required this.isPortrait,
  });
  final bool isPortrait;

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
      '教養科目': true,
      '体育科目': true,
      '外国語科目': true,
      'PBL科目': true,
      '情報工学基盤': true,
      '専門': true,
      '教職科目': true,
    };
    final Map<String, bool> compulsorinesses = {
      '必修': true,
      '選択必修': true,
      '選択': true
    };
    final Map<String, Map<String, bool>> items = {
      '学年': grades,
      '学期': terms,
      '分類': categories,
      '必選': compulsorinesses
    };
    final CourseListNotifier notifier =
        ref.read(courseListNotifierProvider.notifier);
    // ref.listen<List<Course>>(courseListNotifierProvider,
    //     (List<Course>? previous, List<Course> next) {
    //   notifier.filter(
    //     grades: grades,
    //     terms: terms,
    //     categories: categories,
    //     compulsorinesses: compulsorinesses,
    //   );
    // });
    return isPortrait
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.entries
                .map(
                  (entry) => Row(
                    children: [
                      Text(entry.key),
                      FilterButton(
                          title: entry.key,
                          items: entry.value,
                          onChanged: (bool? value) {
                            notifier.filter(
                              grades: grades,
                              terms: terms,
                              categories: categories,
                              compulsorinesses: compulsorinesses,
                            );
                          }),
                    ],
                  ),
                )
                .toList(),
          )
        : Column(
            children: items.entries
                .map((entry) => FilterTile(
                      title: entry.key,
                      items: entry.value,
                      onChanged: (bool? value) {
                        notifier.filter(
                          grades: grades,
                          terms: terms,
                          categories: categories,
                          compulsorinesses: compulsorinesses,
                        );
                      },
                    ))
                .toList(),
          );
  }
}

class FilterTile extends StatefulWidget {
  const FilterTile({
    super.key,
    required this.title,
    required this.items,
    this.onChanged,
  });
  final String title;
  final Map<String, bool> items;
  final void Function(bool?)? onChanged;
  @override
  State<FilterTile> createState() => _FilterTileState();
}

class _FilterTileState extends State<FilterTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      dense: true,
      shape: const Border(
        top: BorderSide(color: Colors.transparent),
        bottom: BorderSide(color: Colors.transparent),
      ),
      title: Text('${widget.title}で絞り込む'),
      children: widget.items.entries
          .map((entry) => CheckboxListTile(
                dense: true,
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
