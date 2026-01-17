import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:example/exceptions.dart';
import 'package:example/models/image_post.dart';
import 'package:example/sources/image_source.dart';

class KonachanSource extends ImageSource {
  @override
  String get name => 'konachan';

  @override
  String get baseUrl => 'https://konachan.net';

  String _buildUrl(String path) {
    final fullUrl = '$baseUrl$path';
    return fullUrl;
  }

  String _buildImageUrl(String imageUrl) {
    return imageUrl;
  }

  @override
  Future<List<ImagePost>> fetchPosts({
    required int page,
    required int limit,
  }) async {
    final url = Uri.parse(
      _buildUrl('/post.json?tags=rating:safe&limit=$limit&page=$page'),
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw ImageSourceException('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List;

    if (data.isEmpty) {
      return [];
    }

    return data.map((item) {
      // Try width/height first, fallback to sample_width/sample_height
      final width = item['width'] ?? item['sample_width'];
      final height = item['height'] ?? item['sample_height'];

      return ImagePost(
        id: item['id'] as int,
        imageUrl: _buildImageUrl(item['preview_url'] as String),
        width: (width as num).toInt(),
        height: (height as num).toInt(),
        source: SourceType.yande,
      );
    }).toList();
  }
}
