// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SearchState.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchState _$SearchStateFromJson(Map<String, dynamic> json) {
  return SearchState(
    result: SearchResult.fromJson(json['result']),
    hasError: json['hasError'] as bool,
    isLoading: json['isLoading'] as bool,
  );
}

Map<String, dynamic> _$SearchStateToJson(SearchState instance) =>
    <String, dynamic>{
      'result': instance.result,
      'hasError': instance.hasError,
      'isLoading': instance.isLoading,
    };
