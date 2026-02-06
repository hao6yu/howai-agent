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

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load Knowledge Hub items.')),
      );
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium,
                size: 52, color: Color(0xFF0078D4)),
            const SizedBox(height: 12),
            Text(
              'Knowledge Hub is a Premium feature',
              style: TextStyle(
                fontSize: settings.getScaledFontSize(18),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to save personal memory and reuse it across conversations.',
              style: TextStyle(fontSize: settings.getScaledFontSize(14)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/subscription'),
              child: const Text('Upgrade to Premium'),
            ),
          ],
        ),
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
                      ? ListView(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25),
                            Icon(Icons.auto_stories_outlined,
                                size: 52,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'No saved memory yet',
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                'Use Save in chat actions or add one here.',
                                style: TextStyle(
                                    fontSize: settings.getScaledFontSize(13)),
                              ),
                            ),
                          ],
                        )
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
