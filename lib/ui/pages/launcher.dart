import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:nawa_niwasa/service/service.dart';
import 'package:nawa_niwasa/ui/ui.dart';

import '../../l10n.dart';

class Launcher extends StatelessWidget {
  const Launcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBarWithNotifications(),
      // bottomNavigationBar: BottomNavigation(),
      backgroundColor: Color(0xfffbfcf8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            LauncherBackgroundImage(),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LauncherView(),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class LauncherBackgroundImage extends StatefulWidget {
  const LauncherBackgroundImage({super.key});

  @override
  State<LauncherBackgroundImage> createState() => _LauncherBackgroundImageState();
}

class _LauncherBackgroundImageState extends State<LauncherBackgroundImage> {
  int carouselIndex = 0;

  @override
  void initState() {
    locate<BannerItemHandler>().sync();
    super.initState();
  }

  Widget buildItem(BuildContext context, BannerItemDto item) {
    String? src;

    /// Trying to load mobile specific media item
    if (item.mobileMedia.isNotEmpty) {
      src = item.mobileMedia.first.mediaUrl;
    }

    /// if mobile media is missing, try other media item
    else {
      src = item.mediaItems.first.mediaUrl;
    }

    if (src == null) return const Placeholder();
    return Image.network(src, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: locate<BannerItemHandler>(),
      builder: (context, _) {
        return CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            aspectRatio: 2,
            autoPlay: true,
            onPageChanged: (i, _) => setState(() => carouselIndex = i),
          ),
          items: locate<BannerItemHandler>()
              .items
              .where((data) => data.status == "ACTIVE")
              .where((data) => data.featured ?? false)
              .map((product) => buildItem(context, product))
              .toList(),
        );
      },
    );
  }
}

class LauncherView extends StatelessWidget {
  const LauncherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        LauncherItem(
          path: "/builders",
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
          ),
          color: const Color(0xff6064a2),
          // text: "Builder",
          text: AppLocalizations.of(context)!.nN_1013,
        ),
        LauncherItem(
          path: "/view-all-complaint",
          icon: const Icon(
            Icons.calendar_today_outlined,
            color: Colors.white,
          ),
          color: const Color(0xff08AF8A),
          // text: "Complaint",
          text: AppLocalizations.of(context)!.nN_1014,
        ),
        LauncherItem(
          path: "/view-all-boq",
          icon: const Icon(
            Icons.person_3_outlined,
            color: Colors.white,
          ),
          color: const Color(0xffF2A828),
          // text: "BOQ",
          text: AppLocalizations.of(context)!.nN_1015,
        ),
        LauncherItem(
          path: "/profile",
          icon: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
          ),
          color: Colors.indigoAccent,
          // text: "Profile",
          text: AppLocalizations.of(context)!.nN_1016,
        ),
        LauncherItem(
          path: "/view-all-jobs",
          icon: const Icon(
            Icons.work_outline_rounded,
            color: Colors.white,
          ),
          color: Colors.pinkAccent,
          // text: "Jobs",
          text: AppLocalizations.of(context)!.nN_1017,
        ),
        LauncherItem(
          path: "/messages",
          icon: const Icon(
            Icons.message_outlined,
            color: Colors.white,
          ),
          color: Colors.cyan,
          // text: "Messages",
          text: AppLocalizations.of(context)!.nN_1018,
        ),
        const SizedBox(),
        LauncherItem(
          path: "/technical-assistance",
          icon: const Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
          ),
          color: Colors.indigo,
          // text: "Technical Assistance",
          text: AppLocalizations.of(context)!.nN_1019,
        ),
        const SizedBox(),
      ],
    );
  }
}

class LauncherItem extends StatelessWidget {
  const LauncherItem({
    Key? key,
    required this.path,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  final String path;
  final Widget icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => GoRouter.of(context).push(path),
      borderRadius: BorderRadius.circular(8),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: .9,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: icon,
                      ),
                    ),
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 5,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
