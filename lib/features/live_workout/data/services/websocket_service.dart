import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/ai_feedback_model.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  void connect(String ipAddress, Function(AiFeedbackModel feedback) onMessageReceived) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://$ipAddress:81'));

      _channel!.stream.listen(
            (message) {
          try {
            final Map<String, dynamic> response = jsonDecode(message.toString());

            if (response['type'] == 'summary') return;

            // بنحول الـ JSON لـ Model ونبعته
            final feedbackModel = AiFeedbackModel.fromJson(response);
            onMessageReceived(feedbackModel);

          } catch (e) {
            log('Error decoding JSON from WebSocket: $e');
          }
        },
        onError: (error) => log('WebSocket Error: $error'),
        onDone: () => log('WebSocket Connection Closed'),
      );
    } catch (e) {
      log('WebSocket Setup Error: $e');
    }
  }

  // الدالة دي الـ Cubit هينادي عليها كل ما الكاميرا تطلع نقط جديدة
  void sendPoseData({required String workoutName, required List<Map<String, dynamic>> points}) {
    if (_channel != null) {
      final payload = {
        "workout": workoutName,
        "points": points,
      };
      _channel!.sink.add(jsonEncode(payload));
    }
  }

  void dispose() {
    _channel?.sink.close();
  }
}