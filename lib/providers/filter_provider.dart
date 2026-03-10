import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/filter.dart';
import 'user_data_provider.dart';

final filterNotifierProvider = NotifierProvider<FilterNotifier, Filter>(() {
  return FilterNotifier();
});

class FilterNotifier extends Notifier<Filter> {
  @override
  Filter build() {
    ref.watch(authenticatorProvider);
    return Filter(
      enrolledOnly: false,
      blankOnly: false,
      internationalSpecified: false,
      filters: {
        '学年': {'1年': false, '2年': false, '3年': false, '4年': false},
        '学期': {
          '前期前': false,
          '前期後': false,
          '前期': false,
          '前集中': false,
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
      },
      searchQuery: '',
    );
  }

  void reSet() {
    state = Filter(
      enrolledOnly: false,
      blankOnly: false,
      internationalSpecified: false,
      filters: {
        '学年': {'1年': false, '2年': false, '3年': false, '4年': false},
        '学期': {
          '前期前': false,
          '前期後': false,
          '前期': false,
          '前集中': false,
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
      },
      searchQuery: '',
    );
  }

  void setEnrolledOnly(bool value) {
    state = state.copyWith(enrolledOnly: value);
  }

  void setBlankOnly(bool value) {
    state = state.copyWith(blankOnly: value);
  }

  void setInternationalSpecified(bool value) {
    state = state.copyWith(internationalSpecified: value);
  }

  void setFilters(Map<String, Map<String, bool>> filters) {
    state = state.copyWith(filters: filters);
  }

  void search(String searchQuery) {
    state = state.copyWith(searchQuery: searchQuery);
  }
}
