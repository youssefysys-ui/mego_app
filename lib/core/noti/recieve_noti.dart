// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:mego_app/core/utils/local_db.dart';


// /// Global function to handle background messages
// /// This must be a top-level function
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   debugPrint('🔔 Handling a background message: ${message.messageId}');
//   debugPrint('📱 Title: ${message.notification?.title}');
//   debugPrint('📄 Body: ${message.notification?.body}');
//   debugPrint('📊 Data: ${message.data}');
// }

// class FCMNotificationReceiver extends GetxController {
//   static final FCMNotificationReceiver _instance = FCMNotificationReceiver._internal();
//   factory FCMNotificationReceiver() => _instance;
//   FCMNotificationReceiver._internal();

//   late FirebaseMessaging _firebaseMessaging;
//   late FlutterLocalNotificationsPlugin _localNotifications;
//   String? _deviceToken;

//   // Notification channel configuration
//   static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
//     'yamaa_notifications', // Channel ID
//     'Yamaa Notifications', // Channel name
//     description: 'Yamaa app notifications', // Channel description
//     importance: Importance.max, // Maximum importance for sound
//     playSound: true,
//     enableVibration: true,
//     enableLights: true,
//     ledColor: Color(0xff5A1E3D),
//     showBadge: true,
//     sound: RawResourceAndroidNotificationSound('notification'), // Custom sound
//   );

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeNotifications();
//   }

//   /// Initialize FCM and local notifications
//   Future<void> _initializeNotifications() async {
//     try {
//       // Initialize Firebase Messaging
//       _firebaseMessaging = FirebaseMessaging.instance;

//       // Initialize Local Notifications
//       _localNotifications = FlutterLocalNotificationsPlugin();

//       // Set up background message handler
//       FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//       // Request permissions
//       await _requestPermissions();

//       // Initialize local notifications
//       await _initializeLocalNotifications();

//       // Get device token
//       await _getDeviceToken();

//       // Set up message listeners
//       _setupMessageListeners();

//       debugPrint('✅ FCM Notifications initialized successfully');
//     } catch (e, stackTrace) {
//       debugPrint('💥 Error initializing notifications: $e');
//       debugPrint('📚 Stack trace: $stackTrace');
//     }
//   }

//   /// Request notification permissions
//   Future<void> _requestPermissions() async {
//     try {
//       // Request FCM permissions
//       NotificationSettings settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );

//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         debugPrint('✅ User granted notification permissions');
//       } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
//         debugPrint('⚠️ User granted provisional notification permissions');
//       } else {
//         debugPrint('❌ User declined or has not accepted notification permissions');
//       }

//       // Request local notification permissions for Android 13+
//       await _localNotifications
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestNotificationsPermission();

//     } catch (e) {
//       debugPrint('💥 Error requesting permissions: $e');
//     }
//   }

//   /// Initialize local notifications
//   Future<void> _initializeLocalNotifications() async {
//     try {
//       // Android initialization settings
//       const AndroidInitializationSettings initializationSettingsAndroid =
//           AndroidInitializationSettings('@mipmap/ic_launcher');

//       // iOS initialization settings
//       const DarwinInitializationSettings initializationSettingsIOS =
//           DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//       );

//       // Combined initialization settings
//       const InitializationSettings initializationSettings =
//           InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS,
//       );

//       // Initialize with settings and callback
//       await _localNotifications.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: _onLocalNotificationTapped,
//       );

//       // Create notification channel for Android
//       await _localNotifications
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(_channel);

//       debugPrint('✅ Local notifications initialized');
//     } catch (e) {
//       debugPrint('💥 Error initializing local notifications: $e');
//     }
//   }

//   /// Get and store device FCM token
//   Future<void> _getDeviceToken() async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         _deviceToken = token;
        
//         // Store token in local storage for later use
//         await storage.write('fcm_token', token);
        
//         debugPrint('📱 FCM Device Token: $token');
//         debugPrint('💾 Token saved to local storage');

//         // Optional: Send token to your server for targeting
//         await _sendTokenToServer(token);
//       }
//     } catch (e) {
//       debugPrint('💥 Error getting device token: $e');
//     }
//   }

//   /// Send token to server (optional)
//   /// You can implement this to store tokens in your backend
//   Future<void> _sendTokenToServer(String token) async {
//     try {
//       // TODO: Implement your server endpoint to store the token
//       // Example:
//       // await http.post(
//       //   Uri.parse('https://your-server.com/api/store-token'),
//       //   body: {
//       //     'user_id': storage.userEmail,
//       //     'device_token': token,
//       //     'platform': Platform.isIOS ? 'ios' : 'android',
//       //   },
//       // );
      
//       debugPrint('📤 Token sent to server (placeholder)');
//     } catch (e) {
//       debugPrint('💥 Error sending token to server: $e');
//     }
//   }

//   /// Set up FCM message listeners
//   void _setupMessageListeners() {
//     // Handle messages when app is in foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint('🔔 ========================================');
//       debugPrint('🔔 FOREGROUND MESSAGE RECEIVED');
//       debugPrint('🔔 Message ID: ${message.messageId}');
//       debugPrint('🔔 Notification Title: ${message.notification?.title}');
//       debugPrint('🔔 Notification Body: ${message.notification?.body}');
//       debugPrint('🔔 Data: ${message.data}');
//       debugPrint('🔔 ========================================');
      
//       _handleForegroundMessage(message);
//     });

//     // Handle messages when app is opened from background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint('🔔 Message clicked (from background): ${message.messageId}');
//       _handleMessageClick(message);
//     });

//     // Handle initial message when app is opened from terminated state
//     _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
//       if (message != null) {
//         debugPrint('🔔 App opened from terminated state: ${message.messageId}');
//         _handleMessageClick(message);
//       }
//     });

//     // Listen for token refresh
//     _firebaseMessaging.onTokenRefresh.listen((String token) {
//       debugPrint('🔄 FCM Token refreshed: $token');
//       _deviceToken = token;
//       storage.write('fcm_token', token);
//       _sendTokenToServer(token);
//     });
//   }

//   /// Handle foreground messages (show local notification)
//   Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     try {
//       debugPrint('🔊 ========================================');
//       debugPrint('🔊 HANDLING FOREGROUND MESSAGE');
      
//       final notification = message.notification;
      
//       // Get title and body from notification OR from data payload
//       String title = notification?.title ?? message.data['title'] ?? 'Yamaa';
//       String body = notification?.body ?? message.data['body'] ?? 'New notification';
      
//       debugPrint('🔊 Title: $title');
//       debugPrint('🔊 Body: $body');
//       debugPrint('🔊 Has notification object: ${notification != null}');
//       debugPrint('🔊 Message data: ${message.data}');
      
//       // Show local notification with sound - ALWAYS show even if notification is null
//       await _showLocalNotification(
//         id: message.hashCode,
//         title: title,
//         body: body,
//         payload: jsonEncode(message.data),
//       );

//       // Handle specific notification types
//       _handleNotificationByType(message);

//       debugPrint('✅ Foreground notification with sound displayed');
//       debugPrint('🔊 ========================================');
//     } catch (e, stackTrace) {
//       debugPrint('💥 Error handling foreground message: $e');
//       debugPrint('💥 Stack trace: $stackTrace');
//     }
//   }

//   /// Show local notification
//   Future<void> _showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     try {
//       debugPrint('📢 ========================================');
//       debugPrint('📢 SHOWING LOCAL NOTIFICATION');
//       debugPrint('📢 ID: $id');
//       debugPrint('📢 Title: $title');
//       debugPrint('📢 Body: $body');
      
//       // Android notification details with enhanced sound configuration
//       final AndroidNotificationDetails androidPlatformChannelSpecifics =
//           AndroidNotificationDetails(
//         'yamaa_notifications',
//         'Yamaa Notifications',
//         channelDescription: 'Yamaa app notifications',
//         importance: Importance.max,
//         priority: Priority.max,
//         playSound: true,
//         enableVibration: true,
//         enableLights: true,
//         ledColor: const Color(0xff5A1E3D),
//         ledOnMs: 1000,
//         ledOffMs: 500,
//         showWhen: true,
//         channelShowBadge: true,
//         onlyAlertOnce: false,
//         ongoing: false,
//         autoCancel: true,
//         silent: false,
//     // Don't set icon here - will use default app icon
//     largeIcon: null,
//         styleInformation: BigTextStyleInformation(
//           body,
//           htmlFormatBigText: false,
//           contentTitle: title,
//           htmlFormatContentTitle: false,
//         ),
//         sound: const RawResourceAndroidNotificationSound('notification'),
//       );

//       // iOS notification details with sound
//       const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//           DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//         sound: 'default', // Use default iOS sound
//         badgeNumber: null,
//         attachments: null,
//         subtitle: null,
//         threadIdentifier: null,
//       );

//       // Combined notification details
//       final NotificationDetails platformChannelSpecifics =
//           NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics,
//       );

//       // Show the notification
//       await _localNotifications.show(
//         id,
//         title,
//         body,
//         platformChannelSpecifics,
//         payload: payload,
//       );

//       debugPrint('✅ Local notification shown successfully!');
//       debugPrint('📢 ========================================');
//     } catch (e, stackTrace) {
//       debugPrint('💥 Error showing local notification: $e');
//       debugPrint('💥 Stack trace: $stackTrace');
//     }
//   }

//   /// Handle notification tap (local notification)
//   void _onLocalNotificationTapped(NotificationResponse response) {
//     try {
//       final payload = response.payload;
//       if (payload != null && payload.isNotEmpty) {
//         final data = jsonDecode(payload) as Map<String, dynamic>;
//         debugPrint('🔔 Local notification tapped with payload: $data');
//         _navigateBasedOnData(data);
//       }
//     } catch (e) {
//       debugPrint('💥 Error handling local notification tap: $e');
//     }
//   }

//   /// Handle message click (FCM)
//   void _handleMessageClick(RemoteMessage message) {
//     try {
//       debugPrint('🔔 FCM message clicked: ${message.data}');
//       _navigateBasedOnData(message.data);
//     } catch (e) {
//       debugPrint('💥 Error handling message click: $e');
//     }
//   }

//   /// Navigate based on notification data
//   void _navigateBasedOnData(Map<String, dynamic> data) {
//     try {
//       final type = data['type'] as String?;
//       final route = data['route'] as String?;

//       debugPrint('🧭 Navigating based on notification type: $type');

//       switch (type) {
//         case 'chat_message':
//           _handleChatNotification(data);
//           break;
//         case 'order_update':
//           _handleOrderNotification(data);
//           break;
//         case 'brand_notification':
//           _handleBrandNotification(data);
//           break;
//         default:
//           if (route != null) {
//             Get.toNamed(route);
//           }
//           break;
//       }
//     } catch (e) {
//       debugPrint('💥 Error navigating based on data: $e');
//     }
//   }

//   /// Handle chat notification navigation
//   void _handleChatNotification(Map<String, dynamic> data) {
//     try {
//       final chatId = data['chat_id'] as String?;
//       final brandName = data['brand_name'] as String?;
      
//       if (chatId != null) {
//         // Navigate to specific chat
//         Get.toNamed('/chat', arguments: {
//           'chat_id': chatId,
//           'brand_name': brandName,
//         });
//       } else {
//         // Navigate to chat list
//         Get.toNamed('/chat_list');
//       }
//     } catch (e) {
//       debugPrint('💥 Error handling chat notification: $e');
//     }
//   }

//   /// Handle order notification navigation
//   void _handleOrderNotification(Map<String, dynamic> data) {
//     try {
//       final orderId = data['order_id'] as String?;
      
//       if (orderId != null) {
//         // Navigate to specific order
//         Get.toNamed('/order_details', arguments: {'order_id': orderId});
//       } else {
//         // Navigate to orders list
//         Get.toNamed('/orders');
//       }
//     } catch (e) {
//       debugPrint('💥 Error handling order notification: $e');
//     }
//   }

//   /// Handle brand notification navigation
//   void _handleBrandNotification(Map<String, dynamic> data) {
//     try {
//       final brandId = data['brand_id'] as String?;
      
//       if (brandId != null) {
//         // Navigate to specific brand
//         Get.toNamed('/brand_details', arguments: {'brand_id': brandId});
//       } else {
//         // Navigate to brands list
//         Get.toNamed('/brands');
//       }
//     } catch (e) {
//       debugPrint('💥 Error handling brand notification: $e');
//     }
//   }

//   /// Handle notification by type (for additional processing)
//   void _handleNotificationByType(RemoteMessage message) {
//     try {
//       final type = message.data['type'] as String?;
      
//       switch (type) {
//         case 'chat_message':
//           _incrementChatBadge();
//           break;
//         case 'order_update':
//           _updateOrderBadge();
//           break;
//         // Add more cases as needed
//       }
//     } catch (e) {
//       debugPrint('💥 Error handling notification by type: $e');
//     }
//   }

//   /// Increment chat badge count
//   void _incrementChatBadge() {
//     try {
//       final currentCount = storage.read<int>('chat_badge_count') ?? 0;
//       storage.write('chat_badge_count', currentCount + 1);
//       debugPrint('💬 Chat badge count: ${currentCount + 1}');
//     } catch (e) {
//       debugPrint('💥 Error incrementing chat badge: $e');
//     }
//   }

//   /// Update order badge
//   void _updateOrderBadge() {
//     try {
//       final currentCount = storage.read<int>('order_badge_count') ?? 0;
//       storage.write('order_badge_count', currentCount + 1);
//       debugPrint('📦 Order badge count: ${currentCount + 1}');
//     } catch (e) {
//       debugPrint('💥 Error updating order badge: $e');
//     }
//   }

//   /// Get current device token
//   String? get deviceToken => _deviceToken;

//   /// Refresh device token
//   Future<String?> refreshToken() async {
//     try {
//       await _firebaseMessaging.deleteToken();
//       return await _firebaseMessaging.getToken();
//     } catch (e) {
//       debugPrint('💥 Error refreshing token: $e');
//       return null;
//     }
//   }

//   /// Subscribe to topic
//   Future<void> subscribeToTopic(String topic) async {
//     try {
//       await _firebaseMessaging.subscribeToTopic(topic);
//       debugPrint('✅ Subscribed to topic: $topic');
//     } catch (e) {
//       debugPrint('💥 Error subscribing to topic: $e');
//     }
//   }

//   /// Unsubscribe from topic
//   Future<void> unsubscribeFromTopic(String topic) async {
//     try {
//       await _firebaseMessaging.unsubscribeFromTopic(topic);
//       debugPrint('✅ Unsubscribed from topic: $topic');
//     } catch (e) {
//       debugPrint('💥 Error unsubscribing from topic: $e');
//     }
//   }

//   /// Clear all notifications
//   Future<void> clearAllNotifications() async {
//     try {
//       await _localNotifications.cancelAll();
//       debugPrint('✅ All notifications cleared');
//     } catch (e) {
//       debugPrint('💥 Error clearing notifications: $e');
//     }
//   }

//   /// Clear specific notification
//   Future<void> clearNotification(int id) async {
//     try {
//       await _localNotifications.cancel(id);
//       debugPrint('✅ Notification $id cleared');
//     } catch (e) {
//       debugPrint('💥 Error clearing notification: $e');
//     }
//   }

//   /// Test notification sound
//   /// Use this method to test if notification sounds are working
//   Future<void> testNotificationSound() async {
//     try {
//       await _showLocalNotification(
//         id: DateTime.now().millisecondsSinceEpoch,
//         title: '🔊 Sound Test',
//         body: 'Testing notification sound - you should hear this!',
//         payload: jsonEncode({'type': 'sound_test'}),
//       );
//       debugPrint('🔊 Test notification with sound sent');
//     } catch (e) {
//       debugPrint('💥 Error testing notification sound: $e');
//     }
//   }

//   /// Check if sound is enabled for notifications
//   Future<bool> isSoundEnabled() async {
//     try {
//       // Check if notifications are enabled
//       final settings = await _firebaseMessaging.getNotificationSettings();
//       final isEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;
//       debugPrint('🔊 Notification sound enabled: $isEnabled');
//       return isEnabled;
//     } catch (e) {
//       debugPrint('💥 Error checking sound status: $e');
//       return false;
//     }
//   }
// }