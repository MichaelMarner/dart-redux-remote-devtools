import 'dart:async';
import 'dart:convert';
import 'dart:io';
import './SearchResult.dart';

class GithubApi {
  final String baseUrl;
  late final Map<String, SearchResult> cache;
  late final HttpClient client;

  GithubApi({
    HttpClient? client,
    Map<String, SearchResult>? cache,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  })  : this.client = client ?? new HttpClient(),
        this.cache = cache ?? <String, SearchResult>{};

  /// Search Github for repositories using the given term
  Future<SearchResult> search(String term) async {
    if (term.isEmpty) {
      return new SearchResult.noTerm();
    } else if (cache.containsKey(term)) {
      return cache[term]!;
    } else {
      final result = await _fetchResults(term);

      cache[term] = result;

      return result;
    }
  }

  Future<SearchResult> _fetchResults(String term) async {
    final request = await new HttpClient().getUrl(Uri.parse("$baseUrl$term"));
    final response = await request.close();
    final results = json.decode(await utf8.decoder.bind(response).join());

    return new SearchResult.fromJson(results['items']);
  }
}

enum SearchResultKind { noTerm, empty, populated }

class SearchResultItem {
  final String fullName;
  final String url;
  final String avatarUrl;

  toJson() {
    return {'fullName': fullName, 'url': url, 'avatarUrl': avatarUrl};
  }

  SearchResultItem(this.fullName, this.url, this.avatarUrl);

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return new SearchResultItem(
      json['full_name'] as String,
      json["html_url"] as String,
      (json["owner"] as Map<String, dynamic>)["avatar_url"] as String,
    );
  }
}
