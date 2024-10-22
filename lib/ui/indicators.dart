import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ProgressIndicatorController extends ValueNotifier<bool> {
  ProgressIndicatorController() : super(false);

  void show() {
    value = true;
    notifyListeners();
  }

  void hide() {
    value = false;
    notifyListeners();
  }
}

class ProgressIndicatorPopup extends StatelessWidget {
  const ProgressIndicatorPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class ConnectivityIndicator extends StatelessWidget {
  ConnectivityIndicator({Key? key}) : super(key: key);

  final Connectivity _connectivity = Connectivity();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _connectivity.onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.none) {
          return Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.black.withOpacity(0.5),
            child: const Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Internet Connection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Please check your connection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class EmptyDataIndicator extends StatelessWidget {
  const EmptyDataIndicator({super.key, this.message, this.description});

  final String? message;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: Colors.orangeAccent,
          size: 50,
        ),
        const SizedBox(height: 10),
        Text(
          message ?? "No data available to display",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 5),
        Text(
          description ?? "There is no available information to present at this time",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}