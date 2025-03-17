import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_partial.dart';
import 'package:url_shortener_server/shared/query_result.dart';

Future<User> createUser({username = 'test', password = 'test'}) async {
  QueryResult result = await User.create(UserPartial(username: username, password: password));
  int lastInsertId = result.lastInsertId.toInt();
  List<User> users = await User.read(UserPartial(id: lastInsertId));
  return users.first;
}
