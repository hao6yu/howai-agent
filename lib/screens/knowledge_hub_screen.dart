import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/knowledge_item.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../services/knowledge_hub_service.dart';
import '../services/subscription_service.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  final KnowledgeHubService _knowledgeHubService = KnowledgeHubService();

  bool _isLoading = false;
  List<KnowledgeItem> _items = [];
  MemoryType? _filterType;
  bool _hasShownEntryUpgradeDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleEntryAccessGate();
      _loadItems();
    });
  }

  void _handleEntryAccessGate() {
    if (_hasShownEntryUpgradeDialog || !mounted) return;

    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    if (subscriptionService.isPremium) return;

    _hasShownEntryUpgradeDialog = true;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Knowledge Hub (Premium)'),
          content: const Text(
            'Knowledge Hub helps HowAI remember your personal preferences, facts, and goals across conversations.\n\nUpgrade to Premium to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Return'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushReplacementNamed(context, '/subscription');
              },
              child: const Text('Go to Subscription'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadItems() async {
    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);
    if (!subscriptionService.isPremium) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _items = [];
        });
      }
      return;
    }

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profileId = profileProvider.selectedProfileId;

    if (profileId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _knowledgeHubService.getKnowledgeItemsForProfile(
        profileId,
        memoryType: _filterType,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } catch (_) {
      // Silence noisy load errors here; entry/access handling already informs user.
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewItem() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profileId = profileProvider.selectedProfileId;
    if (profileId == null) return;

    final created = await _showItemEditorDialog(
      title: 'New Memory',
      initialTitle: '',
      initialContent: '',
      initialType: MemoryType.fact,
      initialTags: const [],
      initialPinned: false,
      initialActive: true,
    );

    if (created == null) return;

    try {
      await _knowledgeHubService.createKnowledgeItem(
        profileId: profileId,
        title: created.title,
        content: created.content,
        memoryType: created.memoryType,
        tags: created.tags,
        isPinned: created.isPinned,
        isActive: created.isActive,
      );
      await _loadItems();
    } on DuplicateKnowledgeItemException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A similar memory already exists.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create memory.')),
      );
    }
  }

  Future<void> _editItem(KnowledgeItem item) async {
    final updatedDraft = await _showItemEditorDialog(
      title: 'Edit Memory',
      initialTitle: item.title,
      initialContent: item.content,
      initialType: item.memoryType,
      initialTags: item.tags,
      initialPinned: item.isPinned,
      initialActive: item.isActive,
    );

    if (updatedDraft == null) return;

    try {
      await _knowledgeHubService.updateKnowledgeItem(
        item.copyWith(
          title: updatedDraft.title,
          content: updatedDraft.content,
          memoryType: updatedDraft.memoryType,
          tags: updatedDraft.tags,
          isPinned: updatedDraft.isPinned,
          isActive: updatedDraft.isActive,
        ),
      );
      await _loadItems();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update memory.')),
      );
    }
  }

  Future<void> _togglePinned(KnowledgeItem item) async {
    try {
      await _knowledgeHubService.updateKnowledgeItem(
        item.copyWith(isPinned: !item.isPinned),
      );
      await _loadItems();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update pin status.')),
      );
    }
  }

  Future<void> _toggleActive(KnowledgeItem item) async {
    try {
      await _knowledgeHubService.updateKnowledgeItem(
        item.copyWith(isActive: !item.isActive),
      );
      await _loadItems();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update active status.')),
      );
    }
  }

  Future<void> _deleteItem(KnowledgeItem item) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Memory'),
            content:
                const Text('Delete this memory item? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await _knowledgeHubService.deleteKnowledgeItem(item.id!);
      await _loadItems();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete memory.')),
      );
    }
  }

  Future<_KnowledgeDraft?> _showItemEditorDialog({
    required String title,
    required String initialTitle,
    required String initialContent,
    required MemoryType initialType,
    required List<String> initialTags,
    required bool initialPinned,
    required bool initialActive,
  }) async {
    final titleController = TextEditingController(text: initialTitle);
    final contentController = TextEditingController(text: initialContent);
    final tagsController = TextEditingController(text: initialTags.join(', '));

    MemoryType selectedType = initialType;
    bool isPinned = initialPinned;
    bool isActive = initialActive;

    return showDialog<_KnowledgeDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      maxLength: 80,
                    ),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Content'),
                      maxLength: 500,
                      minLines: 2,
                      maxLines: 5,
                    ),
                    DropdownButtonFormField<MemoryType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: MemoryType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(_memoryTypeLabel(type)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'comma, separated, tags',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Pinned'),
                      value: isPinned,
                      onChanged: (value) {
                        setDialogState(() {
                          isPinned = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use in AI context'),
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final trimmedTitle = titleController.text.trim();
                    final trimmedContent = contentController.text.trim();
                    if (trimmedTitle.isEmpty || trimmedContent.isEmpty) {
                      return;
                    }

                    final tags = tagsController.text
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toSet()
                        .toList();

                    Navigator.pop(
                      dialogContext,
                      _KnowledgeDraft(
                        title: trimmedTitle,
                        content: trimmedContent,
                        memoryType: selectedType,
                        tags: tags,
                        isPinned: isPinned,
                        isActive: isActive,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _memoryTypeLabel(MemoryType type) {
    switch (type) {
      case MemoryType.preference:
        return 'Preference';
      case MemoryType.fact:
        return 'Fact';
      case MemoryType.goal:
        return 'Goal';
      case MemoryType.constraint:
        return 'Constraint';
      case MemoryType.other:
        return 'Other';
    }
  }

  Widget _buildPremiumBlockedView(SettingsProvider settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          const Icon(Icons.auto_stories_outlined,
              size: 62, color: Color(0xFF0078D4)),
          const SizedBox(height: 14),
          Text(
            'Knowledge Hub is a Premium feature',
            style: TextStyle(
              fontSize: settings.getScaledFontSize(20),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Save key details once, and HowAI remembers them in future chats so you do not need to repeat yourself.',
            style: TextStyle(
              fontSize: settings.getScaledFontSize(14),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          _buildFeatureCard(
            settings,
            icon: Icons.bookmark_add_outlined,
            title: 'Capture what matters',
            description:
                'Save preferences, goals, and constraints directly from messages.',
          ),
          const SizedBox(height: 10),
          _buildFeatureCard(
            settings,
            icon: Icons.psychology_outlined,
            title: 'Get smarter replies',
            description:
                'Relevant memory is used in context so responses feel more personal and consistent.',
          ),
          const SizedBox(height: 10),
          _buildFeatureCard(
            settings,
            icon: Icons.manage_search_outlined,
            title: 'Control your memory',
            description:
                'Edit, pin, disable, or delete items any time from one place.',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    SettingsProvider settings, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0078D4), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(13),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumEmptyState(SettingsProvider settings) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_stories_outlined,
                  color: Color(0xFF0078D4), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is Knowledge Hub?',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A personal memory space where you save key details once, so HowAI can use them in future replies.',
                      style: TextStyle(
                        fontSize: settings.getScaledFontSize(13),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to get started',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _buildStep(
                settings,
                number: '1',
                text: 'Tap New Memory or use Save from any chat message.',
              ),
              _buildStep(
                settings,
                number: '2',
                text: 'Choose type (Preference, Goal, Fact, Constraint).',
              ),
              _buildStep(
                settings,
                number: '3',
                text: 'Add tags to make memory easier to match later.',
              ),
              _buildStep(
                settings,
                number: '4',
                text: 'Pin critical memories to prioritize them in context.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Example memories',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildExampleMemory(
                settings,
                title: 'Preference',
                content: 'Keep my summaries short and bullet-pointed.',
              ),
              const SizedBox(height: 8),
              _buildExampleMemory(
                settings,
                title: 'Goal',
                content: 'I am preparing for product manager interviews.',
              ),
              const SizedBox(height: 8),
              _buildExampleMemory(
                settings,
                title: 'Constraint',
                content:
                    'Do not include local file paths in translated output.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(
    SettingsProvider settings, {
    required String number,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF0078D4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: settings.getScaledFontSize(13),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleMemory(
    SettingsProvider settings, {
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(12),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0078D4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: settings.getScaledFontSize(13),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Hub'),
        actions: [
          if (subscriptionService.isPremium)
            PopupMenuButton<MemoryType?>(
              icon: const Icon(Icons.filter_list),
              initialValue: _filterType,
              onSelected: (value) {
                setState(() {
                  _filterType = value;
                });
                _loadItems();
              },
              itemBuilder: (context) => [
                const PopupMenuItem<MemoryType?>(
                  value: null,
                  child: Text('All types'),
                ),
                ...MemoryType.values.map(
                  (type) => PopupMenuItem<MemoryType?>(
                    value: type,
                    child: Text(_memoryTypeLabel(type)),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: subscriptionService.isPremium
          ? RefreshIndicator(
              onRefresh: _loadItems,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? _buildPremiumEmptyState(settings)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Card(
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(14, 10, 10, 10),
                                title: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          Chip(
                                            label: Text(_memoryTypeLabel(
                                                item.memoryType)),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          ...item.tags.take(3).map(
                                                (tag) => Chip(
                                                  label: Text(tag),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                              ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (action) {
                                    if (action == 'edit') {
                                      _editItem(item);
                                    } else if (action == 'pin') {
                                      _togglePinned(item);
                                    } else if (action == 'active') {
                                      _toggleActive(item);
                                    } else if (action == 'delete') {
                                      _deleteItem(item);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'pin',
                                      child:
                                          Text(item.isPinned ? 'Unpin' : 'Pin'),
                                    ),
                                    PopupMenuItem(
                                      value: 'active',
                                      child: Text(item.isActive
                                          ? 'Disable in context'
                                          : 'Enable in context'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                                onTap: () => _editItem(item),
                              ),
                            );
                          },
                        ),
            )
          : _buildPremiumBlockedView(settings),
      floatingActionButton: subscriptionService.isPremium
          ? FloatingActionButton.extended(
              onPressed: _createNewItem,
              icon: const Icon(Icons.add),
              label: const Text('New Memory'),
            )
          : null,
    );
  }
}

class _KnowledgeDraft {
  final String title;
  final String content;
  final MemoryType memoryType;
  final List<String> tags;
  final bool isPinned;
  final bool isActive;

  const _KnowledgeDraft({
    required this.title,
    required this.content,
    required this.memoryType,
    required this.tags,
    required this.isPinned,
    required this.isActive,
  });
}
