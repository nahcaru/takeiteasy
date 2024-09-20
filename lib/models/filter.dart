class Filter {
  final String searchQuery;
  final bool enrolledOnly;
  final bool blankOnly;
  final bool internationalSpecified;
  final Map<String, Map<String, bool>> filters;

  Filter(
      {this.searchQuery = '',
      this.enrolledOnly = false,
      this.blankOnly = false,
      this.internationalSpecified = false,
      this.filters = const <String, Map<String, bool>>{
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
      }});

  Filter copyWith({
    String? searchQuery,
    bool? enrolledOnly,
    bool? blankOnly,
    bool? internationalSpecified,
    Map<String, Map<String, bool>>? filters,
  }) =>
      Filter(
        searchQuery: searchQuery ?? this.searchQuery,
        enrolledOnly: enrolledOnly ?? this.enrolledOnly,
        blankOnly: blankOnly ?? this.blankOnly,
        internationalSpecified:
            internationalSpecified ?? this.internationalSpecified,
        filters: filters ?? this.filters,
      );
}
