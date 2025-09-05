import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String phoneNumber;
  final String username;
  final String? profilePicture;
  final String status;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isVerified;
  final PrivacySettings privacySettings;
  final List<String> blockedUsers;
  final List<Contact> contacts;
  final List<String> archivedChats;
  final List<MutedChat> mutedChats;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.username,
    this.profilePicture,
    required this.status,
    required this.isOnline,
    this.lastSeen,
    required this.isVerified,
    required this.privacySettings,
    required this.blockedUsers,
    required this.contacts,
    required this.archivedChats,
    required this.mutedChats,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profilePicture'],
      status: json['status'] ?? 'Hey there! I am using ChatApp',
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      isVerified: json['isVerified'] ?? false,
      privacySettings: PrivacySettings.fromJson(json['privacySettings'] ?? {}),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((contact) => Contact.fromJson(contact))
              .toList() ??
          [],
      archivedChats: List<String>.from(json['archivedChats'] ?? []),
      mutedChats: (json['mutedChats'] as List<dynamic>?)
              ?.map((chat) => MutedChat.fromJson(chat))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'username': username,
      'profilePicture': profilePicture,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'isVerified': isVerified,
      'privacySettings': privacySettings.toJson(),
      'blockedUsers': blockedUsers,
      'contacts': contacts.map((contact) => contact.toJson()).toList(),
      'archivedChats': archivedChats,
      'mutedChats': mutedChats.map((chat) => chat.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? username,
    String? profilePicture,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
    bool? isVerified,
    PrivacySettings? privacySettings,
    List<String>? blockedUsers,
    List<Contact>? contacts,
    List<String>? archivedChats,
    List<MutedChat>? mutedChats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isVerified: isVerified ?? this.isVerified,
      privacySettings: privacySettings ?? this.privacySettings,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      contacts: contacts ?? this.contacts,
      archivedChats: archivedChats ?? this.archivedChats,
      mutedChats: mutedChats ?? this.mutedChats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        username,
        profilePicture,
        status,
        isOnline,
        lastSeen,
        isVerified,
        privacySettings,
        blockedUsers,
        contacts,
        archivedChats,
        mutedChats,
        createdAt,
        updatedAt,
      ];
}

class PrivacySettings extends Equatable {
  final String lastSeen; // 'everyone', 'contacts', 'nobody'
  final String profilePhoto; // 'everyone', 'contacts', 'nobody'
  final String status; // 'everyone', 'contacts', 'nobody'

  const PrivacySettings({
    required this.lastSeen,
    required this.profilePhoto,
    required this.status,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      lastSeen: json['lastSeen'] ?? 'everyone',
      profilePhoto: json['profilePhoto'] ?? 'everyone',
      status: json['status'] ?? 'everyone',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSeen': lastSeen,
      'profilePhoto': profilePhoto,
      'status': status,
    };
  }

  PrivacySettings copyWith({
    String? lastSeen,
    String? profilePhoto,
    String? status,
  }) {
    return PrivacySettings(
      lastSeen: lastSeen ?? this.lastSeen,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [lastSeen, profilePhoto, status];
}

class Contact extends Equatable {
  final String userId;
  final String name;
  final String phoneNumber;
  final DateTime addedAt;

  const Contact({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.addedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      userId: json['user'] ?? json['userId'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [userId, name, phoneNumber, addedAt];
}

class MutedChat extends Equatable {
  final String chatId;
  final DateTime mutedUntil;

  const MutedChat({
    required this.chatId,
    required this.mutedUntil,
  });

  factory MutedChat.fromJson(Map<String, dynamic> json) {
    return MutedChat(
      chatId: json['chatId'] ?? '',
      mutedUntil: DateTime.parse(json['mutedUntil']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'mutedUntil': mutedUntil.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [chatId, mutedUntil];
}