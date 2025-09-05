import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'message_model.dart';

enum ChatType {
  private,
  group,
  community,
}

class ChatModel extends Equatable {
  final String id;
  final List<UserModel> participants;
  final ChatType type;
  final String? name;
  final String? profilePicture;
  final MessageModel? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final bool isArchived;
  final bool isMuted;
  final DateTime? mutedUntil;
  final List<String> pinnedMessages;
  final Map<String, String> draftMessages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.participants,
    required this.type,
    this.name,
    this.profilePicture,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.isArchived,
    required this.isMuted,
    this.mutedUntil,
    required this.pinnedMessages,
    required this.draftMessages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? json['_id'] ?? '',
      participants: (json['participants'] as List<dynamic>?)
              ?.map((participant) => UserModel.fromJson(participant))
              .toList() ??
          [],
      type: _parseChatType(json['type']),
      name: json['name'],
      profilePicture: json['profilePicture'],
      lastMessage: json['lastMessage'] != null 
          ? MessageModel.fromJson(json['lastMessage']) 
          : null,
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt']) 
          : null,
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
      isArchived: json['isArchived'] ?? false,
      isMuted: json['isMuted'] ?? false,
      mutedUntil: json['mutedUntil'] != null 
          ? DateTime.parse(json['mutedUntil']) 
          : null,
      pinnedMessages: List<String>.from(json['pinnedMessages'] ?? []),
      draftMessages: Map<String, String>.from(json['draftMessages'] ?? {}),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  static ChatType _parseChatType(String? type) {
    switch (type?.toLowerCase()) {
      case 'group':
        return ChatType.group;
      case 'community':
        return ChatType.community;
      default:
        return ChatType.private;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((participant) => participant.toJson()).toList(),
      'type': type.name,
      'name': name,
      'profilePicture': profilePicture,
      'lastMessage': lastMessage?.toJson(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'isArchived': isArchived,
      'isMuted': isMuted,
      'mutedUntil': mutedUntil?.toIso8601String(),
      'pinnedMessages': pinnedMessages,
      'draftMessages': draftMessages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    List<UserModel>? participants,
    ChatType? type,
    String? name,
    String? profilePicture,
    MessageModel? lastMessage,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
    bool? isArchived,
    bool? isMuted,
    DateTime? mutedUntil,
    List<String>? pinnedMessages,
    Map<String, String>? draftMessages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      type: type ?? this.type,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      draftMessages: draftMessages ?? this.draftMessages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String getDisplayName(String currentUserId) {
    if (type == ChatType.private) {
      final otherUser = participants.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () => participants.first,
      );
      return otherUser.username;
    }
    return name ?? 'Unknown Chat';
  }

  String? getDisplayPicture(String currentUserId) {
    if (type == ChatType.private) {
      final otherUser = participants.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () => participants.first,
      );
      return otherUser.profilePicture;
    }
    return profilePicture;
  }

  UserModel? getOtherUser(String currentUserId) {
    if (type == ChatType.private && participants.length >= 2) {
      return participants.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () => participants.first,
      );
    }
    return null;
  }

  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  bool hasUnreadMessages(String userId) {
    return getUnreadCountForUser(userId) > 0;
  }

  String? getDraftMessage(String userId) {
    return draftMessages[userId];
  }

  bool hasDraftMessage(String userId) {
    final draft = getDraftMessage(userId);
    return draft != null && draft.isNotEmpty;
  }

  bool isOnline() {
    if (type == ChatType.private && participants.length >= 2) {
      return participants.any((user) => user.isOnline);
    }
    return false;
  }

  DateTime? getLastSeen(String currentUserId) {
    if (type == ChatType.private) {
      final otherUser = getOtherUser(currentUserId);
      return otherUser?.lastSeen;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        type,
        name,
        profilePicture,
        lastMessage,
        lastMessageAt,
        unreadCount,
        isArchived,
        isMuted,
        mutedUntil,
        pinnedMessages,
        draftMessages,
        createdAt,
        updatedAt,
      ];
}