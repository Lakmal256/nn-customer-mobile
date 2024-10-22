import 'package:flutter/material.dart';
import 'package:nawa_niwasa/locator.dart';

import '../../service/service.dart';

class LocationSandbox extends StatelessWidget {
  const LocationSandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ReverseGeocodingSandbox(),
      ],
    );
  }
}

class ReverseGeocodingSandbox extends StatefulWidget {
  final String? coordinates;
  const ReverseGeocodingSandbox({super.key, this.coordinates});

  @override
  State<ReverseGeocodingSandbox> createState() => _ReverseGeocodingSandboxState();
}

class _ReverseGeocodingSandboxState extends State<ReverseGeocodingSandbox> {
  late TextEditingController coordinatesTextEditingController;
  Future<ReverseGeocodeAddressResponse>? future;
  late String coordinates;

  @override
  initState() {
    coordinates = widget.coordinates ?? "";
    coordinatesTextEditingController = TextEditingController(text: coordinates);
    super.initState();
  }

  fetchAddress() => setState(() {
        future = locate<ReverseGeocodingService>().getAddress(coordinates);
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            return Text(snapshot.data?.formattedAddress ?? "N/A");
          },
        ),
        TextField(
          controller: coordinatesTextEditingController,
          onChanged: (value) => coordinates = value,
        ),
        TextButton(onPressed: fetchAddress, child: const Text("Reverse Location Coordinates"))
      ],
    );
  }
}

class MapSandbox extends StatefulWidget {
  const MapSandbox({super.key});

  @override
  State<MapSandbox> createState() => _MapSandboxState();
}

class _MapSandboxState extends State<MapSandbox> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
