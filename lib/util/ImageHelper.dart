import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ImageHelper {
  static final String _baseImagePath = 'assets/images/';
  static final ImageHelper _instance = ImageHelper._internal();

  Map<String, BitmapDescriptor> _images;

  Future<BitmapDescriptor> getImage(String pathURL, int widthScaler) async {
    final cachedImage = _images[pathURL];

    // The image was previously fetched, return cached value from memory
    if (cachedImage != null) return Future.value(cachedImage);

    // The image was not yet fetched, so fetch it.
    Uint8List imageBytes = await getBytesFromAsset(
        rootBundle, _baseImagePath + pathURL, widthScaler);

    // Place the image in memory for future use
    _images[pathURL] = BitmapDescriptor.fromBytes(imageBytes);

    // Return the image
    return _images[pathURL];
  }

  static Future<Uint8List> getBytesFromAsset(
      AssetBundle rootBundle, String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  factory ImageHelper() {
    return _instance;
  }

  ImageHelper._internal() {
    _images = Map();
  }
}
