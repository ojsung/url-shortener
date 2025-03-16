class InsertResult {
  final BigInt lastInsertId;
  final BigInt affectedRows;
  const InsertResult({required this.lastInsertId, required this.affectedRows});
}
