import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../providers/conversation_provider.dart';
import '../providers/profile_provider.dart';
import '../models/conversation.dart';
import '../models/profile.dart';
import '../services/database_service.dart';
import '../services/subscription_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ConversationDrawer extends StatefulWidget {
  final int? profileId;
  const ConversationDrawer({Key? key, this.profileId}) : super(key: key);

  @override
  State<ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends State<ConversationDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Ensure keyboard is dismissed when drawer opens, but with slight delay
    // to prevent conflicts with the text field focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(1),
        bottomRight: Radius.circular(1),
      ),
      child: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(1),
            bottomRight: Radius.circular(1),
          ),
        ),
        child: Consumer<ConversationProvider>(
          builder: (context, provider, _) {
            final allConversations = provider.conversations;

            // Filter conversations based on search query
            final filteredConversations = _searchQuery.isEmpty
                ? allConversations
                : allConversations
                    .where((c) => c.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

            final pinned =
                filteredConversations.where((c) => c.isPinned).toList();
            final others =
                filteredConversations.where((c) => !c.isPinned).toList();

            return Column(
              children: [
                // Fixed header section (search bar and spacing)
                SizedBox(height: MediaQuery.of(context).padding.top + 16),

                // Search bar and New Chat button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Search bar
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade800
                                    : Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .searchConversations,
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey.shade600),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // New chat button
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Color(0xFF0078D4), width: 1),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.post_add,
                              color: Color(0xFF0078D4)),
                          tooltip:
                              AppLocalizations.of(context)!.newConversation,
                          onPressed: () {
                            // Clear selection and close drawer
                            provider.clearSelection();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Scrollable conversations section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        // Pinned conversations section
                        if (pinned.isNotEmpty) ...[
                          _sectionHeader(
                              AppLocalizations.of(context)!.pinnedSection),
                          ...pinned.map(
                              (c) => _conversationTile(context, provider, c)),
                          const Divider(
                              height: 24,
                              color: Colors.grey,
                              indent: 16,
                              endIndent: 16),
                        ],

                        // Main conversations section
                        _sectionHeader(
                            AppLocalizations.of(context)!.chatsSection),
                        if (others.isEmpty && _searchQuery.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              AppLocalizations.of(context)!.noConversationsYet,
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else if (others.isEmpty && _searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No conversations matching "$_searchQuery"',
                              style: TextStyle(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...others.map(
                              (c) => _conversationTile(context, provider, c)),
                      ],
                    ),
                  ),
                ),

                // Settings section at bottom
                _buildKnowledgeHubSection(),
                _buildSettingsSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.grey.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getDisplayTitle(Conversation c) {
    // If the title is already a timestamp, show the first part of the message
    if (c.title.startsWith('New Conversation')) {
      // Format the date from the timestamp
      final date = c.createdAt;
      return '${date.month}/${date.day} Conversation';
    }
    return c.title;
  }

  Widget _conversationTile(
      BuildContext context, ConversationProvider provider, Conversation c) {
    final isSelected = provider.selectedConversation?.id == c.id;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 0.0), // Remove vertical padding completely
      minVerticalPadding: 0.0, // Force minimum vertical padding to 0
      visualDensity: VisualDensity.compact, // Make the tile even more compact
      title: Text(
        _getDisplayTitle(c),
        style: TextStyle(
          color:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Created ${_timeAgo(context, c.createdAt)}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade900.withOpacity(0.3)
          : Colors.blue.shade50,
      trailing: IconButton(
        icon: Icon(
          c.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: c.isPinned ? Color(0xFF0078D4) : Colors.grey.shade600,
          size: 20,
        ),
        onPressed: () => provider.pinConversation(c, !c.isPinned),
      ),
      onTap: () {
        provider.selectConversation(c);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  String _timeAgo(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  Future<String?> _resolveAvatarPath(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) return null;

    // If it's already an absolute path and exists, use it
    if (avatarPath.startsWith('/') && File(avatarPath).existsSync()) {
      return avatarPath;
    }

    // If it's a relative path, resolve it relative to app documents directory
    if (avatarPath.startsWith('profiles/')) {
      final appDir = await getApplicationDocumentsDirectory();
      final fullPath = '${appDir.path}/$avatarPath';
      if (File(fullPath).existsSync()) {
        return fullPath;
      }
    }

    return null;
  }

  Widget _buildSettingsSection() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final selectedProfile = profileProvider.profiles.firstWhere(
          (p) => p.id == profileProvider.selectedProfileId,
          orElse: () => Profile(id: 0, name: 'User', createdAt: null),
        );

        final settingsRow = Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: InkWell(
            onTap: () {
              // Close drawer first
              Navigator.pop(context);
              // Navigate to settings
              Navigator.pushNamed(context, '/settings');
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: Theme.of(context).brightness == Brightness.dark
                            ? [
                                const Color(0xFF1E3A5F).withOpacity(
                                    0.8), // More visible dark blue for dark mode
                                const Color(0xFF2C5282).withOpacity(
                                    0.6), // More visible dark blue for dark mode
                              ]
                            : [
                                const Color(0xFF0078D4).withOpacity(
                                    0.1), // Original for light mode
                                const Color(0xFF0078D4).withOpacity(
                                    0.05), // Original for light mode
                              ],
                      ),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2C5282).withOpacity(
                                0.8) // More visible border for dark mode
                            : const Color(0xFF0078D4)
                                .withOpacity(0.3), // Original for light mode
                        width: 2,
                      ),
                    ),
                    child: FutureBuilder<String?>(
                      future: _resolveAvatarPath(selectedProfile.avatarPath),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return CircleAvatar(
                            radius: 18,
                            backgroundImage: FileImage(File(snapshot.data!)),
                          );
                        }
                        return CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            selectedProfile.name.isNotEmpty
                                ? selectedProfile.name
                                    .substring(0, 1)
                                    .toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white // White text for dark mode
                                  : const Color(
                                      0xFF0078D4), // Blue text for light mode
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User Name
                  Expanded(
                    child: Text(
                      selectedProfile.name.isNotEmpty
                          ? selectedProfile.name
                          : 'User',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Settings Icon
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );

        return settingsRow;
      },
    );
  }

  Widget _buildKnowledgeHubSection() {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.blue.shade100,
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.auto_stories_outlined,
              color: const Color(0xFF0078D4),
            ),
            title: const Text('Knowledge Hub'),
            subtitle: Text(
              subscriptionService.isPremium
                  ? 'Manage saved memory'
                  : 'Premium feature',
            ),
            trailing: !subscriptionService.isPremium
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  )
                : const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/knowledge-hub');
            },
          ),
        );
      },
    );
  }
}
