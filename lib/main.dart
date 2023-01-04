import 'dart:developer';
import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:auto_file_showing/screen/home/home_screen.dart';
import 'package:auto_file_showing/utils/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueNotifier<List<FileSystemEntity>> folderFiles = ValueNotifier([]);

  @override
  void initState() {
    _listenForPermissionStatus();

    getDownloadPath();
    super.initState();
  }

  Future future = Future.delayed(const Duration(seconds: 3));
  Permission? _permission;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: ValueListenableBuilder<List<FileSystemEntity>>(
              valueListenable: folderFiles,
              builder: (context, child, index) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final isFolderEmpty = folderFiles.value;
                    if (isFolderEmpty.isNotEmpty) {
                      final filePath = folderFiles.value[index].path;
                      final extension = path.extension(filePath);
                      if (extension == '.jpeg' || extension == '.jpg') {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BuildImageTile(filePath: filePath),
                        );
                      } else if (extension == '.pdf') {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BuildPdfTile(
                            filePath: filePath,
                          ),
                        );
                      } else if (extension == '.mp4') {
                        return const BuildMp4Tile();
                      }
                    }
                    return const SizedBox.shrink();
                  },
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: SizedBox(
                      height: 5,
                      child: Divider(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  itemCount: folderFilesCount,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getDownloadPath();
        },
        child: const Icon(Icons.refresh_outlined),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  get folderFilesCount => folderFiles.value.length;

  void _listenForPermissionStatus() async {
    final status = await _permission?.status;
    debugPrint('permissionStatusIs$status');
  }

  Future getDownloadPath() async {
    debugPrint('EnteringToGetDownloadPath');
    debugPrint('storage1 ${await Permission.storage.isGranted}');
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    debugPrint('storage2 ${await Permission.storage.isGranted}');

    Directory? directory;
    try {
      debugPrint('EnteringToGetDownloadPath2');
      debugPrint('EnteringToGetDownloadPath3');
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        debugPrint('EnteringToGetDownloadPath4');
        directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          debugPrint('FolderExists');
          folderFiles.value.addAll(directory.listSync(recursive: true));
          folderFiles.notifyListeners();
        } else {
          debugPrint('FolderDoesNotExists');
        }
      }
    } catch (err, stack) {
      debugPrint("Cannot get download folder path $err $stack");
    }
  }
}

class BuildImageTile extends StatelessWidget {
  final String filePath;

  const BuildImageTile({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);

    return ListTile(
      leading: Card(
        child: Image.file(
          file,
          height: 50,
          width: 50,
        ),
      ),
      title: Text(
        path.basename(file.path),
        style: Theme.of(context).textTheme.headline6,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: Image.file(file),
          ),
        );
      },
    );
  }
}

class BuildPdfTile extends StatefulWidget {
  final String filePath;

  const BuildPdfTile({Key? key, required this.filePath}) : super(key: key);

  @override
  State<BuildPdfTile> createState() => _BuildPdfTileState();
}

class _BuildPdfTileState extends State<BuildPdfTile> {
  late dynamic doc;

  @override
  void initState() {
    convertToPdfDoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Card(
        child: Image.asset(
          'assets/previewIcons/pdfPreviewIco.png',
          height: 50,
          width: 50,
        ),
      ),
      title: Text(
        path.basename(File(widget.filePath).path),
        style: Theme.of(context).textTheme.headline6,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: PDFViewer(
              document: doc,
            ),
          ),
        );
      },
    );
  }

  convertToPdfDoc() async {
    final file = File(widget.filePath);
    PDFDocument doc = await PDFDocument.fromFile(file);
    this.doc = doc;
  }
}

class BuildMp4Tile extends StatelessWidget {
  const BuildMp4Tile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ListTile();
  }
}
