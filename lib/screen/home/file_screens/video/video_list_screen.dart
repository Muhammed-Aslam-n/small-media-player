import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:auto_file_showing/screen/models/video_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as path;

class VideoListScreen extends StatefulWidget {
  final ValueNotifier<List<VideoFileDetailsModel>>? videoFileList;

  const VideoListScreen({Key? key, required this.videoFileList})
      : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: NestedScrollView(
          restorationId: 'customScrollView',
          key: const Key('videoListAppBar'),
          // shrinkWrap: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 120,
                floating: true,
                flexibleSpace: Container(
                  padding: const EdgeInsets.only(top: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.background,
                      hintText: '\t\t\t\t\t\tSearch Media',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              children: [
                ListView.separated(
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return ValueListenableBuilder(
                        valueListenable: selectedFilesIndex,
                        builder: (context, value, child) {
                          return ListTile(
                            tileColor: selectedFilesIndex.value.contains(index)
                                ? Theme.of(context).colorScheme.secondary
                                : null,
                            onLongPress: () {
                              if (selectedFilesIndex.value.contains(index)) {
                                selectedFilesIndex.value.remove(index);
                                selectedFilesIndex.notifyListeners();
                              } else {
                                selectedFilesIndex.value.add(index);
                                selectedFilesIndex.notifyListeners();
                              }
                              isAnyFileSelected.value =
                                  selectedFilesIndex.value.isNotEmpty
                                      ? true
                                      : false;
                              isAnyFileSelected.notifyListeners();
                              debugPrint(
                                  'selectedFilesArrayNow ${selectedFilesIndex.value}');
                            },
                            leading: FutureBuilder<Uint8List?>(
                              future: generateVideoThumbnail(
                                widget
                                    .videoFileList!.value[index].videoFilePath!,
                              ),
                              builder: (_, snapShot) {
                                if (snapShot.hasData) {
                                  return FittedBox(
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: MemoryImage(
                                                snapShot.data!,
                                              ),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          right: 10,
                                          child:
                                              FutureBuilder<VideoPlayerValue?>(
                                            future: getVideoInfo(
                                              widget.videoFileList!.value[index]
                                                  .absolutePath!,
                                            ),
                                            builder: (_, snapShot) {
                                              if (snapShot.hasData) {
                                                final duration =
                                                    snapShot.data!.duration;
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Text(
                                                      formatDuration(duration)),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return FittedBox(
                                  child: Card(
                                    child: Image.asset(
                                      "assets/iconsAndGifs/lineLoadingNoBg1-.gif",
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 50,
                                    ),
                                  ),
                                );
                              },
                            ),
                            title: Text(
                              widget.videoFileList!.value[index].videoFilePath!
                                  .split('/')
                                  .last,
                            ),
                            subtitle: Text(
                              getFileSizeString(
                                bytes:
                                    widget.videoFileList!.value[index].length!,
                              ),
                            ),
                            // trailing:
                          );
                        });
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: widget.videoFileList!.value.length,
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: isAnyFileSelected,
          builder: (context, value, child) {
            if (value) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () async {
                        debugPrint('ShareButtonClicked');
                        await shareSelectedFile();
                      },
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      disabledColor: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.5),
                      onPressed: selectedFilesIndex.value.length > 1
                          ? null
                          : () async {
                              debugPrint('EditButtonClicked');
                              var k = await showDialog(
                                context: context,
                                builder: (_) => RenameDialog(
                                  fileToRename: widget.videoFileList
                                      ?.value[selectedFilesIndex.value.first],
                                ),
                              );
                              debugPrint('ControlComesToThisVariableAndValueIs $k');
                              if(k != false){
                                final newName = k['newFileName'];
                                widget.videoFileList
                                    ?.value[selectedFilesIndex.value.first].
                              }
                              selectedFilesIndex.value.clear();
                              selectedFilesIndex.notifyListeners();
                              isAnyFileSelected.value = false;
                              isAnyFileSelected.notifyListeners();
                            },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        debugPrint('DeleteButtonClicked');
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  ValueNotifier<bool> isAnyFileSelected = ValueNotifier(false);
  ValueNotifier<bool> changeBg = ValueNotifier(false);
  ValueNotifier<List<int>> selectedFilesIndex = ValueNotifier([]);

  String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = [" B", " KB", " MB", " GB", " TB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    tokens.add('${seconds}s');

    return tokens.join(':');
  }

  Future<VideoPlayerValue?> getVideoInfo(File filePath) async {
    return null;
  }

  Future<Uint8List?> generateVideoThumbnail(file) async {
    final uInt8list = await VideoThumbnail.thumbnailData(
      video: file,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 100,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    // final thumbFile = File.fromRawPath(uInt8list!);
    return uInt8list;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> shareSelectedFile() async {
    final box = context.findRenderObject() as RenderBox?;
    debugPrint(
        'selectedFilesLengthOnShareIs ${selectedFilesIndex.value.length}');
    if (selectedFilesIndex.value.length > 1) {
      List<XFile> filesToShare = [];
      for (var selectedFileIndex in selectedFilesIndex.value) {
        print('FilePathInShareFn $selectedFileIndex');
        final filePath =
            widget.videoFileList?.value[selectedFileIndex].videoFilePath;
        filesToShare.add(XFile(filePath!));
      }
      debugPrint('fileListIs $filesToShare');
      await Share.shareXFiles(
        filesToShare,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } else {
      List<XFile>? filesToShare = [
        XFile(widget.videoFileList!.value.first.videoFilePath!)
      ];
      await Share.shareXFiles(
        filesToShare,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }
}

class RenameDialog extends StatelessWidget {
  RenameDialog({Key? key, this.fileToRename}) : super(key: key);
  final VideoFileDetailsModel? fileToRename;
  final TextEditingController fileNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      key: const Key("videoDialogKey"),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        height: MediaQuery.of(context).size.height * 0.23,
        width: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              'Rename',
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'File name',
                  border: UnderlineInputBorder(),
                ),
                controller: fileNameController,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              key: const Key('WrapKey'),
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel',style: TextStyle(color: Colors.redAccent),),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    if (fileNameController.text.isNotEmpty) {
                      renameFile(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill the new name',style: TextStyle(color: Theme.of(context).colorScheme.tertiary),)),
                      );
                    }
                  },
                  child: const Text('Rename'),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  renameFile(context) {
    try {
      final renameFile = fileToRename;
      final nameOfFile = path.extension(renameFile!.absolutePath!.path);
      String? dir = renameFile.parentDirectory?.path;
      String newPath = path.join(dir!, '${fileNameController.text}$nameOfFile');
      debugPrint('renameSuccessFull ->>>>  NewPath: $newPath');
      renameFile.absolutePath?.renameSync(newPath);
      Navigator.of(context).pop({'newFileName':'${fileNameController.text}$nameOfFile'});
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Can't rename this file",style: TextStyle(color: Theme.of(context).colorScheme.tertiary),)),
      );
    }
  }
}
