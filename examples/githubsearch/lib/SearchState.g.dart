// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SearchState.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchState _$SearchStateFromJson(Map<String, dynamic> json) {
  return new SearchState(
      result: json['result'] == null
          ? null
          : new SearchResult.fromJson(json['result']),
      hasError: json['hasError'] as bool,
      isLoading: json['isLoading'] as bool);
}

abstract class _$SearchStateSerializerMixin {
  SearchResult get result;
  bool get hasError;
  bool get isLoading;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result,
        'hasError': hasError,
        'isLoading': isLoading
      };
}
