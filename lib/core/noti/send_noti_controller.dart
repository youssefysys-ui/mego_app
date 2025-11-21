import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FCMNotificationSender extends GetxController {
  // Firebase Project ID - Update this with your project ID
  static const String _projectId = 'ya3a-app';
  //'servicesapp2024';
  // FCM endpoint using HTTP v1 API
  static String get _fcmEndpoint => 
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  /// Get OAuth2 access token using service account credentials
  static Future<String> _getAccessToken() async {
    /*
      "project_info": {
    "project_number": "199212985609",
    "project_id": "ya3a-app",
    "storage_bucket": "ya3a-app.firebasestorage.app"
  },
    */
    // Service Account JSON credentials
    // Get this from Firebase Console > Project Settings > Service Accounts > Generate New Private Key
    final serviceAccountJson = {
    "type": "service_account",
  "project_id": "ya3a-app",
  "private_key_id": "e98c312930187f90574cdf9c9be3a798a829f5cb",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCgs4ULu9Q7ZHbB\nfKTZiy5iAkbBtaqbSAddQimwUCyyd5itIqlavZG1Xcyev3egiuRG3Bv6ZRMgrZ7a\nkBZc2vVJZg5e5V97KbokPBgPojcSOPCxN8066Jvq2ULQs9p3oOnVswZ1ERwyynmP\nOwWsptWoZen7h0PWQG9jdbElFSXSBlmYhWN/S8oQ7uM8oN1FThuzdoLijWLrDmKq\nJqSyDCwxkE5iUHDQ2Xq4XVwAba3ciBvkdXTikJV41ofAGU6VtcCOI37AfQvCSWE7\nVtKs3ZNLoKnkxuaOpXabI2AtzER5svAqRjXq25B2dJTFlrl4a2T8+wlAITn8yeHj\npWJVNwsHAgMBAAECggEAFNB7vJPU/uZZzWDgFz9EQDSMRp3Jnbg8H/OoY6pWx7ze\n3Rn+tn6UR1oBXVRuYbBrtdPfmdSKoDJsv2FnTBqeJ6Yc2WS7M8ApWHUiJrA7ktQm\nNMYGAonLXCVM1qxc8R65+tBn1zTiop+AFDGwX/bx+JBOuKICAtewtcCyM5vkHKo6\nNGbylGMggvJToBfOgAE/vgDe3Zfp63DbOhWcHK81MU2qMWtiUekrtAUuncnq9scA\nPH1XE49CGy1wWSePyzPfpQXwX1oKt9oPxFK3as2WSN2DKX4HnRVAB0H06X4ItnWV\nhwYtz+++/rKpBmRbnyPLVKyz15UGr7ZxJXlEp9w8TQKBgQDaSzuD6HcX2HaX+MNG\n9AYRcHqGy3fLrs0gIbEU7D6eR8Z3jwta+rZrz9K26Zq+wiCfy31hyM8uV3WjftWb\nD+yBx/WZ/1LMgNhnLloeHFm0X7ovytwa+K0EQSEUSZj5qld5hyi4B0un2Ojv3pF4\nq9076ErzOIUIVrLP1hi7AAZfzQKBgQC8dZc6+WmfJKVF7fI6UyinG684aH0YG1f+\niugwHcP3uUxGSdIGCiU9xNKF/yYHKeggDeItdk06PdEI+FQ27hlhfVgWoLtxXfpU\ncGeri+pzvWMTZYDn3vz7b8TMWlUna1PsmUMiajPpkS0D6kBB+azFrfO7H6Kjxre6\nlLUETrG6IwKBgGVtfWrN8cAXqQr14C4wpj0mKRhGpBP01YSvgus41eOPcA0PXvRX\n97jiaILqyicGZkg5MbnkpzdeFd/wx+lzna2zrk9ujhdNar+Ojvrcq2We8RDRzjGO\nCD4o0OjvRXAEEP77qRTQ9vs3UwxZOvh5yqLSTTjzswRr3Eurq/P/j/alAoGAb2Df\nu87jiVZTBv0VhzrWb8yAxcmbBMBERP87MhSlWKZ+WZwPL9qXH+ZOtTqR8vHlaexK\nm6urAJzACZkZzEzzWxaFFPpxTRLJe1XjLxNFwJlREImQoXi78q2flVZdtSpNMytw\n7cnuXD+cZw/uYg94+GtR/Gk56ajrtK1mPeF0UBkCgYB/Ek0UzV4cnypYro0O5LNc\nePIos25O8GRCGd7vg8QH48cO48JsB46grsI3xUF+4qkL5itxiMy/CLYZV41WRQIa\nBgA0ufF5cN2WJO85jHxL2wTzAcSo6tOjR1gLsEdtdBzkcVp5PiULOq1YQhAmXAWN\n1qyhWM3rjdJbpRGMeYYFqw==\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@ya3a-app.iam.gserviceaccount.com",
  "client_id": "109875574524975668320",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40ya3a-app.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
    };

    // Required OAuth2 scopes for FCM
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      // Create HTTP client with service account credentials
      http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      // Obtain access credentials
      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();
      
      debugPrint('✅ OAuth2 access token obtained successfully');
      return credentials.accessToken.data;
    } catch (e) {
      debugPrint('💥 Error getting access token: $e');
      rethrow;
    }
  }

  /// Send FCM notification to a specific device using HTTP v1 API
  /// 
  /// [deviceToken] - FCM token of the target device
  /// [title] - Notification title
  /// [body] - Notification body content
  /// [data] - Optional custom data payload
  Future<bool> sendNotificationToDevice({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (deviceToken.isEmpty) {
        debugPrint('❌ Device token is empty');
        return false;
      }

      if (title.isEmpty || body.isEmpty) {
        debugPrint('❌ Title or body is empty');
        return false;
      }

      // Get OAuth2 access token
      final String accessToken = await _getAccessToken();

      // Build FCM v1 message payload
      final Map<String, dynamic> message = {
        "message": {
          "token": deviceToken,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": data ?? {},
          "android": {
            "priority": "high",
            "notification": {
              "channel_id": "yamaa_notifications",
              "sound": "default",
              "notification_priority": "PRIORITY_MAX",
              "visibility": "public",
              "default_sound": true,
              "default_vibrate_timings": true,
            }
          },
          "apns": {
            "headers": {
              "apns-priority": "10",
            },
            "payload": {
              "aps": {
                "alert": {
                  "title": title,
                  "body": body,
                },
                "sound": "default",
                "badge": 1,
                "content-available": 1,
              }
            }
          }
        }
      };

      debugPrint('📤 Sending FCM notification (HTTP v1 API)...');
      debugPrint('📱 To device: ${deviceToken.substring(0, 20)}...');
      debugPrint('📝 Title: $title');
      debugPrint('📄 Body: $body');

      // Send HTTP request
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('✅ Notification sent successfully');
        debugPrint('📊 Response: $responseData');
        
        // Show success feedback
        Get.snackbar(
          'success'.tr,
          'notification_sent_successfully'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          icon: Icon(Icons.check_circle, color: Colors.green[800]),
          duration: const Duration(seconds: 3),
        );
        
        return true;
      } else {
        debugPrint('❌ Failed to send notification');
        debugPrint('📊 Status: ${response.statusCode}');
        debugPrint('📊 Response: ${response.body}');
        
        // Show error feedback
        Get.snackbar(
          'error'.tr,
          'failed_to_send_notification'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          icon: Icon(Icons.error_outline, color: Colors.red[800]),
          duration: const Duration(seconds: 3),
        );
        
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Error sending FCM notification: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      
      // Show error feedback
      Get.snackbar(
        'error'.tr,
        'notification_send_error'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error_outline, color: Colors.red[800]),
        duration: const Duration(seconds: 3),
      );
      
      return false;
    }
  }

  /// Send notification to multiple devices
  /// Note: HTTP v1 API doesn't support batch sending to multiple tokens in one request
  /// This method sends individual notifications to each device
  /// 
  /// [deviceTokens] - List of FCM tokens
  /// [title] - Notification title
  /// [body] - Notification body content
  /// [data] - Optional custom data payload
  Future<int> sendNotificationToMultipleDevices({
    required List<String> deviceTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (deviceTokens.isEmpty) {
        debugPrint('❌ Device tokens list is empty');
        return 0;
      }

      debugPrint('📤 Sending FCM notification to ${deviceTokens.length} devices...');
      debugPrint('📝 Title: $title');
      debugPrint('📄 Body: $body');

      int successCount = 0;
      int failureCount = 0;

      // Send notification to each device individually
      for (String token in deviceTokens) {
        bool sent = await sendNotificationToDevice(
          deviceToken: token,
          title: title,
          body: body,
          data: data,
        );
        
        if (sent) {
          successCount++;
        } else {
          failureCount++;
        }
      }
      
      debugPrint('✅ Notification sent to $successCount devices');
      debugPrint('❌ Failed to send to $failureCount devices');
      
      // Show success feedback
      Get.snackbar(
        'success'.tr,
        'notification_sent_to_devices'.trParams({
          'success': successCount.toString(),
          'total': deviceTokens.length.toString(),
        }),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green[800]),
        duration: const Duration(seconds: 3),
      );
      
      return successCount;
    } catch (e, stackTrace) {
      debugPrint('💥 Error sending FCM notification: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      return 0;
    }
  }

  /// Send chat message notification
  /// Specialized for chat notifications with specific data
  Future<bool> sendChatNotification({
    required String deviceToken,
    required String senderName,
    required String message,
    required String chatId,
    required String brandName,
  }) async {
    final title = 'new_message_from'.trParams({'name': senderName});
    final body = message.length > 100 ? '${message.substring(0, 100)}...' : message;
    
    final data = {
      'type': 'chat_message',
      'chat_id': chatId,
      'sender_name': senderName,
      'brand_name': brandName,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'route': '/chat',
    };

    return await sendNotificationToDevice(
      deviceToken: deviceToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send order notification
  /// Specialized for order updates
  Future<bool> sendOrderNotification({
    required String deviceToken,
    required String orderStatus,
    required String orderId,
    String? brandName,
  }) async {
    final title = 'order_status_update'.tr;
    final body = 'order_status_changed'.trParams({
      'orderId': orderId,
      'status': orderStatus,
    });
    
    final data = {
      'type': 'order_update',
      'order_id': orderId,
      'status': orderStatus,
      'brand_name': brandName ?? '',
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'route': '/orders',
    };

    return await sendNotificationToDevice(
      deviceToken: deviceToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send brand notification
  /// For brand-related updates
  Future<bool> sendBrandNotification({
    required String deviceToken,
    required String brandName,
    required String notificationMessage,
    String? brandId,
  }) async {
    final title = brandName;
    final body = notificationMessage;
    
    final data = {
      'type': 'brand_notification',
      'brand_id': brandId ?? '',
      'brand_name': brandName,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'route': '/brands',
    };

    return await sendNotificationToDevice(
      deviceToken: deviceToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Test notification sender
  /// For development and testing purposes
  Future<bool> sendTestNotification({
    required String deviceToken,
    required String title,
    required String body,
  }) async {
    return await sendNotificationToDevice(
      deviceToken: deviceToken,
      title: title,
      body: body,
      data: {
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}