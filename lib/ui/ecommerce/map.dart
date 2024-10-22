import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:nawa_niwasa/locator.dart';

import '../../l10n.dart';
import '../../service/service.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({
    super.key,
    required this.title,
    required this.initialPosition,
    required this.onDone,
  });

  final String title;
  final LatLng initialPosition;
  final Function(LatLng) onDone;

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  TextEditingController placesTextEditingController = TextEditingController();
  LatLng? location;

  @override
  initState() {
    location = widget.initialPosition;
    super.initState();
  }

  handleLocationChange(coordinate) {
    setState(() {
      location = coordinate;
    });
  }

  handleOnDone() {
    if (location == null) return;
    widget.onDone(location!);
  }

  Widget buildLocationInfo(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: StandaloneAddressBuilder(
        location: location,
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // "Selected Location",
                      AppLocalizations.of(context)!.nN_1053,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(snapshot.data ?? "N/A"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    FilledButton(
                      onPressed: handleOnDone,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: MaterialStatePropertyAll(Color(0xFFEE1C25)),
                        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
                      ),
                      // child: const Text("Done"),
                      child: Text(AppLocalizations.of(context)!.nN_1054),
                    )
                  ],
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting) const LinearProgressIndicator()
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    GooglePlacesAutoCompleteTextFormField(
                      textEditingController: placesTextEditingController,
                      googleAPIKey: locate<LocatorConfig>().googlePlacesApiKey,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        // hintText: "Search Location",
                        hintText: AppLocalizations.of(context)!.nN_1052,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      overlayContainer: (child) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                        child: child,
                      ),
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (prediction) {
                        if (prediction.lat != null && prediction.lng != null) {
                          final double latitude = double.parse(prediction.lat!);
                          final double longitude = double.parse(prediction.lng!);
                          final l0 = LatLng(latitude, longitude);
                          handleLocationChange(l0);
                        }
                      },
                      itmClick: (_) {},
                    ),
                    Expanded(
                      child: MapView(
                        onChange: (value) {
                          handleLocationChange(value);

                          /// Clear places auto complete field value
                          placesTextEditingController.clear();
                        },
                        position: location!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          buildLocationInfo(context)
        ],
      ),
    );
  }

  @override
  void dispose() {
    placesTextEditingController.dispose();
    super.dispose();
  }
}

class StandaloneAddressBuilder extends StatelessWidget {
  const StandaloneAddressBuilder({super.key, required this.location, required this.builder});

  final LatLng? location;
  final AsyncWidgetBuilder<String?> builder;

  Future<String?> getAddress() async {
    if (location == null) return "";
    var data = await locate<ReverseGeocodingService>().getAddress("${location?.latitude},${location?.longitude}");
    return data.formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAddress(),
      builder: builder,
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key, required this.onChange, required this.position});

  final Function(LatLng) onChange;
  final LatLng? position;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> cCompleter = Completer<GoogleMapController>();

  late GoogleMapController? _mapController;

  Set<Marker> markers = {};

  @override
  void initState() {
    if (widget.position != null) {
      markers = {
        Marker(
          visible: true,
          markerId: const MarkerId("m0"),
          position: widget.position!,
        )
      };
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position && widget.position != null) {
      markers = {
        Marker(
          visible: true,
          markerId: const MarkerId("m0"),
          position: widget.position!,
        )
      };
      _mapController?.animateCamera(CameraUpdate.newLatLng(widget.position!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: cCompleter.future,
      builder: (context, snapshot) {
        return Column(
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: LinearProgressIndicator(),
              ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  zoom: 11.0,
                  target: widget.position!,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  cCompleter.complete(controller);
                },
                onTap: widget.onChange,
                markers: markers,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
