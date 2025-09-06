import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/new_chat_controller.dart';
import '../../widgets/common/custom_text_field.dart';

class NewChatScreen extends GetView<NewChatController> {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NewChatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: controller.searchController,
              hintText: 'Search for users',
              prefixIcon: Icons.search,
              onChanged: controller.onSearchQueryChanged,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.isTrue) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.users.isEmpty) {
                return const Center(
                  child: Text('No users found'),
                );
              }

              return ListView.builder(
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePicture ?? ''),
                    ),
                    title: Text(user.username ?? ''),
                    subtitle: Text(user.bio ?? ''),
                    onTap: () => controller.startNewChat(user),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
