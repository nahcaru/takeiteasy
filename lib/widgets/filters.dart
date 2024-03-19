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
    final Map<String, Map<String, bool>> items = {
      '学年': {'1年': false, '2年': false, '3年': false, '4年': false},
      '学期': {
        '後期前': false,
        '後期後': false,
        '後期': false,
        '後集中': false,
        '通年': false
      },
      '分類': {
        '教養科目': false,
        '体育科目': false,
        '外国語科目': false,
        'PBL科目': false,
        '情報工学基盤': false,
        '専門': false,
        '教職科目': false,
      },
      '必選': {'必修': false, '選択必修': false, '選択': false}
    };
    final CourseListNotifier notifier =
        ref.read(courseListNotifierProvider.notifier);
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
                            notifier.setFilters(items);
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
                        notifier.setFilters(items);
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
