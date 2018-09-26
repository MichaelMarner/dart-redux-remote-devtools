// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SearchResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  return new SearchResult(
      $enumDecodeNullable(
          'SearchResultKind', SearchResultKind.values, json['kind'] as String),
      (json['items'] as List)
          ?.map((e) => e == null
              ? null
              : new SearchResultItem.fromJson(e as Map<String, Object>))
          ?.toList());
}

abstract class _$SearchResultSerializerMixin {
  SearchResultKind get kind;
  List<SearchResultItem> get items;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind?.toString()?.split('.')?.last,
        'items': items
      };
}
