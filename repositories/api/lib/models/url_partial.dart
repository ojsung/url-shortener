import 'package:url_shortener_server/models/url_model.dart' show Url;
import 'package:url_shortener_server/shared/interfaces/partial.dart' show Partial;

class UrlPartial implements Partial<Url, UrlPartial> {
  final int? id;
  final String? url;
  final String? shortenedUrl;

  UrlPartial({this.id, this.url, this.shortenedUrl});

  @override
  UrlPartial toPartial() {
    return this;
  }
}
