import 'package:url_shortener_server/models/user_url_model.dart';
import 'package:url_shortener_server/shared/interfaces/partial.dart' show Partial;

class UserUrlPartial implements Partial<UserUrl, UserUrlPartial> {
  final int? id;
  final int? userId;
  final int? urlId;

  UserUrlPartial({this.id, this.userId, this.urlId});

  @override
  UserUrlPartial toPartial() {
    return this;
  }
}
