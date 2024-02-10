import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  @override
  State<FilterButton> createState() => FilterButtonState();
  const FilterButton({Key? key, required this.filter}) : super(key: key);
  final Filter filter;
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
          return widget.filter.items.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            return PopupMenuItem<String>(
              value: item,
              padding: EdgeInsets.zero,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(item),
                  value: widget.filter.areItemsSelected[index],
                  onChanged: (bool? value) {
                    setState(() {
                      widget.filter.areItemsSelected[index] = value!;
                    });
                  },
                );
              }),
            );
          }).toList();
        });
  }
}

class Filter {
  final List<String> items;
  late List<bool> areItemsSelected = List<bool>.filled(items.length, true);

  Filter({required this.items});

  bool isItemSelected(String item) {
    return areItemsSelected[items.indexOf(item)];
  }
}

/*
void main() {
  List<String> items = ['A', 'B', 'C'];
  Filter filter = Filter(items: items);
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('FilterButton'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilterButton(filter: filter),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Text('FilterButton${filter.areItemsSelected}');
            }),
          ],
        ),
      ),
    ),
  ));
}*/
