import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_list_provider.dart';

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

class Filters extends ConsumerStatefulWidget {
  const Filters({
    super.key,
    this.crclumcd,
    required this.isPortrait,
  });
  final bool isPortrait;
  final String? crclumcd;

  @override
  ConsumerState<Filters> createState() => _FiltersState();
}

class _FiltersState extends ConsumerState<Filters> {
  bool _enrolledOnly = false;
  bool _internationalSpecified = false;
  final Map<String, Map<String, bool>> filters = {
    '学年': {'1年': false, '2年': false, '3年': false, '4年': false},
    '学期': {'後期前': false, '後期後': false, '後期': false, '後集中': false, '通年': false},
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
    final CourseListNotifier notifier =
        ref.read(courseListNotifierProvider.notifier);
    return widget.isPortrait
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...filters.entries.map(
                (entry) => Row(
                  children: [
                    Text(entry.key),
                    FilterButton(
                        title: entry.key,
                        items: entry.value,
                        onChanged: (bool? value) {
                          notifier.setFilters(filters);
                        }),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  notifier.setFilters(filters);
                },
                child: const Text('リセット'),
              ),
            ],
          )
        : Column(
            children: [
              ListTile(
                title: const Text('フィルター'),
                dense: true,
                trailing: ButtonTheme(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _enrolledOnly = false;
                        _internationalSpecified = false;
                        for (final Map<String, bool> item in filters.values) {
                          for (final String key in item.keys) {
                            item[key] = false;
                          }
                        }
                      });
                      notifier.setEnrolledOnly(false);
                      notifier.setInternationalSpecified(false);
                      notifier.setFilters(filters);
                      notifier.applyFilter();
                    },
                    child: const Text('リセット', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('登録済み'),
                dense: true,
                value: _enrolledOnly,
                onChanged: (bool? value) {
                  setState(() {
                    _enrolledOnly = value!;
                  });
                  notifier.setEnrolledOnly(value!);
                  notifier.applyFilter();
                },
              ),
              if (_internationalCodes.contains(widget.crclumcd))
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('国際コース\n指定科目'),
                  dense: true,
                  value: _internationalSpecified,
                  onChanged: (bool? value) {
                    setState(() {
                      _internationalSpecified = value!;
                    });
                    notifier.setInternationalSpecified(value!);
                    notifier.applyFilter();
                  },
                ),
              ...filters.entries.map((entry) => FilterTile(
                    title: entry.key,
                    items: entry.value,
                    onChanged: (bool? value) {
                      notifier.setFilters(filters);
                      notifier.applyFilter();
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
