import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../providers/course_list_provider.dart';
import '../models/filter.dart';

class FilterColumn extends ConsumerStatefulWidget {
  const FilterColumn({
    super.key,
    this.crclumcd,
  });
  final String? crclumcd;

  @override
  ConsumerState<FilterColumn> createState() => _FiltersState();
}

class _FiltersState extends ConsumerState<FilterColumn> {
  final List<String> _internationalCodes = const [
    's21311',
    's22211',
    's23311',
    's24311',
    's21321',
    's22221',
    's23321',
    's24321'
  ];
  @override
  Widget build(BuildContext context) {
    final Filter filter = ref.watch(filterNotifierProvider);
    final FilterNotifier notifier = ref.read(filterNotifierProvider.notifier);
    return Column(
      children: [
        ListTile(
          title: const Text('フィルター'),
          dense: true,
          trailing: ButtonTheme(
            child: TextButton(
              onPressed: () {
                setState(() {
                  notifier.reSet();
                });
              },
              child: const Text('リセット', style: TextStyle(fontSize: 12)),
            ),
          ),
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('登録済み'),
          dense: true,
          value: filter.enrolledOnly,
          onChanged: (bool? value) {
            notifier.setEnrolledOnly(value!);
          },
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('空きコマ'),
          dense: true,
          value: filter.blankOnly,
          onChanged: (bool? value) {
            notifier.setBlankOnly(value!);
          },
        ),
        if (_internationalCodes.contains(widget.crclumcd))
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('国際コース指定科目')),
            dense: true,
            value: filter.internationalSpecified,
            onChanged: (bool? value) {
              notifier.setInternationalSpecified(value!);
            },
          ),
        ...filter.filters.entries.map((entry) => FilterTile(
              title: entry.key,
              items: entry.value,
              onChanged: (String key, bool? value) {
                notifier.setFilters(filter.filters);
              },
            ))
      ],
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
  final void Function(String, bool?)? onChanged;
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
                  widget.onChanged!(entry.key, value);
                },
              ))
          .toList(),
    );
  }
}
