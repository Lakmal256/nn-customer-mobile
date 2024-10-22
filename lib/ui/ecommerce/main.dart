import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nawa_niwasa/locator.dart';
import 'package:nawa_niwasa/service/service.dart';

import '../../l10n.dart';
import '../ui.dart';

class ECommerceMainView extends StatefulWidget {
  const ECommerceMainView({super.key});

  @override
  State<ECommerceMainView> createState() => _ECommerceMainViewState();
}

class _ECommerceMainViewState extends State<ECommerceMainView> {
  @override
  void initState() {
    initOrder();
    fetchFlashSales();
    super.initState();
  }

  /// Create an order record on the server
  /// Server is using order record to create OrderSummery and the Draft oder
  initOrder() async {
    await locate<DeviceLocationService>().requestServicePermission();
    await locate<DeviceLocationService>().requestLocationPermission();
  }

  fetchFlashSales() async {
    var response = await locate<RestService>().getFlashSales();
    locate<FlashSaleValueNotifier>().setValue(response);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const AspectRatio(
              aspectRatio: 0.85,
              child: BannerHeader(),
            ),
            const SizedBox(height: 10),
            Text(
              // "Shop Our Top Categories",
              AppLocalizations.of(context)!.nN_199,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            const TopCategoriesView(),
            if (locate<PermissionService>().request(['toViewRecentlyViewedItems']))
              const Column(
                children: [
                  SizedBox(height: 10),
                  RecentlyViewedItemsView(),
                ],
              ),
            const SizedBox(height: 10),
            const MostSellingProductsView(),
            const SizedBox(height: 30),
            const QuickLinksView(),
          ],
        ),
      ),
    );
  }
}

class BannerHeader extends StatelessWidget {
  const BannerHeader({super.key});

  handleSearchSelect(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainSearchPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          "assets/images/bg_004.png",
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      if (locate<PermissionService>().request(['toViewNotificationIndicator']))
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: StandaloneNotificationIndicator(),
                        )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () => handleSearchSelect(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          // "Search",
                          AppLocalizations.of(context)!.nN_175,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: _StandaloneBannerSlider(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StandaloneBannerSlider extends StatelessWidget {
  const _StandaloneBannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locate<RestService>().getSuggestedProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _BannerSlider(products: snapshot.data!);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BannerSlider extends StatefulWidget {
  const _BannerSlider({super.key, required this.products});

  final List<ProductDto> products;

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  int carouselIndex = 0;

  Widget buildItem(BuildContext context, ProductDto product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Image.network(
            product.mobileImage ?? "",
            errorBuilder: (context, _, __) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.bottomLeft,
              child: _BannerItemName(
                text: product.name ?? "",
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1,
              height: MediaQuery.of(context).size.height,
              onPageChanged: (i, _) => setState(() => carouselIndex = i),
            ),
            items: (widget.products).map((product) => buildItem(context, product)).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: CarouselDots(
            length: widget.products.length,
            index: carouselIndex,
          ),
        )
      ],
    );
  }
}

class _BannerItemName extends StatelessWidget {
  const _BannerItemName({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    var parts = text.toUpperCase().split(" ");
    var firstName = "${parts.first}\n";
    var rest = parts.sublist(1).fold("", (previousValue, element) => "$previousValue $element");
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: firstName,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: rest.substring(1),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.red,
            ),
          ),
        ],
        style: const TextStyle(
          height: 1.5,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(
              offset: Offset(0.0, 1.5),
              blurRadius: 2,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

class TopCategoriesView extends StatefulWidget {
  const TopCategoriesView({super.key});

  @override
  State<TopCategoriesView> createState() => _TopCategoriesViewState();
}

class _TopCategoriesViewState extends State<TopCategoriesView> {
  late Future<List<ProductCategoryDto>> action;

  @override
  void initState() {
    action = fetchData();
    super.initState();
  }

  Future<List<ProductCategoryDto>> fetchData() => locate<RestService>().getAllProductCategories();

  handleSelect(ProductCategoryDto category) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PageWithAppBar(
        child: ProductsUnderCategoryView(category: category),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: action,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            children: (snapshot.data ?? [])
                .map((item) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: GestureDetector(
                          onTap: () => handleSelect(item),
                          child: TopCategoryItem(
                            title: item.name ?? "N/A",
                            imageUrl: item.imageUrl ?? "",
                          ),
                        ),
                      ),
                    ))
                .toList(),
          );
        }

        if (snapshot.hasError) return Text(snapshot.error.toString());

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class TopCategoryItem extends StatelessWidget {
  const TopCategoryItem({super.key, required this.title, required this.imageUrl});

  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            errorBuilder: (context, _, __) => Container(
              color: Colors.black12,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
          )
        ],
      ),
    );
  }
}

class _PageSection extends StatelessWidget {
  const _PageSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class RecentlyViewedItemsView extends StatelessWidget {
  const RecentlyViewedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locate<RestService>().getAllRecentlyViewedProducts(),
      builder: (context, snapshot) {
        var data = snapshot.data ?? [];
        if (snapshot.hasError) return Text(snapshot.error.toString());
        return _PageSection(
          // title: "Recently Viewed",
          title: AppLocalizations.of(context)!.nN_200,
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              itemCount: data.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                var item = data[index];
                return AspectRatio(
                  aspectRatio: 0.75,
                  child: ProductItemCard(
                    slot1: item.name ?? "N/A",
                    slot2: item.productDescription ?? "N/A",
                    slot3: item.mobileImage ?? "N/A",
                    onAdd: () {
                      if (locate<ListenablePermissionService>().request(['toAddItems'])) {
                        locate<DraftCartHandler>().addItem(item);
                      }
                    },
                    isOnFlashSale: locate<FlashSaleValueNotifier>().isOnFlashSale(item),
                    onSelect: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PageWithAppBar(
                          child: ProductView(product: item),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MostSellingProductsView extends StatelessWidget {
  const MostSellingProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locate<RestService>().getAllMostSellingProducts(),
      builder: (context, snapshot) {
        var data = snapshot.data ?? [];
        if (snapshot.hasError) return Text(snapshot.error.toString());
        return _PageSection(
          // title: "Most Selling Products",
          title: AppLocalizations.of(context)!.nN_202,
          child: SizedBox(
            height: 220,
            child: ListView.separated(
              itemCount: data.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                var item = data[index];
                return AspectRatio(
                  aspectRatio: 0.75,
                  child: ProductItemCard(
                    slot1: item.name ?? "N/A",
                    slot2: item.productDescription ?? "N/A",
                    slot3: item.mobileImage ?? "N/A",
                    onAdd: () {
                      if (locate<ListenablePermissionService>().request(['toAddItems'])) {
                        locate<DraftCartHandler>().addItem(item);
                      }
                    },
                    // onAdd: () => locate<DraftCartHandler>().addItem(item),
                    isOnFlashSale: locate<FlashSaleValueNotifier>().isOnFlashSale(item),
                    onSelect: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PageWithAppBar(
                          child: ProductView(product: item),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class QuickLink {
  QuickLink({
    required this.icon,
    required this.title,
    required this.description,
    required this.path,
  });

  final Widget icon;
  final String title;
  final String description;
  final String path;
}

class QuickLinksView extends StatefulWidget {
  const QuickLinksView({super.key});

  @override
  State<QuickLinksView> createState() => _QuickLinksViewState();
}

class _QuickLinksViewState extends State<QuickLinksView> {
  List<QuickLink> getLinks(BuildContext context) => [
        QuickLink(
          // title: "Search Builder",
          title: AppLocalizations.of(context)!.nN_042,
          description: "${AppLocalizations.of(context)!.nN_040}\n ${AppLocalizations.of(context)!.nN_041}",
          path: "/builders",
          icon: Image.asset("assets/images/icons/icon_0001.png"),
        ),
        QuickLink(
          // title: "BOQ",
          title: AppLocalizations.of(context)!.nN_043,
          description: "${AppLocalizations.of(context)!.nN_040}\n ${AppLocalizations.of(context)!.nN_041}",
          path: "/view-all-boq",
          icon: Image.asset("assets/images/icons/icon_0002.png"),
        ),
        QuickLink(
          // title: "Technical\n Assistance",
          title: AppLocalizations.of(context)!.nN_045,
          description: "${AppLocalizations.of(context)!.nN_040}\n ${AppLocalizations.of(context)!.nN_041}",
          path: "/technical-assistance",
          icon: Image.asset("assets/images/icons/icon_0003.png"),
        )
      ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: getLinks(context)
            .map((item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () {
                        if (locate<ListenablePermissionService>().request(['toUseQuickLinks'])) {
                          GoRouter.of(context).push(item.path);
                        }
                      },
                      child: AspectRatio(
                        aspectRatio: 0.75,
                        child: QuickLinkCard(link: item),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class QuickLinkCard extends StatelessWidget {
  const QuickLinkCard({super.key, required this.link});

  final QuickLink link;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 3,
          color: const Color(0xFF6D6E71),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: link.icon,
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      link.description,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: const Color(0xFF6D6E71),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  link.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EcommerceStorePage extends StatelessWidget {
  const EcommerceStorePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class MainSearchPage extends StatefulWidget {
  const MainSearchPage({super.key});

  @override
  State<MainSearchPage> createState() => _MainSearchPageState();
}

class _MainSearchPageState extends State<MainSearchPage> {
  String filterValue = "";
  late Future<List<ProductDto>> action;

  @override
  initState() {
    action = fetchData();
    super.initState();
  }

  fetchData() => locate<RestService>().filterProducts();

  setFilter(String value) {
    setState(() {
      filterValue = value;
    });
  }

  handleItemSelect(BuildContext context, ProductDto product) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PageWithAppBar(
        child: ProductView(product: product),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          children: [
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
                        onChanged: (value) => setFilter(value),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          // hintText: 'SEARCH PRODUCTS',
                          hintText: AppLocalizations.of(context)!.nN_198.toUpperCase(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: action,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    var items = snapshot.data!
                        .where((item) => (item.name ?? "").toLowerCase().contains(filterValue.toLowerCase()))
                        .toList();
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      itemBuilder: (context, i) {
                        var product = items[i];

                        return GestureDetector(
                          onTap: () => handleItemSelect(context, product),
                          child: Container(
                            // height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(
                                  product.mobileImage ?? "",
                                  height: 75,
                                  width: 75,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, _, __) => const SizedBox.shrink(),
                                ),
                                Flexible(
                                  flex: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name ?? "N/A",
                                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              product.productDescription ?? "N/A",
                                              style: Theme.of(context).textTheme.titleSmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, _) => const SizedBox(height: 10),
                      itemCount: items.length,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
