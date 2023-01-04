import 'package:auto_file_showing/screen/assetCons/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'file_screens/music_screen.dart';
import 'file_screens/settings_screen.dart';
import 'file_screens/video/video_directory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<int> selectedIndex = ValueNotifier(0);
  ValueNotifier<List<String>> selectedScreenTitle =
      ValueNotifier(['Videos', 'Music', 'Settings']);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(0, 170),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  child: Center(
                    child: ValueListenableBuilder(
                      valueListenable: selectedIndex,
                      builder: (_, values, child) => Text(
                        selectedScreenTitle.value[selectedIndex.value]
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.background,
                        hintText: '\t\t\t\t\t\tSearch Folders',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: ValueListenableBuilder(
            valueListenable: selectedIndex,
            builder: (context, value, child) {
              return tabScreens.value[selectedIndex.value];
            },
          ),
          bottomNavigationBar: ValueListenableBuilder(
            valueListenable: selectedIndex,
            builder: (context, value, child) {
              return BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      playButton,
                      height: 30,
                      semanticsLabel: 'Video Icon',
                      color: selectedIndex.value == 0
                          ? Theme.of(context)
                              .bottomNavigationBarTheme
                              .selectedItemColor
                          : Theme.of(context)
                              .bottomNavigationBarTheme
                              .unselectedItemColor,
                    ),
                    label: selectedScreenTitle.value[0],
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      music1,
                      height: 30,
                      semanticsLabel: 'Music Icon',
                      color: selectedIndex.value == 1
                          ? Theme.of(context)
                              .bottomNavigationBarTheme
                              .selectedItemColor
                          : Theme.of(context)
                              .bottomNavigationBarTheme
                              .unselectedItemColor,
                    ),
                    label: selectedScreenTitle.value[1],
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      settingsIcon,
                      height: 30,
                      semanticsLabel: 'Settings Icon',
                      color: selectedIndex.value == 2
                          ? Theme.of(context)
                              .bottomNavigationBarTheme
                              .selectedItemColor
                          : Theme.of(context)
                              .bottomNavigationBarTheme
                              .unselectedItemColor,
                    ),
                    label: selectedScreenTitle.value[2],
                  ),
                ],
                type: BottomNavigationBarType.shifting,
                currentIndex: selectedIndex.value,
                onTap: _onItemTapped,
                elevation: 5,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    selectedIndex.value = index;
    selectedIndex.notifyListeners();
  }

  ValueNotifier<List<Widget>> tabScreens = ValueNotifier([
    const VideoScreen(),
    const MusicScreen(),
    const SettingScreen(),
  ]);
}
