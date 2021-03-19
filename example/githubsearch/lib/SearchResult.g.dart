// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SearchResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  return SearchResult(
    _$enumDecode(_$SearchResultKindEnumMap, json['kind']),
    (json['items'] as List<dynamic>)
        .map((e) => SearchResultItem.fromJson((e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            )))
        .toList(),
  );
}

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'kind': _$SearchResultKindEnumMap[instance.kind],
      'items': instance.items,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$SearchResultKindEnumMap = {
  SearchResultKind.noTerm: 'noTerm',
  SearchResultKind.empty: 'empty',
  SearchResultKind.populated: 'populated',
};
