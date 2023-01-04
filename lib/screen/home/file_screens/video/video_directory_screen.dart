import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:auto_file_showing/screen/home/file_screens/video/video_list_screen.dart';
import 'package:path/path.dart' as path;
import 'package:auto_file_showing/screen/models/video_model.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FileManagerController controller = FileManagerController();
  ValueNotifier<bool> isFetchingFiles = ValueNotifier(true);

  ValueNotifier<List<VideoDirectoryModel>> videoFileDetails = ValueNotifier([]);

  @override
  void initState() {
    getFiles();
    super.initState();
  }

  Widget loadingWidget() {
    debugPrint('callingLoadingWidget');
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            'Loading Videos...',
            style: Theme.of(context).textTheme.headline1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.isRootDirectory()) {
          return true;
        } else {
          controller.goToParentDirectory();
          return false;
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            getFiles();
          },
          child: const Icon(Icons.refresh_outlined),
        ),
        body: ValueListenableBuilder(
          valueListenable: isFetchingFiles,
          builder: (_, value, child) {
            if (isFetchingFiles.value) {
              return loadingWidget();
            } else {
              return ValueListenableBuilder(
                valueListenable: videoFileDetails,
                builder: (_, value, child) {
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      final directoryName = videoFileDetails
                          .value[index].directoryName
                          .toString()
                          .split('/')
                          .last;
                      return ListTile(
                        leading: const Icon(
                          Icons.folder,
                          size: 30 * 2,
                        ),
                        title: Text(
                          directoryName,
                        ),
                        subtitle: Text(
                          videoFileDetails.value[index].fileCount.toString(),
                        ),
                        onTap: () {
                          final ValueNotifier<List<VideoFileDetailsModel>>?
                              videoFileList = ValueNotifier(videoFileDetails
                                  .value[index].videoFileDetailsModel!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoListScreen(
                                videoFileList: videoFileList,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemCount: videoFileDetails.value.length,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void getFiles() async {
    isFetchingFiles.value = true;
    isFetchingFiles.notifyListeners();
    videoFileDetails.value.clear();
    final storageDirectories = await FileManager.getStorageList();
    for (var storage in storageDirectories) {
      processFiles(searchElement: storage);
    }
    await Future.delayed(const Duration(milliseconds: 2000));
    isFetchingFiles.value = false;
    isFetchingFiles.notifyListeners();
  }

  Future<void> processFiles({required searchElement}) async {
    if (FileManager.isDirectory(searchElement) && searchElement.path.split('/').last != '.android_secure') {
      log('DirectoryListAre -> $searchElement');
      var dir = searchElement as Directory;
      for (var i in await dir.list().toList()) {
        await processFiles(searchElement: i);
        continue;
      }
    } else {
      if (searchElement is File) {
        final fileExtension = path.extension(searchElement.path).toLowerCase();
        if (fileExtension == '.mp4' ||
            fileExtension == '.mov' ||
            fileExtension == '.wmv' ||
            fileExtension == '.avi' ||
            fileExtension == '.mkv' ||
            fileExtension == '.flv' ) {

          final fileDetails = VideoFileDetailsModel(
            videoFilePath: searchElement.path,
            absolutePath: searchElement.absolute,
            isAbsolute: searchElement.isAbsolute,
            lastAccessed: searchElement.lastAccessedSync(),
            length: searchElement.lengthSync(),
            parentDirectory: searchElement.parent,
            stats: searchElement.statSync(),
            uri: searchElement.uri,
            // thumbFilepath: thumbFile,
          );

          final videoFile = VideoDirectoryModel(
            directoryName: searchElement.parent.toString(),
            fileCount: 1,
            videoFileDetailsModel: [fileDetails],
          );
          bool isAdded = false;

          videoFileDetails.value.asMap().forEach(
            (key, value) {
              if (videoFileDetails.value[key].directoryName ==
                  searchElement.parent.toString()) {
                videoFileDetails.value[key].videoFileDetailsModel
                    ?.add(fileDetails);
                videoFileDetails.value[key].fileCount =
                    (videoFileDetails.value[key].fileCount! + 1);
                isAdded = true;
              }
            },
          );
          if (!isAdded) {
            videoFileDetails.value.add(videoFile);
            videoFileDetails.notifyListeners();
          }
        }
      }

      // log('-----------------------------\nitIsAFile ->>> $searchElement and its path is ${searchElement.path}\n absolute is ${searchElement.absolute}\n isAbsolute is ${searchElement.isAbsolute}\n parent is ${searchElement.parent}\n Uri is ${searchElement.uri}\n  length is ${await searchElement.length()}\n  lastAccessed is ${await searchElement.lastAccessed()}\n  stat is ${await searchElement.stat()}\n----------------------------');
    }
  }
}
