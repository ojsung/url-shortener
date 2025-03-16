class WhereClause {
  final List<String> where;
  final List<dynamic> values;
  const WhereClause({required this.where, required this.values});
  @override
  String toString() {
    return '''
WhereClause(
  where: $where,
  values: $values
)
''';
  }
}
