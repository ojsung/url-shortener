import 'package:mysql1/mysql1.dart';

class MySqlConnectionPool {
  final String host;
  final int port;
  final String user;
  final String password;
  final String database;
  final int maxConnections;
  final List<MySqlConnection> _connections = [];
  final List<MySqlConnection> _availableConnections = [];

  MySqlConnectionPool({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.database,
    this.maxConnections = 10,
  });

  Future<MySqlConnection> getConnection() async {
    if (_availableConnections.isNotEmpty) {
      return _availableConnections.removeLast();
    }

    if (_connections.length < maxConnections) {
      final settings = ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: database,
      );
      final connection = await MySqlConnection.connect(settings);
      _connections.add(connection);
      return connection;
    }

    // Wait for an available connection
    while (_availableConnections.isEmpty) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    return _availableConnections.removeLast();
  }

  void releaseConnection(MySqlConnection connection) {
    _availableConnections.add(connection);
  }

  Future<void> closeAllConnections() async {
    for (final connection in _connections) {
      await connection.close();
    }
    _connections.clear();
    _availableConnections.clear();
  }
}
