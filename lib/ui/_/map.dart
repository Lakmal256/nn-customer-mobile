import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSandboxPage extends StatefulWidget {
  const MapSandboxPage({super.key});

  @override
  State<MapSandboxPage> createState() => _MapSandboxPageState();
}

class _MapSandboxPageState extends State<MapSandboxPage> {
  handleLocationChange(LatLng value) async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          MapView(
            onChange: handleLocationChange,
            initialPosition: const LatLng(6.933042853592146, 79.86570619550082),
          ),
        ],
      ),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key, required this.onChange, required this.initialPosition});

  final Function(LatLng) onChange;
  final LatLng initialPosition;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> cCompleter = Completer<GoogleMapController>();

  late Marker cMarker;

  @override
  initState() {
    cMarker = Marker(
      visible: true,
      markerId: const MarkerId("m0"),
      position: widget.initialPosition,
    );
    super.initState();
  }

  handleOnTap(LatLng value) {
    setState(() {
      cMarker = cMarker.copyWith(positionParam: value);
    });
    widget.onChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        zoom: 11.0,
        target: widget.initialPosition,
      ),
      onMapCreated: (GoogleMapController controller) {
        cCompleter.complete(controller);
      },
      onTap: handleOnTap,
      markers: {cMarker},
    );
  }
}

class DeliveryLocationResponse {
  final LatLng position;
  final String address;

  DeliveryLocationResponse({required this.position, required this.address});
}

class AddressFutureBuilder extends StatelessWidget {
  const AddressFutureBuilder({super.key, this.future});

  final Future<DeliveryLocationResponse>? future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        return const SizedBox.shrink();
      },
    );
  }
}
