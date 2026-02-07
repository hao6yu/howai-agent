import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/profile.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/knowledge_item.dart';
import 'dart:convert';
import 'sync_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Lazy initialization for sync service to avoid circular dependencies
  SyncService? _syncService;
  SyncService get syncService {
    _syncService ??= SyncService();
    return _syncService!;
  }

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'haogpt.db');
    final db = await openDatabase(
      path,
      version: 16,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Only set basic configuration that's safe during onConfigure
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    // Apply performance optimizations after database is fully opened
    await _optimizeDatabase(db);
    return db;
  }

  // Apply database performance optimizations safely after opening
  Future<void> _optimizeDatabase(Database db) async {
    try {
      // Optimize SQLite settings for performance
      await db
          .execute('PRAGMA synchronous = NORMAL'); // Balance safety/performance
      await db.execute('PRAGMA cache_size = 10000'); // 40MB cache
      await db
          .execute('PRAGMA temp_store = MEMORY'); // Keep temp tables in memory

      // Try WAL mode, but handle gracefully if not supported
      try {
        await db.execute('PRAGMA journal_mode = WAL'); // Write-Ahead Logging
      } catch (e) {
        // WAL mode might not be supported on all platforms, use default mode
        print(
            '[DatabaseService] WAL mode not supported, using default journal mode');
      }
    } catch (e) {
      // If any optimization fails, log but don't crash
      print('[DatabaseService] Some database optimizations failed: $e');
    }
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT,
        characteristics TEXT,
        preferences TEXT,
        avatarPath TEXT
      )
    ''');

    // Create conversations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS conversations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        is_pinned INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        profile_id INTEGER
      )
    ''');

    // Create chat_messages table
    await _createChatMessagesTable(db);

    // Create ai_personalities table
    await _createAIPersonalitiesTable(db);

    // Create content_reports table
    await _createContentReportsTable(db);

    // Create knowledge_items table
    await _createKnowledgeItemsTable(db);

    // Preload default profiles
    await _preloadDefaultProfiles(db);
  }

  Future<void> _preloadDefaultProfiles(Database db) async {
    // Check if profiles already exist
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM profiles'));
    if (count == 0) {
      // Add User's profile
      await db.insert('profiles', {
        'name': 'User',
        'createdAt': DateTime.now().toIso8601String(),
        'characteristics': '{}',
        'preferences': '{}',
        'avatarPath': '',
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE chat_messages ADD COLUMN image_paths TEXT');
    }

    if (oldVersion < 7) {
      try {
        await db.execute(
            'ALTER TABLE chat_messages ADD COLUMN is_welcome_message INTEGER DEFAULT 0');
        // print('Added is_welcome_message column to chat_messages table');
      } catch (e) {
        // print('Error adding is_welcome_message column: $e');
      }
    }

    // Add conversations and conversation_id for multi-convo support
    if (oldVersion < 8) {
      // 1. Create conversations table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS conversations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          is_pinned INTEGER DEFAULT 0,
          created_at TEXT,
          updated_at TEXT,
          profile_id INTEGER
        )
      ''');
      // 2. Add conversation_id to chat_messages
      try {
        await db.execute(
            'ALTER TABLE chat_messages ADD COLUMN conversation_id INTEGER');
      } catch (e) {
        // print('Column conversation_id may already exist: $e');
      }
      // 3. For each profile, create a default conversation and update messages
      final profiles = await db.query('profiles');
      for (final profile in profiles) {
        final convId = await db.insert('conversations', {
          'title': 'First Conversation',
          'is_pinned': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'profile_id': profile['id'],
        });
        await db.update(
          'chat_messages',
          {'conversation_id': convId},
          where:
              'profile_id = ? AND (conversation_id IS NULL OR conversation_id = 0)',
          whereArgs: [profile['id']],
        );
      }
    }

    // Add file_paths column for file attachments support
    if (oldVersion < 9) {
      try {
        await db
            .execute('ALTER TABLE chat_messages ADD COLUMN file_paths TEXT');
        // print('Added file_paths column to chat_messages table');
      } catch (e) {
        // print('Error adding file_paths column: $e');
      }
    }

    // Add location_results column for local discovery feature
    if (oldVersion < 10) {
      try {
        await db.execute(
            'ALTER TABLE chat_messages ADD COLUMN location_results TEXT');
        // print('Added location_results column to chat_messages table');
      } catch (e) {
        // print('Error adding location_results column: $e');
      }
    }

    // Add message_type column for review request messages
    if (oldVersion < 11) {
      try {
        await db.execute(
            'ALTER TABLE chat_messages ADD COLUMN message_type INTEGER DEFAULT 0');
        // print('Added message_type column to chat_messages table');
      } catch (e) {
        // print('Error adding message_type column: $e');
      }
    }

    // Add ai_personalities table
    if (oldVersion < 12) {
      try {
        await _createAIPersonalitiesTable(db);
        // print('Added ai_personalities table');
      } catch (e) {
        // print('Error adding ai_personalities table: $e');
      }
    }

    // Add avatar_path column to ai_personalities table
    if (oldVersion < 13) {
      try {
        await db.execute(
            'ALTER TABLE ai_personalities ADD COLUMN avatar_path TEXT');
        // print('Added avatar_path column to ai_personalities table');
      } catch (e) {
        // print('Error adding avatar_path column to ai_personalities table: $e');
      }
    }

    // Add content_reports table for AI content reporting feature
    if (oldVersion < 14) {
      try {
        await _createContentReportsTable(db);
        // print('Added content_reports table');
      } catch (e) {
        // print('Error adding content_reports table: $e');
      }
    }

    // Add image_urls column for Supabase cloud storage URLs
    if (oldVersion < 15) {
      try {
        await db
            .execute('ALTER TABLE chat_messages ADD COLUMN image_urls TEXT');
        // print('Added image_urls column to chat_messages table');
      } catch (e) {
        // print('Error adding image_urls column: $e');
      }
    }

    if (oldVersion < 16) {
      try {
        await _createKnowledgeItemsTable(db);
      } catch (e) {
        // print('Error adding knowledge_items table: $e');
      }
    }

    // Add avatarPath and createdAt columns if missing
    final columns = await db.rawQuery("PRAGMA table_info(profiles)");
    final hasAvatarPath = columns.any((col) => col['name'] == 'avatarPath');
    final hasCreatedAt = columns.any((col) => col['name'] == 'createdAt');
    if (!hasAvatarPath) {
      await db.execute('ALTER TABLE profiles ADD COLUMN avatarPath TEXT');
    }
    if (!hasCreatedAt) {
      await db.execute('ALTER TABLE profiles ADD COLUMN createdAt TEXT');
    }
  }

  // Helper method to create chat_messages table
  Future<void> _createChatMessagesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        is_user_message INTEGER NOT NULL,
        audio_path TEXT,
        timestamp TEXT NOT NULL,
        profile_id INTEGER,
        image_paths TEXT,
        image_urls TEXT,
        file_paths TEXT,
        is_welcome_message INTEGER DEFAULT 0,
        conversation_id INTEGER,
        location_results TEXT,
        message_type INTEGER DEFAULT 0,
        FOREIGN KEY (profile_id) REFERENCES profiles (id),
        FOREIGN KEY (conversation_id) REFERENCES conversations (id)
      )
    ''');
  }

  // Helper method to create ai_personalities table
  Future<void> _createAIPersonalitiesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ai_personalities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        ai_name TEXT NOT NULL,
        gender TEXT NOT NULL DEFAULT 'neutral',
        age INTEGER NOT NULL DEFAULT 25,
        personality TEXT NOT NULL DEFAULT 'friendly',
        communication_style TEXT NOT NULL DEFAULT 'casual',
        expertise TEXT NOT NULL DEFAULT 'general',
        humor_level TEXT NOT NULL DEFAULT 'moderate',
        response_length TEXT NOT NULL DEFAULT 'moderate',
        interests TEXT NOT NULL DEFAULT '',
        background_story TEXT NOT NULL DEFAULT '',
        avatar_path TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
      )
    ''');
  }

  // Helper method to create content_reports table
  Future<void> _createContentReportsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS content_reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message_id INTEGER NOT NULL,
        report_reason TEXT NOT NULL,
        report_description TEXT,
        created_at TEXT NOT NULL,
        is_resolved INTEGER DEFAULT 0,
        resolution_action TEXT,
        FOREIGN KEY (message_id) REFERENCES chat_messages (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createKnowledgeItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS knowledge_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        conversation_id INTEGER,
        source_message_id INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        memory_type TEXT NOT NULL,
        tags_json TEXT,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE SET NULL,
        FOREIGN KEY (source_message_id) REFERENCES chat_messages (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_knowledge_items_profile_active
      ON knowledge_items(profile_id, is_active, updated_at)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_knowledge_items_profile_type
      ON knowledge_items(profile_id, memory_type)
    ''');
  }

  // Profile CRUD operations
  Future<int> insertProfile(Profile profile) async {
    final db = await database;
    final map = profile.toMap();
    map['characteristics'] = jsonEncode(map['characteristics']);
    map['preferences'] = jsonEncode(map['preferences']);
    return await db.insert('profiles', map);
  }

  Future<List<Profile>> getProfiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('profiles');
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['characteristics'] = jsonDecode(map['characteristics'] ?? '{}');
      map['preferences'] = jsonDecode(map['preferences'] ?? '{}');
      return Profile.fromMap(map);
    });
  }

  Future<Profile?> getProfile(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    final map = Map<String, dynamic>.from(maps.first);
    map['characteristics'] = jsonDecode(map['characteristics'] ?? '{}');
    map['preferences'] = jsonDecode(map['preferences'] ?? '{}');
    return Profile.fromMap(map);
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    final map = profile.toMap();
    map['characteristics'] = jsonEncode(map['characteristics']);
    map['preferences'] = jsonEncode(map['preferences']);
    return await db.update(
      'profiles',
      map,
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'haogpt.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Chat Messages CRUD operations
  Future<int> insertChatMessage(ChatMessage message) async {
    final db = await database;

    // Debug: Log the message being inserted
    // print('[DatabaseService] insertChatMessage called with:');
    // print('[DatabaseService] - message.filePaths: ${message.filePaths}');
    // print('[DatabaseService] - message.message length: ${message.message.length}');
    // print('[DatabaseService] - conversationId: ${message.conversationId}');

    // Enhanced duplicate detection for messages
    // Check for duplicates based on content, conversation, user type, profile, AND file attachments
    String whereClause = 'message = ? AND is_user_message = ?';
    List<dynamic> whereArgs = [message.message, message.isUserMessage ? 1 : 0];

    // Handle conversation_id (can be null)
    if (message.conversationId != null) {
      whereClause += ' AND conversation_id = ?';
      whereArgs.add(message.conversationId);
    } else {
      whereClause += ' AND conversation_id IS NULL';
    }

    // Handle profile_id (can be null)
    if (message.profileId != null) {
      whereClause += ' AND profile_id = ?';
      whereArgs.add(message.profileId);
    } else {
      whereClause += ' AND profile_id IS NULL';
    }

    // IMPORTANT: Also check filePaths to avoid treating messages with different files as duplicates
    final serializedFilePaths =
        message.filePaths != null ? jsonEncode(message.filePaths) : null;
    if (serializedFilePaths != null) {
      whereClause += ' AND file_paths = ?';
      whereArgs.add(serializedFilePaths);
    } else {
      whereClause +=
          ' AND (file_paths IS NULL OR file_paths = "[]" OR file_paths = "")';
    }

    final existingMessages = await db.query(
      'chat_messages',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    // If a duplicate exists, check if it's within a reasonable time window
    if (existingMessages.isNotEmpty) {
      final existingTimestamp = existingMessages.first['timestamp'] as String;
      final existingTime = DateTime.parse(existingTimestamp);
      final currentTime = DateTime.parse(message.timestamp);
      final timeDifference = currentTime.difference(existingTime);

      // Only consider it a duplicate if it's within 30 seconds
      // This allows users to ask the same question again after some time
      if (timeDifference.inSeconds < 10) {
        // print('[DatabaseDuplicate] Prevented duplicate message insertion. Existing ID: ${existingMessages.first['id']}');
        // print('[DatabaseDuplicate] Message content: ${message.message.substring(0, min(50, message.message.length))}...');
        // print('[DatabaseDuplicate] File paths match: ${serializedFilePaths}');
        // print('[DatabaseDuplicate] Time difference: ${timeDifference.inSeconds} seconds');
        return existingMessages.first['id'] as int;
      } else {
        // print('[DatabaseNoDuplicate] Similar message found but outside time window (${timeDifference.inSeconds} seconds)');
        // Allow the message to be inserted as it's not a recent duplicate
      }
    }

    final insertedId = await db.insert('chat_messages', message.toMap());
    // print('[DatabaseInsert] New message inserted with ID: $insertedId, ConversationID: ${message.conversationId}, UserMessage: ${message.isUserMessage}');

    // Sync to Supabase in background (silent, non-blocking)
    _syncMessageToSupabase(message.copyWith(id: insertedId));

    return insertedId;
  }

  // Silent background sync for messages
  void _syncMessageToSupabase(ChatMessage message) {
    // Run in background, don't await
    Future.microtask(() async {
      try {
        await syncService.uploadMessage(message);
      } catch (e) {
        // Silent failure - will retry later via sync queue
      }
    });
  }

  // Batch insert multiple chat messages efficiently using transactions
  Future<List<int>> batchInsertChatMessages(List<ChatMessage> messages) async {
    if (messages.isEmpty) return [];

    final db = await database;
    final stopwatch = Stopwatch()..start();
    final List<int> insertedIds = [];

    await db.transaction((txn) async {
      for (final message in messages) {
        // Check for duplicates within the transaction (simplified check for performance)
        String whereClause =
            'message = ? AND is_user_message = ? AND timestamp > ?';
        final timeThreshold = DateTime.parse(message.timestamp)
            .subtract(Duration(seconds: 10))
            .toIso8601String();
        List<dynamic> whereArgs = [
          message.message,
          message.isUserMessage ? 1 : 0,
          timeThreshold
        ];

        // Handle conversation_id
        if (message.conversationId != null) {
          whereClause += ' AND conversation_id = ?';
          whereArgs.add(message.conversationId);
        } else {
          whereClause += ' AND conversation_id IS NULL';
        }

        final existingMessages = await txn.query(
          'chat_messages',
          where: whereClause,
          whereArgs: whereArgs,
          limit: 1,
        );

        if (existingMessages.isNotEmpty) {
          // Use existing ID instead of inserting duplicate
          insertedIds.add(existingMessages.first['id'] as int);
        } else {
          // Insert new message
          final id = await txn.insert('chat_messages', message.toMap());
          insertedIds.add(id);

          // Queue for background Supabase sync (don't sync in transaction)
          _queueMessageForSync(message.copyWith(id: id));
        }
      }
    });

    final elapsed = stopwatch.elapsedMilliseconds;
    print(
        '[DatabaseService] Batch inserted ${messages.length} messages in ${elapsed}ms');

    return insertedIds;
  }

  // Queue for background sync to avoid blocking the transaction
  final List<ChatMessage> _syncQueue = [];

  void _queueMessageForSync(ChatMessage message) {
    _syncQueue.add(message);
    _processSyncQueue();
  }

  void _processSyncQueue() {
    if (_syncQueue.isEmpty) return;

    Future.microtask(() async {
      final messagesToSync = List<ChatMessage>.from(_syncQueue);
      _syncQueue.clear();

      for (final message in messagesToSync) {
        try {
          await syncService.uploadMessage(message);
        } catch (e) {
          // Silent failure - will retry later via sync queue
        }
      }
    });
  }

  // Batch update multiple messages efficiently
  Future<void> batchUpdateChatMessages(List<ChatMessage> messages) async {
    if (messages.isEmpty) return;

    final db = await database;
    final stopwatch = Stopwatch()..start();

    await db.transaction((txn) async {
      for (final message in messages) {
        if (message.id != null) {
          await txn.update(
            'chat_messages',
            message.toMap(),
            where: 'id = ?',
            whereArgs: [message.id],
          );
        }
      }
    });

    final elapsed = stopwatch.elapsedMilliseconds;
    print(
        '[DatabaseService] Batch updated ${messages.length} messages in ${elapsed}ms');
  }

  Future<int> updateChatMessage(ChatMessage message) async {
    final db = await database;
    return await db.update(
      'chat_messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<List<ChatMessage>> getChatMessages(
      {int? profileId, int limit = 100, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;

    if (profileId != null) {
      maps = await db.query(
        'chat_messages',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );
    } else {
      maps = await db.query(
        'chat_messages',
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );
    }

    final messages =
        List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
    return messages.reversed.toList(); // Return in chronological order
  }

  Future<int> deleteAllChatMessages({int? profileId}) async {
    final db = await database;
    if (profileId != null) {
      return await db.delete(
        'chat_messages',
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
    } else {
      return await db.delete('chat_messages');
    }
  }

  Future<int> deleteChatMessagesBefore(DateTime date, {int? profileId}) async {
    final db = await database;
    String whereClause = 'timestamp < ?';
    List<dynamic> whereArgs = [date.toIso8601String()];

    if (profileId != null) {
      whereClause += ' AND profile_id = ?';
      whereArgs.add(profileId);
    }

    return await db.delete(
      'chat_messages',
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<int> clearChatMessagesAudioFiles() async {
    final db = await database;
    // We're not actually deleting the files here, just the references
    // The actual file deletion should be handled separately
    return await db.update(
      'chat_messages',
      {'audio_path': null},
      where: 'audio_path IS NOT NULL',
    );
  }

  // Add a method to check database integrity and reset if needed
  Future<bool> checkAndRepairDatabase() async {
    try {
      final db = await database;

      // Check if chat_messages table exists
      final tableCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='chat_messages'");

      if (tableCheck.isEmpty) {
        // print('chat_messages table missing, resetting database');
        await resetDatabase();
        return true;
      }

      // print('Database integrity check passed');
      return false;
    } catch (e) {
      // print('Error checking database: $e');
      await resetDatabase();
      return true;
    }
  }

  // Method to completely reset the database
  Future<void> resetDatabase() async {
    try {
      // Close the current database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Delete the database file
      String path = join(await getDatabasesPath(), 'haogpt.db');
      await databaseFactory.deleteDatabase(path);

      // print('Database deleted, will be recreated on next access');

      // Reinitialize database (this will trigger onCreate)
      _database = await _initDatabase();
    } catch (e) {
      // print('Error resetting database: $e');
    }
  }

  // Add methods to update specific aspects of the profile
  Future<void> updateProfileCharacteristics(
      int profileId, Map<String, dynamic> characteristics) async {
    final profile = await getProfile(profileId);
    if (profile != null) {
      final updatedCharacteristics =
          Map<String, dynamic>.from(profile.characteristics);
      updatedCharacteristics.addAll(characteristics);

      final updatedProfile = profile.copyWith(
        characteristics: updatedCharacteristics,
      );

      await updateProfile(updatedProfile);
    }
  }

  Future<void> updateProfilePreferences(
      int profileId, Map<String, dynamic> preferences) async {
    final profile = await getProfile(profileId);
    if (profile != null) {
      final updatedPreferences = Map<String, dynamic>.from(profile.preferences);
      updatedPreferences.addAll(preferences);

      final updatedProfile = profile.copyWith(
        preferences: updatedPreferences,
      );

      await updateProfile(updatedProfile);
    }
  }

  // Conversation CRUD
  Future<int> insertConversation(Map<String, dynamic> conversation) async {
    final db = await database;
    final insertedId = await db.insert('conversations', conversation);

    // Sync to Supabase in background (silent, non-blocking)
    _syncConversationToSupabase(conversation, insertedId);

    return insertedId;
  }

  // Silent background sync for conversations
  void _syncConversationToSupabase(
      Map<String, dynamic> conversationData, int localId) {
    // Run in background, don't await
    Future.microtask(() async {
      try {
        final conv = Conversation.fromMap({...conversationData, 'id': localId});
        await syncService.uploadConversation(conv);
      } catch (e) {
        // Silent failure - will retry later via sync queue
      }
    });
  }

  Future<int> updateConversation(Map<String, dynamic> conversation) async {
    final db = await database;
    return await db.update(
      'conversations',
      conversation,
      where: 'id = ?',
      whereArgs: [conversation['id']],
    );
  }

  Future<int> deleteConversation(int id) async {
    final db = await database;
    return await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getConversations(
      {int? profileId, bool pinnedFirst = true}) async {
    final db = await database;
    String orderBy =
        pinnedFirst ? 'is_pinned DESC, updated_at DESC' : 'updated_at DESC';
    if (profileId != null) {
      return await db.query(
        'conversations',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: orderBy,
      );
    } else {
      return await db.query('conversations', orderBy: orderBy);
    }
  }

  // Get all conversations (for migration)
  Future<List<Map<String, dynamic>>> getAllConversations() async {
    final db = await database;
    return await db.query('conversations', orderBy: 'created_at ASC');
  }

  // Get a single conversation by ID
  Future<Map<String, dynamic>?> getConversation(int id) async {
    final db = await database;
    final results = await db.query('conversations',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  // Get messages for a specific conversation
  Future<List<Map<String, dynamic>>> getConversationMessages(
      int conversationId) async {
    final db = await database;
    return await db.query(
      'chat_messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<int> deleteAllConversations({int? profileId}) async {
    final db = await database;
    if (profileId != null) {
      return await db.delete(
        'conversations',
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
    } else {
      return await db.delete('conversations');
    }
  }

  // AI Personality CRUD operations
  Future<int> insertAIPersonality(dynamic aiPersonality) async {
    final db = await database;
    return await db.insert('ai_personalities', aiPersonality.toMap());
  }

  Future<dynamic> getAIPersonalityForProfile(int profileId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_personalities',
      where: 'profile_id = ? AND is_active = 1',
      whereArgs: [profileId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    // We need to import the AIPersonality model, but to avoid circular import,
    // we'll return the map and let the provider handle the conversion
    return maps.first;
  }

  Future<int> updateAIPersonality(dynamic aiPersonality) async {
    final db = await database;
    return await db.update(
      'ai_personalities',
      aiPersonality.toMap(),
      where: 'id = ?',
      whereArgs: [aiPersonality.id],
    );
  }

  Future<int> deleteAIPersonality(int id) async {
    final db = await database;
    return await db.delete(
      'ai_personalities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAIPersonalitiesForProfile(
      int profileId) async {
    final db = await database;
    return await db.query(
      'ai_personalities',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'is_active DESC, updated_at DESC',
    );
  }

  // Knowledge Hub CRUD operations
  Future<int> insertKnowledgeItem(KnowledgeItem item) async {
    final db = await database;
    return await db.insert('knowledge_items', item.toMap());
  }

  Future<List<KnowledgeItem>> getKnowledgeItemsForProfile(
    int profileId, {
    bool activeOnly = false,
    int? limit,
    String? memoryType,
  }) async {
    final db = await database;
    final where = <String>['profile_id = ?'];
    final args = <dynamic>[profileId];

    if (activeOnly) {
      where.add('is_active = 1');
    }

    if (memoryType != null && memoryType.isNotEmpty) {
      where.add('memory_type = ?');
      args.add(memoryType);
    }

    final maps = await db.query(
      'knowledge_items',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'is_pinned DESC, updated_at DESC',
      limit: limit,
    );

    return maps.map(KnowledgeItem.fromMap).toList();
  }

  Future<KnowledgeItem?> getKnowledgeItemById(int id) async {
    final db = await database;
    final maps = await db.query(
      'knowledge_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return KnowledgeItem.fromMap(maps.first);
  }

  Future<int> updateKnowledgeItem(KnowledgeItem item) async {
    final db = await database;
    if (item.id == null) return 0;
    return await db.update(
      'knowledge_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteKnowledgeItem(int id) async {
    final db = await database;
    return await db.delete(
      'knowledge_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearKnowledgeItemsForProfile(int profileId) async {
    final db = await database;
    return await db.delete(
      'knowledge_items',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
  }
}
