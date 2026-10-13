import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit monitoring real-time device network interface status.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit({required Connectivity connectivity})
      : _connectivity = connectivity,
        super(true) {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    _checkInitial();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _checkInitial() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isConnected = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
    emit(isConnected);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
