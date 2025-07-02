import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@singleton
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged
      .map((result) => _hasConnection(result));

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(result);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      _isConnected = _hasConnection(result);
    });
  }

  bool _hasConnection(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
