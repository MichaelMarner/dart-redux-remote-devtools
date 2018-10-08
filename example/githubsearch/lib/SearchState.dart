import 'github_search_api.dart';
import './SearchResult.dart';
import 'package:json_annotation/json_annotation.dart';

part 'SearchState.g.dart';

@JsonSerializable()
class SearchState extends Object with _$SearchStateSerializerMixin {
  final SearchResult result;
  final bool hasError;
  final bool isLoading;

  SearchState({
    this.result,
    this.hasError = false,
    this.isLoading = false,
  });

  factory SearchState.initial() =>
      new SearchState(result: SearchResult.noTerm());

  factory SearchState.loading() => SearchState(isLoading: true);

  factory SearchState.error() => SearchState(hasError: true);
}
