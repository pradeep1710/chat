import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/api/api_service.dart';
import '../routes/app_routes.dart';

class NewChatController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final TextEditingController searchController = TextEditingController();
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  void onSearchQueryChanged(String query) {
    if (query.isEmpty) {
      users.clear();
      return;
    }

    searchUsers(query);
  }

  Future<void> searchUsers(String query) async {
    try {
      isLoading.value = true;
      final response = await _apiService.searchUsers(query);

      if (response['success'] == true) {
        final userList = (response['users'] as List)
            .map((userJson) => UserModel.fromJson(userJson))
            .toList();
        users.value = userList;
      }
    } catch (e) {
      print('Error searching users: $e');
      Get.snackbar('Error', 'Failed to search for users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startNewChat(UserModel user) async {
    try {
      final response = await _apiService.createPrivateChat(user.id);

      if (response['success'] == true) {
        final chat = response['chat'];
        Get.toNamed(AppRoutes.chatDetail, arguments: {'chat': chat});
      }
    } catch (e) {
      print('Error creating chat: $e');
      Get.snackbar('Error', 'Failed to start a new chat');
    }
  }
}
