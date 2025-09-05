import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  final RxBool _isConnected = true.obs;
  final Rx<ConnectivityResult> _connectionType = ConnectivityResult.none.obs;
  
  bool get isConnected => _isConnected.value;
  ConnectivityResult get connectionType => _connectionType.value;
  
  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
  
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _connectionType.value = result;
    _isConnected.value = result != ConnectivityResult.none;
    
    if (result == ConnectivityResult.none) {
      Get.snackbar(
        'No Internet',
        'Please check your connection',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } else if (_isConnected.value) {
      // Only show connection restored if we were previously disconnected
      if (_connectionType.value == ConnectivityResult.none) {
        Get.snackbar(
          'Connected',
          'Internet connection restored',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
  
  String getConnectionTypeString() {
    switch (_connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      default:
        return 'No Connection';
    }
  }
}