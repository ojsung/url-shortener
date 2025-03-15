import 'package:url_shortener_server/models/user_model.dart' show User;
import 'package:url_shortener_server/shared/interfaces/partial.dart' show Partial;

class UserPartial implements Partial<User, UserPartial> {
  final int? id;
  final String? username;
  final String? password;

  UserPartial({this.id, this.username, this.password});

  @override
  UserPartial toPartial() {
    return this;
  }
}
