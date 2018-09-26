import './github_search_api.dart';
import 'package:json_annotation/json_annotation.dart';

part 'SearchResult.g.dart';

@JsonSerializable()
class SearchResult extends Object with _$SearchResultSerializerMixin {
  final SearchResultKind kind;
  final List<SearchResultItem> items;

  SearchResult(this.kind, this.items);

  factory SearchResult.noTerm() =>
      new SearchResult(SearchResultKind.noTerm, <SearchResultItem>[]);

  factory SearchResult.fromJson(dynamic json) {
    final items = (json as List)
        .cast<Map<String, Object>>()
        .map((Map<String, Object> item) {
      return new SearchResultItem.fromJson(item);
    }).toList();

    return new SearchResult(
      items.isEmpty ? SearchResultKind.empty : SearchResultKind.populated,
      items,
    );
  }

  bool get isPopulated => kind == SearchResultKind.populated;

  bool get isEmpty => kind == SearchResultKind.empty;

  bool get isNoTerm => kind == SearchResultKind.noTerm;
}
