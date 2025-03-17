import 'package:url_shortener_server/models/url_model.dart';
import 'package:url_shortener_server/models/url_partial.dart';
import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_url_model.dart';
import 'package:url_shortener_server/models/user_url_partial.dart';
import 'package:url_shortener_server/shared/query_result.dart';

Future<Url> createUrl([String url = 'https://www.google.com']) async {
  return Url.create(UrlPartial(url: url));
}

Future<UserUrl> createUserUrl(User user, Url url) async {
  QueryResult createResult = await UserUrl.create(
    UserUrlPartial(userId: user.id, urlId: url.id),
  );
  List<UserUrl> readResult = await UserUrl.read(
    UserUrlPartial(id: createResult.lastInsertId.toInt()),
  );
  return readResult.first;
}
