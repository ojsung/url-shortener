import 'package:collection/collection.dart';

typedef QueryRow = Map<String, dynamic>;

class QueryResult extends DelegatingList<QueryRow> {
  final BigInt lastInsertId;
  final BigInt affectedRows;
  final List<QueryRow> _base;
  QueryResult(this._base, {required this.lastInsertId, required this.affectedRows}) : super(_base);
  @override
  String toString() => '''
QueryResult(
  lastInsertId: $lastInsertId,
  affectedRows: $affectedRows,
  (rows): $_base
)
''';

  /// Avoid overuse. It is expensive to get the runtime type
  String toDebugString() => '''
QueryResult(
  ${lastInsertId.runtimeType} lastInsertId: $lastInsertId,
  ${affectedRows.runtimeType} affectedRows: $affectedRows,
  (debug rows): [
${_base.map<String>((row) => row.entries.map<String>((entry) => "${entry.value.runtimeType} ${entry.key}: ${entry.value}").join('\n')).join('\n')}
  ]
)
''';
}
