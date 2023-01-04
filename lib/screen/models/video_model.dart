import 'dart:io';

import 'dart:typed_data';

class VideoDirectoryModel {
  VideoDirectoryModel({
    this.directoryName,
    this.fileCount,
    this.videoFileDetailsModel,
  });

  String? directoryName;
  int? fileCount;
  List<VideoFileDetailsModel>? videoFileDetailsModel;

  factory VideoDirectoryModel.fromJson(Map<String, dynamic> json) =>
      VideoDirectoryModel(
        directoryName: json["directoryName"],
        fileCount: json["fileCount"],
        videoFileDetailsModel: List<VideoFileDetailsModel>.from(
            json["videoFileDetails"]
                .map((x) => VideoFileDetailsModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "directoryName": directoryName,
        "fileCount": fileCount,
        "videoFileDetails":
            List<dynamic>.from(videoFileDetailsModel!.map((x) => x.toJson())),
      };
}

class VideoFileDetailsModel {
  VideoFileDetailsModel({
    this.videoFilePath,
    this.absolutePath,
    this.isAbsolute,
    this.parentDirectory,
    this.uri,
    this.length,
    this.lastAccessed,
    this.stats,
    // this.thumbFilepath,
  });

  String? videoFilePath;
  File? absolutePath;
  bool? isAbsolute;
  Directory? parentDirectory;
  Uri? uri;
  int? length;
  DateTime? lastAccessed;
  FileStat? stats;

  factory VideoFileDetailsModel.fromJson(Map<String, dynamic> json) =>
      VideoFileDetailsModel(
        videoFilePath: json["videoFilePath"],
        absolutePath: json["absolutePath"],
        isAbsolute: json["isAbsolute"],
        parentDirectory: json["parentPath"],
        uri: json["uri"],
        length: json["length"],
        lastAccessed: DateTime.parse(json["lastAccessed"]),
        stats: json["stats"],
        // thumbFilepath: json['thumbFilepath'],
      );

  Map<String, dynamic> toJson() => {
        "videoFilePath": videoFilePath,
        "absolutePath": absolutePath,
        "isAbsolute": isAbsolute,
        "parentPath": parentDirectory,
        "uri": uri,
        "length": length,
        "lastAccessed": lastAccessed?.toIso8601String(),
        "stats": stats,
        // "thumbFilepath": thumbFilepath,
      };
}
