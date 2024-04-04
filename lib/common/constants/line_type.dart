/// 线类型
enum LineType {
  full(description: '实线'),
  dotted(description: '虚线');

  final String description;

  const LineType({required this.description});

  static LineType getByName(String? name) {
    if (name == null || name.trim() == '') {
      return LineType.full;
    }

    return LineType.values
        .firstWhere((e) => e.name == name, orElse: () => LineType.full);
  }
}
