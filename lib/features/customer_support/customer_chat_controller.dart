import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../core/shared_models/chat_model.dart';

class CustomerChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  // Observable list of messages
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  
  // Supabase client and channel
  late final SupabaseClient _supabase;
  RealtimeChannel? _chatChannel;
  
  String? get currentUserId => _supabase.auth.currentUser?.id;
  
  @override
  void onInit() {
    super.onInit();
    _supabase = Supabase.instance.client;
    _initializeChat();
  }
  
  /// Initialize chat by loading previous messages and subscribing to real-time updates
  Future<void> _initializeChat() async {
    try {
      isLoading.value = true;
      
      // Load previous messages
      await _loadPreviousMessages();
      
      // Subscribe to real-time updates
      _subscribeToMessages();
      
      // Scroll to bottom after loading
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize chat: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load previous messages from database
  Future<void> _loadPreviousMessages() async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .order('created_at', ascending: true)
          .limit(100);
      
      messages.value = (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading messages: $e');
      rethrow;
    }
  }
  
  /// Subscribe to real-time message updates
  void _subscribeToMessages() {
    _chatChannel = _supabase.channel('chat_messages_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            final newMessage = ChatMessage.fromJson(payload.newRecord);
            messages.add(newMessage);
            _scrollToBottom();
          },
        )
        .subscribe();
  }
  
  /// Send a new message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }
    
    if (currentUserId == null) {
      Get.snackbar(
        'Error',
        'You must be logged in to send messages',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isSending.value = true;
      
      final messageData = {
        'user_id': currentUserId,
        'message': messageController.text.trim(),
      };
      
      await _supabase
          .from('chat_messages')
          .insert(messageData);
      
      // Clear input
      messageController.clear();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }
  
  /// Scroll to bottom of chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  /// Format timestamp
  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      // Today - show time only
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  /// Check if message is from current user
  bool isMyMessage(ChatMessage message) {
    return message.userId == currentUserId;
  }
  
  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _chatChannel?.unsubscribe();
    super.onClose();
  }
}
