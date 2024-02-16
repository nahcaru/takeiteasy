import 'package:flutter/material.dart';
import 'course.dart';
import 'dropdown.dart';

class ChoiceBox extends StatelessWidget {
  const ChoiceBox({Key? key, required this.options, required this.onSelected})
      : super(key: key);
  final List<ChoiceOption> options;
  final Function(String?) onSelected;
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: CustomDropdownMenu<String>(
        menuHeight: 300,
        enableFilter: true,
        onSelected: (value) => onSelected(value) as void Function(String?),
        hintText: 'カリキュラム',
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          isCollapsed: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        dropdownMenuEntries: options
            .map((option) => DropdownMenuEntry<String>(
                value: option.code, label: option.name))
            .toList(),
      ),
    );
  }
}

class ChoiceOption {
  String name;
  String code;
  ChoiceOption({required this.name, required this.code});
}

class SearchBox extends StatelessWidget {
  const SearchBox({Key? key, required this.options}) : super(key: key);
  final List<Course> options;
  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) => SearchBar(
        controller: controller,
        leading: const Icon(Icons.search),
        hintText: '検索',
        constraints: const BoxConstraints(
          minHeight: 40,
          maxWidth: 300,
        ),
        onChanged: (text) {
          controller.openView();
        },
      ),
      suggestionsBuilder: (context, controller) => options
          .where((course) => (course.name.contains(controller.text) |
              course.code.contains(controller.text)))
          .map((course) => ListTile(
                title: Text(course.name),
                onTap: () {
                  controller.closeView(course.name);
                },
              ))
          .toList(),
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({Key? key, required this.options, required this.onChanged})
      : super(key: key);
  final List<FilterOption> options;
  final Function(bool?) onChanged;
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) =>
              IconButton(
        tooltip: 'フィルター',
        icon: const Icon(Icons.filter_alt_outlined),
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
      menuChildren: options
          .map((option) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(option.name),
                value: option.value,
                onChanged: (bool? value) {
                  option.value = value!;
                  onChanged(value) as void Function(bool?);
                },
              ))
          .toList(),
    );
  }
}

class FilterOption {
  String name;
  bool value;
  FilterOption({required this.name, this.value = true});
}
