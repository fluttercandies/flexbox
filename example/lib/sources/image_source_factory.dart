import 'package:example/models/image_post.dart';
import 'package:example/sources/image_source.dart';
import 'package:example/sources/konachan_source.dart';
import 'package:example/sources/nekosia_source.dart';
import 'package:example/sources/yande_source.dart';
import 'package:example/sources/zerochan_source.dart';

class ImageSourceFactory {
  static ImageSource create(SourceType type) {
    switch (type) {
      case SourceType.yande:
        return YandeSource();
      case SourceType.zerochan:
        return ZerochanSource();
      case SourceType.nekosia:
        return NekosiaSource();
      case SourceType.konachan:
        return KonachanSource();
    }
  }
}
