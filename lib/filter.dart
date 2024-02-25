import 'package:flutter/material.dart';
import 'course.dart';

class ChoiceBox extends StatelessWidget {
  const ChoiceBox({super.key, required this.options, required this.onSelected});
  final List<Map<String, String>> options;
  final void Function(String?)? onSelected;
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownMenu<String>(
        menuHeight: 300,
        //enableFilter: true,
        onSelected: (value) {
          onSelected?.call(value);
        },
        hintText: 'カリキュラム',
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          isCollapsed: true,
          border: OutlineInputBorder(),
          constraints: BoxConstraints(maxHeight: 40),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        dropdownMenuEntries: options
            .map((option) => DropdownMenuEntry<String>(
                value: option['code']!, label: option['name']!))
            .toList(),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.options});
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
                onTap: () => controller.closeView(course.name),
              ))
          .toList(),
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key, required this.options, this.onChanged});
  final List<FilterOption> options;
  final void Function(bool?)? onChanged;
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
      menuChildren: options
          .map((option) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(option.name),
                value: option.value,
                onChanged: (bool? value) {
                  option.value = value!;
                  onChanged?.call(value);
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
