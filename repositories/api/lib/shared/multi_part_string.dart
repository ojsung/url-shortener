import 'package:collection/collection.dart';

class MultiPartString<T extends String> extends DelegatingList<T> {
  final List<T> _parts;
  MultiPartString(Iterable<T> parts) : this._(parts.toList());
  MultiPartString._(super.parts) : _parts = parts;

  @override
  String toString() {
    return _parts.join(':');
  }

  static MultiPartString<String> fromString(String value) {
    final parts = value.split(':');
    return MultiPartString(parts);
  }

  @override
  bool operator ==(Object other) {
    if (other is MultiPartString) {
      return _parts.foldIndexed<bool>(true, (
        int index,
        bool carry,
        String value,
      ) {
        return carry && value == other[index];
      });
    } else if (other is String) {
      return toString() == other;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll(_parts);
}
