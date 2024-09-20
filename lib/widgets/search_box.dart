import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../providers/course_list_provider.dart';

class SearchBox extends ConsumerStatefulWidget {
  const SearchBox({super.key});
  static final SearchController searchController = SearchController();
  @override
  ConsumerState<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> {
  @override
  Widget build(BuildContext context) {
    final FilterNotifier filterNotifier =
        ref.read(filterNotifierProvider.notifier);
    final CourseListNotifier courseListNotifier =
        ref.read(courseListNotifierProvider.notifier);
    return SearchAnchor.bar(
      searchController: SearchBox.searchController,
      onSubmitted: (value) {
        if (SearchBox.searchController.isOpen) {
          setState(() {
            SearchBox.searchController.closeView(value);
          });
        }
        FocusScope.of(context).unfocus();
        filterNotifier.search(value);
      },
      barHintText: '検索',
      barTrailing: [
        if (SearchBox.searchController.text.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                    SearchBox.searchController.clear();
                    filterNotifier.search('');
                  }))
      ],
      constraints: const BoxConstraints(
        minHeight: 40,
        maxWidth: 300,
      ),
      suggestionsBuilder: (context, controller) => courseListNotifier
          .suggestion(controller.text)
          .map((course) => ListTile(
                title: Text(course.name),
                onTap: () {
                  setState(() {
                    controller.closeView(course.name);
                  });
                  FocusScope.of(context).unfocus();
                  filterNotifier.search(course.name);
                },
              ))
          .toList(),
    );
  }
}
