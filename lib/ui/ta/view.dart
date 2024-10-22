import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nawa_niwasa/service/dto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../l10n.dart';
import '../../locator.dart';
import '../../service/rest.dart';
import '../ui.dart';

class TechnicalAssistanceView extends StatefulWidget {
  const TechnicalAssistanceView({super.key});

  @override
  State<TechnicalAssistanceView> createState() => _TechnicalAssistanceViewState();
}

class _TechnicalAssistanceViewState extends State<TechnicalAssistanceView> {
  CarouselController carouselController = CarouselController();
  late Future<List<TechnicalAssistanceDto>> action;
  late int carouselIndex;
  String filterString = "";

  Future<List<TechnicalAssistanceDto>> fetchAssets() async {
    return await locate<RestService>().getAllTechnicalAssistanceAssets();
  }

  @override
  void initState() {
    action = fetchAssets();
    carouselIndex = 0;
    super.initState();
  }

  setFilterString(String value) {
    setState(() {
      filterString = value;
    });
  }

  handleItemSelect(TechnicalAssistanceDto data) {
    if (data.type == TechnicalAssistanceType.media) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return TechnicalAssistanceMedaView(data: data);
      }));
    } else if (data.type == TechnicalAssistanceType.article) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return TechnicalAssistanceArticleView(data: data);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: action,
      builder: (context, snapshot) {
        late Widget child;

        if (snapshot.connectionState == ConnectionState.waiting) {
          child = const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          child = Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            // "Nothing to show here!"
            child = Center(child: Text(AppLocalizations.of(context)!.nN_1068));
          }

          var data = snapshot.data!
            .where((element) => (element.title ?? "").toLowerCase().contains(filterString.toLowerCase()));

          List<TechnicalAssistanceDto> articles =
              data.where((element) => element.type == TechnicalAssistanceType.article).toList();
          List<TechnicalAssistanceDto> media =
              data.where((element) => element.type == TechnicalAssistanceType.media).toList();

          child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  // "Videos",
                  AppLocalizations.of(context)!.nN_147,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              CarouselSlider(
                items: media
                    .map((item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: VideoThumbnailLong(
                            imageUrl: item.imageUrl,
                            title: item.title ?? "N/A",
                            onSelect: () => handleItemSelect(item),
                          ),
                        ))
                    .toList(),
                options: CarouselOptions(
                  aspectRatio: 2.5,
                  viewportFraction: 1.0,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: false,
                  onPageChanged: (index, _) => setState(() {
                    carouselIndex = index;
                  }),
                ),
                carouselController: carouselController,
              ),
              const SizedBox(height: 10),
              CarouselDots(
                length: media.length,
                index: carouselIndex,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  // "Articles",
                  AppLocalizations.of(context)!.nN_148,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: articles.length,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) => ArticleCard(
                  title: articles[i].title ?? "N/A",
                  body: articles[i].text ?? "N/A",
                  imageUrl: articles[i].imageUrl,
                  onSelect: () => handleItemSelect(articles[i]),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  // "How Can We Help You ?",
                  AppLocalizations.of(context)!.nN_146,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          cursorColor: Colors.red,
                          onChanged: (value) => setFilterString(value),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(context)!.nN_175,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}

class CarouselDots extends StatelessWidget {
  final int length;
  final int index;

  const CarouselDots({super.key, required this.length, required this.index});

  Widget buildDot(BuildContext context, bool isSelected) {
    Color color = isSelected ? Colors.black : Colors.black12;
    return Container(
      height: 8,
      width: 8,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: buildDot(context, index == i),
        ),
      ),
    );
  }
}

class VideoThumbnailLong extends StatelessWidget {
  const VideoThumbnailLong({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onSelect,
  });

  final String imageUrl;
  final String title;
  final void Function() onSelect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.fitWidth,
          color: Colors.black38,
          colorBlendMode: BlendMode.darken,
          errorBuilder: (context, _, __) => Container(color: Colors.black38),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 10.0,
          bottom: 5.0,
          child: FilledButton(
            onPressed: onSelect,
            child: Text(
              // "Play Video",
              AppLocalizations.of(context)!.nN_1065,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.onSelect,
  });

  final String title;
  final String body;
  final String imageUrl;
  final void Function() onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: const BoxDecoration(
              color: Color(0xFFEC2127),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Colors.black12,
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Html(data: body),
                  const SizedBox(height: 15),
                  FilledButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black),
                    ),
                    onPressed: onSelect,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // "More",
                          AppLocalizations.of(context)!.nN_1066,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.keyboard_arrow_down_sharp)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TechnicalAssistanceArticleView extends StatelessWidget {
  const TechnicalAssistanceArticleView({super.key, required this.data});

  final TechnicalAssistanceDto data;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              data.imageUrl,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
              errorBuilder: (context, _, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                data.title ?? "N/A",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Html(data: data.text),
            ),
          ],
        ),
      ),
    );
  }
}

class TechnicalAssistanceMedaView extends StatefulWidget {
  const TechnicalAssistanceMedaView({super.key, this.data});

  final TechnicalAssistanceDto? data;

  @override
  State<TechnicalAssistanceMedaView> createState() => _TechnicalAssistanceMedaView();
}

class _TechnicalAssistanceMedaView extends State<TechnicalAssistanceMedaView> {
  late TechnicalAssistanceDto data;
  late VideoPlayerController _controller;

  @override
  void initState() {
    data = widget.data!;
    if (widget.data != null) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.data!.mediaUrl),
        videoPlayerOptions: VideoPlayerOptions(),
      );
    }
    super.initState();
  }

  setVideo(TechnicalAssistanceDto data) {
    setState(() {
      this.data = data;
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(data.mediaUrl),
        videoPlayerOptions: VideoPlayerOptions(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: _controller.initialize(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.78,
                child: VideoPlayer(_controller),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title ?? "N/A",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    const SizedBox(height: 15),
                    FilledButton(
                      onPressed: () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.standard,
                        minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                        backgroundColor: MaterialStateProperty.all(AppColors.red),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, value, child) {
                          return value.isPlaying
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pause_circle_filled_rounded, color: Colors.white),
                                    SizedBox(width: 10),
                                    // "Pause Video"
                                    Text(AppLocalizations.of(context)!.nN_1067),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, color: Colors.white),
                                    SizedBox(width: 10),
                                    // "Play Video"
                                    Text(AppLocalizations.of(context)!.nN_1065),
                                  ],
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Divider(thickness: 1, height: 1),
              Expanded(
                child: StandaloneVideoArticlesView(
                  onSelect: (item) => setVideo(item),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class StandaloneVideoArticlesView extends StatelessWidget {
  const StandaloneVideoArticlesView({super.key, required this.onSelect});

  final Function(TechnicalAssistanceDto) onSelect;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locate<RestService>().getAllTechnicalAssistanceAssets(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) return const SizedBox.shrink();

        var items = snapshot.data!.where((item) => item.type == TechnicalAssistanceType.media).toList();
        return ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          separatorBuilder: (context, i) => const SizedBox(height: 10),
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => onSelect(items[i]),
            child: _VideoThumbnailLong(
              coverUrl: items[i].imageUrl,
              title: items[i].title ?? "N/A",
            ),
          ),
        );
      },
    );
  }
}

class _VideoThumbnailLong extends StatelessWidget {
  const _VideoThumbnailLong({
    required this.coverUrl,
    required this.title,
  });

  final String coverUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.58,
                child: Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Container(
                    color: Colors.black38,
                  ),
                ),
              ),
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.black38,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
