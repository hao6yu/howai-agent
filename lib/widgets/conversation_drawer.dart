import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../providers/conversation_provider.dart';
import '../providers/profile_provider.dart';
import '../models/conversation.dart';
import '../models/profile.dart';
import '../services/database_service.dart';
import '../services/subscription_service.dart';
import 'package:path_provider/path_provider.dart';
import '../core/accessibility/motion_preferences.dart';
import '../core/theme/howai_theme.dart';
import 'new_conversation_button.dart';

enum _ConversationAction { pin, rename, archive, restore, delete }

typedef _ConversationGroup = ({String title, List<Conversation> conversations});

class ConversationDrawer extends StatefulWidget {
  final int? profileId;
  final Future<void> Function()? onClose;

  const ConversationDrawer({super.key, this.profileId, this.onClose});

  @override
  State<ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends State<ConversationDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  Set<int> _messageMatchIds = <int>{};
  int _searchGeneration = 0;
  Timer? _searchDebounce;
  bool _isSearchingMessages = false;
  bool _archivedExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.howaiColors;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(1),
        bottomRight: Radius.circular(1),
      ),
      child: Drawer(
        width: math.min(MediaQuery.sizeOf(context).width * 0.9, 390),
        backgroundColor: colors.canvas,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(1),
            bottomRight: Radius.circular(1),
          ),
        ),
        child: Consumer<ConversationProvider>(
          builder: (context, provider, _) {
            final allConversations = provider.conversations;
            final allArchivedConversations = provider.archivedConversations;

            // Search titles and local message content.
            final filteredConversations = _searchQuery.isEmpty
                ? allConversations
                : allConversations.where(_matchesSearch).toList();
            final filteredArchivedConversations = _searchQuery.isEmpty
                ? allArchivedConversations
                : allArchivedConversations.where(_matchesSearch).toList();

            final pinned = filteredConversations
                .where((c) => c.isPinned)
                .toList();
            final others = filteredConversations
                .where((c) => !c.isPinned)
                .toList();

            return Column(
              children: [
                // Fixed header section (search bar and spacing)
                SizedBox(height: MediaQuery.paddingOf(context).top + 8),

                // Search bar and New Chat button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    children: [
                      // Search bar
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            key: const ValueKey<String>(
                              'conversation_search_field',
                            ),
                            controller: _searchController,
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color ??
                                  Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.searchConversations,
                              hintStyle: TextStyle(color: colors.textTertiary),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 21,
                                color: colors.textSecondary,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              filled: false,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              suffixIcon: AnimatedSwitcher(
                                duration: motionDuration(
                                  context,
                                  HowAIMotion.quick,
                                ),
                                child: _isSearchingMessages
                                    ? const Padding(
                                        key: ValueKey<String>(
                                          'conversation_search_progress',
                                        ),
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox.square(
                                          dimension: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : _searchQuery.isNotEmpty
                                    ? IconButton(
                                        key: const ValueKey<String>(
                                          'conversation_search_clear',
                                        ),
                                        tooltip: 'Clear search',
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged('');
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 19,
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey<String>(
                                          'conversation_search_idle',
                                        ),
                                      ),
                              ),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NewConversationButton(
                        onPressed: () {
                          provider.clearSelection();
                          unawaited(_closeDrawer());
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Scrollable conversations section
                Expanded(
                  child: CustomScrollView(
                    key: const PageStorageKey<String>(
                      'conversation_drawer_scroll',
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: _buildConversationSlivers(
                      context,
                      provider,
                      pinned: pinned,
                      conversations: others,
                      archived: filteredArchivedConversations,
                    ),
                  ),
                ),

                // Settings section at bottom
                _buildWorkspaceNavigation(),
                _buildSettingsSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    final generation = ++_searchGeneration;
    _searchDebounce?.cancel();
    final trimmed = value.trim();
    setState(() {
      _searchQuery = value;
      _messageMatchIds = <int>{};
      _isSearchingMessages = trimmed.isNotEmpty;
    });

    if (trimmed.isEmpty) return;

    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      unawaited(_searchMessages(trimmed, generation));
    });
  }

  Future<void> _searchMessages(String query, int generation) async {
    Set<int> matches = <int>{};
    try {
      matches = await _databaseService.searchConversationMessageIds(
        query,
        profileId: widget.profileId,
      );
    } catch (_) {
      // Title filtering still works if local message search is unavailable.
    }
    if (!mounted || generation != _searchGeneration) return;
    setState(() {
      _messageMatchIds = matches;
      _isSearchingMessages = false;
    });
  }

  bool _matchesSearch(Conversation conversation) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return conversation.title.toLowerCase().contains(query) ||
        (conversation.id != null && _messageMatchIds.contains(conversation.id));
  }

  Future<void> _closeThenNavigate(String routeName) async {
    final navigator = Navigator.of(context);
    await _closeDrawer();
    if (!mounted || !navigator.mounted) return;
    await navigator.pushNamed(routeName);
  }

  Future<void> _closeDrawer() async {
    if (widget.onClose != null) {
      await widget.onClose!();
      return;
    }

    final closeDuration = motionDuration(context, HowAIMotion.drawerTransition);
    Navigator.pop(context);
    if (closeDuration > Duration.zero) {
      await Future<void>.delayed(closeDuration);
    }
  }

  List<_ConversationGroup> _groupConversationsByRecency(
    List<Conversation> conversations,
  ) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final groups = <String, List<Conversation>>{
      'Today': [],
      'Previous 7 days': [],
      'Previous 30 days': [],
      'Older': [],
    };

    for (final conversation in conversations) {
      final age = startOfToday.difference(
        DateTime(
          conversation.updatedAt.year,
          conversation.updatedAt.month,
          conversation.updatedAt.day,
        ),
      );
      if (age.inDays <= 0) {
        groups['Today']!.add(conversation);
      } else if (age.inDays < 7) {
        groups['Previous 7 days']!.add(conversation);
      } else if (age.inDays < 30) {
        groups['Previous 30 days']!.add(conversation);
      } else {
        groups['Older']!.add(conversation);
      }
    }

    return groups.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => (title: entry.key, conversations: entry.value))
        .toList(growable: false);
  }

  List<Widget> _buildConversationSlivers(
    BuildContext context,
    ConversationProvider provider, {
    required List<Conversation> pinned,
    required List<Conversation> conversations,
    required List<Conversation> archived,
  }) {
    final colors = context.howaiColors;
    final groups = _groupConversationsByRecency(conversations);
    final hasResults =
        pinned.isNotEmpty || conversations.isNotEmpty || archived.isNotEmpty;
    final showArchivedRows =
        _archivedExpanded || _searchQuery.trim().isNotEmpty;

    return [
      if (pinned.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: _sectionHeader(AppLocalizations.of(context)!.pinnedSection),
        ),
        _conversationSliver(context, provider, pinned),
        SliverToBoxAdapter(
          child: Divider(
            height: 24,
            color: colors.divider,
            indent: 16,
            endIndent: 16,
          ),
        ),
      ],
      if (!hasResults)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: const Alignment(0, -0.72),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _searchQuery.isEmpty
                    ? AppLocalizations.of(context)!.noConversationsYet
                    : AppLocalizations.of(
                        context,
                      )!.noConversationsMatching(_searchQuery),
                style: TextStyle(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
      else
        for (var index = 0; index < groups.length; index++) ...[
          SliverToBoxAdapter(
            child: _sectionHeader(
              groups[index].title,
              separatedFromPrevious: index > 0,
            ),
          ),
          _conversationSliver(context, provider, groups[index].conversations),
        ],
      if (archived.isNotEmpty) ...[
        const SliverToBoxAdapter(
          child: Divider(height: 24, indent: 16, endIndent: 16),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            key: const ValueKey<String>('archived_conversations_toggle'),
            leading: const Icon(Icons.archive_outlined),
            title: Text('Archived (${archived.length})'),
            trailing: AnimatedRotation(
              turns: showArchivedRows ? 0.5 : 0,
              duration: motionDuration(context, HowAIMotion.quick),
              curve: HowAIMotion.enterCurve,
              child: const Icon(Icons.expand_more_rounded),
            ),
            onTap: () {
              setState(() => _archivedExpanded = !_archivedExpanded);
            },
          ),
        ),
        if (showArchivedRows)
          _conversationSliver(context, provider, archived, isArchived: true),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];
  }

  Widget _conversationSliver(
    BuildContext context,
    ConversationProvider provider,
    List<Conversation> conversations, {
    bool isArchived = false,
  }) {
    return SliverList.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) => _conversationTile(
        context,
        provider,
        conversations[index],
        isArchived: isArchived,
      ),
    );
  }

  Widget _sectionHeader(String title, {bool separatedFromPrevious = false}) {
    final colors = context.howaiColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          top: separatedFromPrevious ? 18 : 0,
          bottom: 8,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
    BuildContext context,
    ConversationProvider provider,
    Conversation c, {
    bool isArchived = false,
  }) {
    final colors = context.howaiColors;
    final isSelected = provider.selectedConversation?.id == c.id;

    return AnimatedContainer(
      key: ValueKey<String>('conversation_tile_${c.id ?? c.clientId}'),
      duration: motionDuration(context, HowAIMotion.quick),
      curve: HowAIMotion.enterCurve,
      color: isSelected ? colors.surface : Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 0,
        visualDensity: VisualDensity.compact,
        title: Text(
          _getDisplayTitle(c),
          style: TextStyle(
            color:
                Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        selected: isSelected,
        selectedTileColor: Colors.transparent,
        trailing: PopupMenuButton<_ConversationAction>(
          tooltip: 'Conversation actions',
          onSelected: (action) =>
              _handleConversationAction(context, provider, c, action),
          itemBuilder: (context) => [
            if (!isArchived)
              PopupMenuItem(
                value: _ConversationAction.pin,
                child: _menuAction(
                  c.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  c.isPinned ? 'Unpin' : 'Pin',
                ),
              ),
            if (!isArchived)
              PopupMenuItem(
                value: _ConversationAction.rename,
                child: _menuAction(Icons.edit_outlined, 'Rename'),
              ),
            PopupMenuItem(
              value: isArchived
                  ? _ConversationAction.restore
                  : _ConversationAction.archive,
              child: _menuAction(
                isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                isArchived ? 'Restore' : 'Archive',
              ),
            ),
            PopupMenuItem(
              value: _ConversationAction.delete,
              child: _menuAction(
                Icons.delete_outline,
                AppLocalizations.of(context)!.delete,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        onTap: isArchived
            ? null
            : () {
                provider.selectConversation(c);
                unawaited(_closeDrawer());
              },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _menuAction(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Future<void> _handleConversationAction(
    BuildContext context,
    ConversationProvider provider,
    Conversation conversation,
    _ConversationAction action,
  ) async {
    switch (action) {
      case _ConversationAction.pin:
        await provider.pinConversation(conversation, !conversation.isPinned);
        break;
      case _ConversationAction.rename:
        await _showRenameDialog(context, provider, conversation);
        break;
      case _ConversationAction.archive:
        await provider.archiveConversation(conversation);
        break;
      case _ConversationAction.restore:
        await provider.restoreConversation(conversation);
        break;
      case _ConversationAction.delete:
        await _confirmDelete(context, provider, conversation);
        break;
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    ConversationProvider provider,
    Conversation conversation,
  ) async {
    final controller = TextEditingController(text: conversation.title);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.trim().isEmpty) return;
    await provider.updateConversationTitle(
      conversationId: conversation.id!,
      title: title,
      profileId: conversation.profileId,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ConversationProvider provider,
    Conversation conversation,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete conversation?'),
            content: Text(
              '“${_getDisplayTitle(conversation)}” and its messages will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final deleted = await provider.deleteConversation(conversation);
    if (!context.mounted || deleted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.somethingWentWrong)),
    );
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
    return Consumer2<ProfileProvider, SubscriptionService>(
      builder: (context, profileProvider, subscriptionService, child) {
        final colors = context.howaiColors;
        final selectedProfile = profileProvider.profiles.firstWhere(
          (p) => p.id == profileProvider.selectedProfileId,
          orElse: () => Profile(
            id: 0,
            name: AppLocalizations.of(context)!.defaultUserName,
            createdAt: null,
          ),
        );
        final displayName =
            selectedProfile.name.trim().isEmpty ||
                selectedProfile.name == 'User'
            ? AppLocalizations.of(context)!.defaultUserName
            : selectedProfile.name;

        final settingsRow = Container(
          margin: const EdgeInsets.only(top: 4, bottom: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.divider, width: 1)),
          ),
          child: InkWell(
            onTap: () {
              unawaited(_closeThenNavigate('/settings'));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(color: colors.divider),
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
                            displayName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subscriptionService.isPremium ? 'Pro' : 'Free',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings Icon
                  Icon(
                    Icons.settings_outlined,
                    color: colors.textSecondary,
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

  Widget _buildWorkspaceNavigation() {
    final colors = context.howaiColors;
    return Container(
      key: const ValueKey<String>('drawer_workspace_navigation'),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWorkspaceDestination(
            icon: Icons.checklist_rounded,
            label: 'Automations',
            onTap: () {
              unawaited(_closeThenNavigate('/actions'));
            },
          ),
          Container(
            height: 1,
            margin: const EdgeInsetsDirectional.only(start: 48),
            color: colors.divider,
          ),
          Consumer<SubscriptionService>(
            builder: (context, subscriptionService, _) {
              return _buildWorkspaceDestination(
                icon: Icons.auto_stories_outlined,
                label: AppLocalizations.of(context)!.knowledgeHubTitle,
                showProBadge: !subscriptionService.isPremium,
                onTap: () {
                  unawaited(_closeThenNavigate('/knowledge-hub'));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceDestination({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showProBadge = false,
  }) {
    final colors = context.howaiColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showProBadge) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.premiumBadge,
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
