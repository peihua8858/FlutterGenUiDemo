import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_a2ui/genui_a2ui.dart';
import 'ChatScreenState.dart';
class ChatScreen extends StatefulWidget {
  final String title;
  const ChatScreen({super.key, required this.title});
  @override
  State<ChatScreen> createState() => ChatScreenState();
}
