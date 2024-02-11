import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  @override
  State<FilterButton> createState() => FilterButtonState();
  const FilterButton({Key? key, required this.options, required this.onChanged})
      : super(key: key);
  final List<Option> options;
  final Function(bool?) onChanged;
}

class FilterButtonState extends State<FilterButton> {
  FilterButtonState({Key? key});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        elevation: 12,
        color: Theme.of(context).canvasColor,
        tooltip: 'フィルター',
        icon:
            Icon(Icons.filter_alt_outlined, color: IconTheme.of(context).color),
        itemBuilder: (BuildContext context) {
          return widget.options.asMap().entries.map((entry) {
            String name = entry.value.name;
            return PopupMenuItem<String>(
              value: name,
              padding: EdgeInsets.zero,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(name),
                  value: entry.value.value,
                  onChanged: widget.onChanged,
                );
              }),
            );
          }).toList();
        });
  }
}

class Option {
  String name;
  bool value;
  Option({required this.name, this.value = true});
}
