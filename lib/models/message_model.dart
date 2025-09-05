import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  voice,
  location,
  contact,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final UserModel sender;
  final String content;
  final MessageType type;
  final MediaAttachment? media;
  final String? replyToId;
  final String? forwardedFromId;
  final String? forwardedById;
  final List<String> mentions;
  final MessageStatus status;
  final List<ReadReceipt> readBy;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final bool isStarred;
  final List<String> starredBy;
  final List<MessageReaction> reactions;
  final String? encryptionKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.type,
    this.media,
    this.replyToId,
    this.forwardedFromId,
    this.forwardedById,
    required this.mentions,
    required this.status,
    required this.readBy,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.deletedAt,
    required this.isStarred,
    required this.starredBy,
    required this.reactions,
    this.encryptionKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? json['_id'] ?? '',
      chatId: json['chat'] ?? json['chatId'] ?? '',
      sender: UserModel.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      type: _parseMessageType(json['type']),
      media: json['media'] != null ? MediaAttachment.fromJson(json['media']) : null,
      replyToId: json['replyTo'],
      forwardedFromId: json['forwardedFrom'],
      forwardedById: json['forwardedBy'],
      mentions: List<String>.from(json['mentions'] ?? []),
      status: _parseMessageStatus(json['status']),
      readBy: (json['readBy'] as List<dynamic>?)
              ?.map((item) => ReadReceipt.fromJson(item))
              .toList() ??
          [],
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      isStarred: json['isStarred'] ?? false,
      starredBy: List<String>.from(json['starredBy'] ?? []),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((item) => MessageReaction.fromJson(item))
              .toList() ??
          [],
      encryptionKey: json['encryptionKey'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type?.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'document':
        return MessageType.document;
      case 'voice':
        return MessageType.voice;
      case 'location':
        return MessageType.location;
      case 'contact':
        return MessageType.contact;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat': chatId,
      'sender': sender.toJson(),
      'content': content,
      'type': type.name,
      'media': media?.toJson(),
      'replyTo': replyToId,
      'forwardedFrom': forwardedFromId,
      'forwardedBy': forwardedById,
      'mentions': mentions,
      'status': status.name,
      'readBy': readBy.map((item) => item.toJson()).toList(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'isStarred': isStarred,
      'starredBy': starredBy,
      'reactions': reactions.map((item) => item.toJson()).toList(),
      'encryptionKey': encryptionKey,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    UserModel? sender,
    String? content,
    MessageType? type,
    MediaAttachment? media,
    String? replyToId,
    String? forwardedFromId,
    String? forwardedById,
    List<String>? mentions,
    MessageStatus? status,
    List<ReadReceipt>? readBy,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    bool? isStarred,
    List<String>? starredBy,
    List<MessageReaction>? reactions,
    String? encryptionKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      media: media ?? this.media,
      replyToId: replyToId ?? this.replyToId,
      forwardedFromId: forwardedFromId ?? this.forwardedFromId,
      forwardedById: forwardedById ?? this.forwardedById,
      mentions: mentions ?? this.mentions,
      status: status ?? this.status,
      readBy: readBy ?? this.readBy,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isStarred: isStarred ?? this.isStarred,
      starredBy: starredBy ?? this.starredBy,
      reactions: reactions ?? this.reactions,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        sender,
        content,
        type,
        media,
        replyToId,
        forwardedFromId,
        forwardedById,
        mentions,
        status,
        readBy,
        isEdited,
        editedAt,
        isDeleted,
        deletedAt,
        isStarred,
        starredBy,
        reactions,
        encryptionKey,
        createdAt,
        updatedAt,
      ];
}

class MediaAttachment extends Equatable {
  final String type; // 'image', 'video', 'audio', 'document', 'voice'
  final String url;
  final String filename;
  final int size;
  final int? duration; // for audio/video
  final String? thumbnail; // for video

  const MediaAttachment({
    required this.type,
    required this.url,
    required this.filename,
    required this.size,
    this.duration,
    this.thumbnail,
  });

  factory MediaAttachment.fromJson(Map<String, dynamic> json) {
    return MediaAttachment(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      filename: json['filename'] ?? '',
      size: json['size'] ?? 0,
      duration: json['duration'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'filename': filename,
      'size': size,
      'duration': duration,
      'thumbnail': thumbnail,
    };
  }

  @override
  List<Object?> get props => [type, url, filename, size, duration, thumbnail];
}

class ReadReceipt extends Equatable {
  final String userId;
  final DateTime readAt;

  const ReadReceipt({
    required this.userId,
    required this.readAt,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      userId: json['user'] ?? json['userId'] ?? '',
      readAt: DateTime.parse(json['readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'readAt': readAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [userId, readAt];
}

class MessageReaction extends Equatable {
  final String userId;
  final String emoji;
  final DateTime createdAt;

  const MessageReaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['user'] ?? json['userId'] ?? '',
      emoji: json['emoji'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [userId, emoji, createdAt];
}