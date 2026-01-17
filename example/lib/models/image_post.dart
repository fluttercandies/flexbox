enum SourceType { yande, zerochan, nekosia, konachan }

class ImagePost {
  final int id;
  final String imageUrl;
  final int width;
  final int height;
  final SourceType source;

  double get aspectRatio => width > 0 ? width / height : 1.0;

  const ImagePost({
    required this.id,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'width': width,
      'height': height,
      'source': source.name,
    };
  }

  @override
  String toString() {
    return 'ImagePost(id: $id, width: $width, height: $height, source: $source)';
  }
}
