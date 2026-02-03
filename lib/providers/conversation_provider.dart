import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/database_service.dart';

class ConversationProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  Conversation? _selectedConversation;

  List<Conversation> get conversations => _conversations;
  Conversation? get selectedConversation => _selectedConversation;

  Future<void> loadConversations({int? profileId}) async {
    // print('ConversationProvider.loadConversations called with profileId: $profileId');
    final db = DatabaseService();
    final convMaps = await db.getConversations(profileId: profileId);
    _conversations = convMaps.map((m) => Conversation.fromMap(m)).toList();
    // print('ConversationProvider.loadConversations loaded ${_conversations.length} conversations');

    // No longer auto-selecting the first conversation by default
    // We'll leave the current selection as is or null
    if (_selectedConversation != null) {
      // If we had a selection, make sure it still exists in the updated list
      final stillExists = _conversations.any((c) => c.id == _selectedConversation!.id);
      if (!stillExists) {
        _selectedConversation = null;
        // print('ConversationProvider: Previously selected conversation no longer exists, clearing selection');
      }
    } else {
      // print('ConversationProvider: No conversation selected');
    }

    notifyListeners();
  }

  // Helper method to ensure conversations are loaded for a profile
  Future<void> ensureConversationsLoaded(BuildContext context, {int? profileId}) async {
    if (_conversations.isEmpty) {
      // Load conversations without auto-selecting any
      await loadConversations(profileId: profileId);
      // print('ConversationProvider.ensureConversationsLoaded: Loaded conversations without selection');
    }
  }

  void selectConversation(Conversation conversation) {
    // print('ConversationProvider.selectConversation called with conversation: ${conversation.title}, id: ${conversation.id}');
    _selectedConversation = conversation;
    // print('ConversationProvider selected conversation set to: ${_selectedConversation?.title}, id: ${_selectedConversation?.id}');
    notifyListeners();
  }

  // Clear the selected conversation
  void clearSelection() {
    // print('ConversationProvider.clearSelection called');
    _selectedConversation = null;
    notifyListeners();
  }

  Future<void> createConversation(String title, int? profileId) async {
    // print('ConversationProvider.createConversation called with title: $title, profileId: $profileId');
    final db = DatabaseService();
    final now = DateTime.now();
    final conv = Conversation(
      title: title,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
      profileId: profileId,
    );
    final id = await db.insertConversation(conv.toMap());
    // print('ConversationProvider created conversation with id: $id');
    await loadConversations(profileId: profileId);
    _selectedConversation = _conversations.firstWhere((c) => c.id == id);
    // print('ConversationProvider selected new conversation: ${_selectedConversation?.title}, id: ${_selectedConversation?.id}');
    notifyListeners();
  }

  Future<void> pinConversation(Conversation conversation, bool pin) async {
    final db = DatabaseService();
    conversation.isPinned = pin;
    conversation.updatedAt = DateTime.now();
    await db.updateConversation(conversation.toMap());
    await loadConversations(profileId: conversation.profileId);
    notifyListeners();
  }

  // Add rename, delete, etc. as needed
}
