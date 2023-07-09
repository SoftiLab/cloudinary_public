import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// The recognised file class to be used for this package
class CloudinaryFile {
  /// The [ByteData] file to be uploaded
  final ByteData? byteData;

  /// The bytes data to be uploaded
  final List<int>? bytesData;

  /// The path of the [File] to be uploaded
  final String? filePath;

  /// The file name/path
  final String? identifier;

  /// An optional folder name where the uploaded asset will be stored.
  /// The public ID will contain the full path of the uploaded asset,
  /// including the folder name.
  final String? folder;

  /// External url
  final String? url;

  /// The cloudinary resource type to be uploaded
  /// see [CloudinaryResourceType.Auto] - default,
  /// [CloudinaryResourceType.Image],
  /// [CloudinaryResourceType.Video],
  /// [CloudinaryResourceType.Raw],
  final CloudinaryResourceType resourceType;

  /// File tags
  final List<String>? tags;

  /// A pipe-separated list of the key-value pairs of contextual metadata to
  /// attach to an uploaded asset.
  ///
  /// Eg: {'alt': 'My image', 'caption': 'Profile image'}
  final Map<String, dynamic>? context;

  /// Determine if initialized from [CloudinaryFile.fromUrl]
  bool get fromExternalUrl => url != null;

  /// [CloudinaryFile] instance
  const CloudinaryFile._({
    this.resourceType = CloudinaryResourceType.Auto,
    this.byteData,
    this.bytesData,
    this.filePath,
    this.identifier,
    this.url,
    this.tags,
    this.folder,
    this.context,
  });

  /// Instantiate [CloudinaryFile] from future [ByteData]
  static Future<CloudinaryFile> fromFutureByteData(Future<ByteData> byteData,
          {String? identifier,
          CloudinaryResourceType resourceType = CloudinaryResourceType.Auto,
          List<String>? tags}) async =>
      CloudinaryFile.fromByteData(
        await byteData,
        identifier: identifier,
        resourceType: resourceType,
        tags: tags,
      );

  /// Instantiate [CloudinaryFile] from [ByteData]
  factory CloudinaryFile.fromByteData(
    ByteData byteData, {
    String? identifier,
    CloudinaryResourceType resourceType = CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      byteData: byteData,
      identifier: identifier,
      resourceType: resourceType,
      tags: tags,
      folder: folder,
      context: context,
    );
  }

  /// Instantiate [CloudinaryFile] from [ByteData]
  factory CloudinaryFile.fromBytesData(
    List<int> bytesData, {
    String? identifier,
    CloudinaryResourceType resourceType = CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      bytesData: bytesData,
      identifier: identifier,
      resourceType: resourceType,
      tags: tags,
      folder: folder,
      context: context,
    );
  }

  /// Instantiate [CloudinaryFile] from [File] path
  factory CloudinaryFile.fromFile(
    String path, {
    String? identifier,
    CloudinaryResourceType resourceType = CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      filePath: path,
      identifier: identifier ??= path.split('/').last,
      resourceType: resourceType,
      tags: tags,
      folder: folder,
      context: context,
    );
  }

  /// Instantiate [CloudinaryFile] from an external url
  factory CloudinaryFile.fromUrl(
    String url, {
    CloudinaryResourceType resourceType = CloudinaryResourceType.Auto,
    List<String>? tags,
    String? folder,
    Map<String, dynamic>? context,
  }) {
    return CloudinaryFile._(
      url: url,
      identifier: url,
      resourceType: resourceType,
      folder: folder,
      context: context,
    );
  }

  /// Convert [CloudinaryFile] to [MultipartFile]
  Future<http.MultipartFile> toMultipartFile(
      [String fieldName = 'file']) async {
    assert(
      !fromExternalUrl,
      'toMultipartFile() not available when uploading from external urls',
    );

    if (byteData != null) {
      return http.MultipartFile.fromBytes(
        fieldName,
        byteData!.buffer.asUint8List(),
        filename: identifier,
      );
    }

    if (bytesData != null) {
      return http.MultipartFile.fromBytes(
        fieldName,
        bytesData!,
        filename: identifier,
      );
    }

    if (kIsWeb) {
      final bytes = await http.readBytes(Uri.parse(filePath!));
      return http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: identifier,
      );
    }

    return http.MultipartFile.fromPath(
      fieldName,
      filePath!,
      filename: identifier,
    );
  }
}
