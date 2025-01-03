import 'package:al_quran_audio/src/screens/home/controller/home_page_controller.dart';
import 'package:al_quran_audio/src/screens/home/controller/model/play_list_model.dart';
import 'package:al_quran_audio/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:toastification/toastification.dart';

class PlayListPage extends StatefulWidget {
  final PersistentTabController tabController;
  const PlayListPage({super.key, required this.tabController});

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  final HomePageController homePageController = Get.put(HomePageController());
  final HomePageController audioController = Get.put(HomePageController());
  final themeController = Get.find<AppThemeData>();
  final infoBox = Hive.box("info");
  late Map favorite;
  @override
  void initState() {
    favorite = Map.from(infoBox.get("favorite", defaultValue: {}));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final allPlayList = homePageController.allPlaylistInDB;
        return allPlayList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 75,
                      width: 75,
                      child: Obx(
                        () {
                          bool isDark = themeController.themeModeName.value ==
                                  "dark" ||
                              (themeController.themeModeName.value ==
                                      "system" &&
                                  MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark);

                          return Image(
                            image: const AssetImage(
                              "assets/empty-folder.png",
                            ),
                            color: isDark ? Colors.white : Colors.black,
                          );
                        },
                      ),
                    ),
                    const Gap(10),
                    const Text("No PlayList found"),
                    const Gap(10),
                    ElevatedButton.icon(
                      onPressed: createANewPlayList,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Create PlayList",
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(5),
                children: <Widget>[
                      Row(
                        children: [
                          Text("Total PlayList: ${allPlayList.length}"),
                          const Spacer(),
                          SizedBox(
                            height: 25,
                            child: ElevatedButton.icon(
                              onPressed: createANewPlayList,
                              icon: const Icon(Icons.add),
                              label: const Text("Create New PlayList"),
                            ),
                          ),
                        ],
                      ),
                    ] +
                    List<Widget>.generate(
                      allPlayList.keys.length,
                      (index) {
                        return getPlayListCards(allPlayList, index);
                      },
                    ),
              );
      },
    );
  }

  Card getPlayListCards(
      RxMap<String, List<PlayListModel>> allPlayList, int index) {
    String playListKey = allPlayList.keys.elementAt(index);
    final currentPlayList = allPlayList[playListKey];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
            ),
            tooltip: "Play or Pause",
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // Play the PlayList
            },
          ),
          const Gap(5),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playListKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Text("Total: "),
                  Text(
                    "${currentPlayList?.length ?? 0}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  createANewPlayList() async {
    // homePageController.selectForPlaylistMode.value = true;
    // widget.tabController.jumpToTab(0);

    showDialog(
      context: context,
      builder: (context) {
        final playListController = TextEditingController();
        bool isDark = themeController.themeModeName.value == "dark" ||
            (themeController.themeModeName.value == "system" &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return Dialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Name of the PlayList",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const Gap(10),
                Container(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 2,
                    bottom: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: TextFormField(
                    controller: playListController,
                    decoration: const InputDecoration(
                      hintText: "Enter the name of the PlayList",
                      border: InputBorder.none,
                    ),
                    autofocus: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the name of the PlayList";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const Gap(10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (playListController.text.isNotEmpty) {
                        if (Hive.box('info')
                            .containsKey(playListController.text.trim())) {
                          toastification.show(
                            context: context,
                            title: const Text(
                                "PlayList already exists or name is not allowed"),
                            type: ToastificationType.error,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                        } else {
                          // Name is valid
                          Hive.box('info').put(
                            playListController.text.trim(),
                            [],
                          );
                          Navigator.pop(context);
                          homePageController.selectForPlaylistMode.value = true;
                          homePageController.nameOfEditingPlaylist.value =
                              playListController.text.trim();
                          widget.tabController.jumpToTab(0);
                        }
                      } else {
                        toastification.show(
                          context: context,
                          title:
                              const Text("Empty PlayList name is not allowed"),
                          type: ToastificationType.error,
                          autoCloseDuration: const Duration(seconds: 2),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Create PlayList",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
