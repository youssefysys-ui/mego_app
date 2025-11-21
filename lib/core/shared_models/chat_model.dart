import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  // Create ChatMessage from JSON (from Supabase)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert ChatMessage to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'message': message,
    };
  }

  // Create a copy with updated fields
  ChatMessage copyWith({
    String? id,
    String? userId,
    String? message,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, userId: $userId, message: $message, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.userId == userId &&
        other.message == message &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    message.hashCode ^
    createdAt.hashCode;
  }
}