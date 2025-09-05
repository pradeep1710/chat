import 'package:get/get.dart';

class CallsController extends GetxController {
  // Observable variables
  final RxList<dynamic> _calls = <dynamic>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  
  // Getters
  List<dynamic> get calls => _calls;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  int get currentPage => _currentPage.value;
  
  @override
  void onInit() {
    super.onInit();
    loadCalls();
  }
  
  Future<void> loadCalls({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMore.value = true;
        _calls.clear();
      }
      
      if (!_hasMore.value || _isLoading.value) return;
      
      _isLoading.value = true;
      
      // TODO: Replace with actual API call
      // Simulating API call with dummy data
      await Future.delayed(const Duration(seconds: 1));
      
      final dummyCalls = _generateDummyCalls();
      
      if (refresh) {
        _calls.value = dummyCalls;
      } else {
        _calls.addAll(dummyCalls);
      }
      
      _currentPage.value++;
      _hasMore.value = dummyCalls.length >= 10;
    } catch (e) {
      print('Error loading calls: $e');
      Get.snackbar('Error', 'Failed to load calls');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> refreshCalls() async {
    await loadCalls(refresh: true);
  }
  
  List<dynamic> _generateDummyCalls() {
    // Generate dummy call data for demonstration
    return List.generate(10, (index) {
      final types = ['voice', 'video'];
      final directions = ['incoming', 'outgoing'];
      final statuses = ['answered', 'missed', 'declined'];
      
      return {
        'id': 'call_$index',
        'user': {
          'id': 'user_$index',
          'username': 'User $index',
          'profilePicture': null,
        },
        'type': types[index % types.length],
        'direction': directions[index % directions.length],
        'status': statuses[index % statuses.length],
        'duration': index % 3 == 0 ? 0 : (index + 1) * 60, // Some calls have no duration (missed)
        'createdAt': DateTime.now().subtract(Duration(hours: index)),
      };
    });
  }
}
