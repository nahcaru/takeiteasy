import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_data_provider.dart';

class ChoiceBox extends ConsumerWidget {
  const ChoiceBox({
    super.key,
    required this.crclumcd,
  });

  final String? crclumcd;
  final Map<String, String> options = const {
    '情科21(一般)': 's21310',
    '情科21(国際)': 's21311',
    '情科22(一般)': 's22210',
    '情科22(国際)': 's22211',
    '情科23(一般)': 's23310',
    '情科23(国際)': 's23311',
    '情科24(一般)': 's24310',
    '情科24(国際)': 's24311',
    '知能21(一般)': 's21320',
    '知能21(国際)': 's21321',
    '知能22(一般)': 's22220',
    '知能22(国際)': 's22221',
    '知能23(一般)': 's23320',
    '知能23(国際)': 's23321',
    '知能24(一般)': 's24320',
    '知能24(国際)': 's24321'
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownMenu<String>(
      initialSelection: crclumcd,
      onSelected: (value) {
        if (value != null) {
          ref.read(userDataNotifierProvider.notifier).setCrclumcd(value);
        }
      },
      hintText: 'カリキュラム',
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        isCollapsed: true,
        border: OutlineInputBorder(),
        constraints: BoxConstraints(maxHeight: 40),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      dropdownMenuEntries: options.entries
          .map((option) =>
              DropdownMenuEntry<String>(value: option.value, label: option.key))
          .toList(),
    );
  }
}
