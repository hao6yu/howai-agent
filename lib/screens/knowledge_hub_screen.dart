import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../models/knowledge_item.dart';
import '../models/knowledge_source.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import '../services/knowledge_hub_service.dart';
import '../services/knowledge_source_service.dart';
import '../services/subscription_service.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  static const int _memoryTitleMaxLength = KnowledgeHubLimits.titleMaxLength;
  static const int _memoryContentMaxLength =
      KnowledgeHubLimits.contentMaxLength;

  final KnowledgeHubService _knowledgeHubService = KnowledgeHubService();
  final KnowledgeSourceService _knowledgeSourceService =
      KnowledgeSourceService();
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = false;
  List<KnowledgeItem> _items = [];
  MemoryType? _filterType;
  bool _showPinnedOnly = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _hasShownEntryUpgradeDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleEntryAccessGate();
      _loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    final mode = await _showNewMemoryModePicker();
    if (mode == null) return;

    _RecentMessageChoice? initialLinkedMessage;
    if (mode == _NewMemoryMode.fromChat) {
      initialLinkedMessage = await _pickRecentMessageForMemory();
      if (initialLinkedMessage == null) return;
    }

    final created = await _showItemEditorDialog(
      title: 'New Memory',
      initialTitle: mode == _NewMemoryMode.fromChat
          ? _buildMemoryTitle(initialLinkedMessage!.content)
          : '',
      initialContent: mode == _NewMemoryMode.fromChat
          ? _truncateWithEllipsis(
              initialLinkedMessage!.content, _memoryContentMaxLength)
          : '',
      initialType: MemoryType.fact,
      initialTags: const [],
      initialPinned: false,
      initialActive: true,
      profileId: profileId,
      knowledgeItemId: null,
      initialSources: const [],
      initialLinkedMessage: initialLinkedMessage,
      showRecentMessageAction: mode == _NewMemoryMode.fromChat,
      showAttachDocumentAction: mode == _NewMemoryMode.fromDocument,
      showContentField: mode != _NewMemoryMode.fromDocument,
    );

    if (created == null) return;

    try {
      final item = await _knowledgeHubService.createKnowledgeItem(
        profileId: profileId,
        conversationId: created.conversationId,
        sourceMessageId: created.sourceMessageId,
        title: created.title,
        content: created.content,
        memoryType: created.memoryType,
        tags: created.tags,
        isPinned: created.isPinned,
        isActive: created.isActive,
      );
      for (final sourceId in created.sourceIds) {
        await _knowledgeSourceService.linkSourceToKnowledgeItem(
          sourceId: sourceId,
          knowledgeItemId: item.id!,
        );
      }
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
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profileId = profileProvider.selectedProfileId;
    if (profileId == null) return;
    final initialSources = await _knowledgeSourceService.getSourcesForProfile(
      profileId,
      knowledgeItemId: item.id,
    );

    final updatedDraft = await _showItemEditorDialog(
      title: 'Edit Memory',
      initialTitle: item.title,
      initialContent: item.content,
      initialType: item.memoryType,
      initialTags: item.tags,
      initialPinned: item.isPinned,
      initialActive: item.isActive,
      profileId: profileId,
      knowledgeItemId: item.id,
      initialSources: initialSources,
      initialLinkedMessage: null,
      showRecentMessageAction: true,
      showAttachDocumentAction: true,
      showContentField: true,
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

      final existingIds =
          initialSources.map((source) => source.id).whereType<int>().toSet();
      final draftIds = updatedDraft.sourceIds.toSet();

      final toAdd = draftIds.difference(existingIds);
      final toRemove = existingIds.difference(draftIds);

      for (final sourceId in toAdd) {
        await _knowledgeSourceService.linkSourceToKnowledgeItem(
          sourceId: sourceId,
          knowledgeItemId: item.id!,
        );
      }
      for (final sourceId in toRemove) {
        await _knowledgeSourceService.unlinkSourceFromKnowledgeItem(
          sourceId: sourceId,
          knowledgeItemId: item.id!,
        );
      }
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
    required int profileId,
    required int? knowledgeItemId,
    required List<KnowledgeSource> initialSources,
    required _RecentMessageChoice? initialLinkedMessage,
    required bool showRecentMessageAction,
    required bool showAttachDocumentAction,
    required bool showContentField,
  }) async {
    final titleController = TextEditingController(text: initialTitle);
    final contentController = TextEditingController(text: initialContent);
    final tagsController = TextEditingController(text: initialTags.join(', '));

    MemoryType selectedType = initialType;
    bool isPinned = initialPinned;
    bool isActive = initialActive;
    _RecentMessageChoice? linkedMessage = initialLinkedMessage;
    final sourceDrafts =
        initialSources.map((source) => _SourceDraft(source: source)).toList();
    final initialSourceIds =
        initialSources.map((source) => source.id).whereType<int>().toSet();
    bool isAttachingSource = false;

    Future<void> cleanupTransientSources() async {
      final transientIds = sourceDrafts
          .map((entry) => entry.source.id)
          .whereType<int>()
          .where((id) => !initialSourceIds.contains(id))
          .toList();
      for (final sourceId in transientIds) {
        await _knowledgeSourceService.deleteSource(sourceId);
      }
    }

    return showDialog<_KnowledgeDraft>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showRecentMessageAction)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () async {
                            final selected =
                                await _pickRecentMessageForMemory();
                            if (selected == null) return;
                            final clippedContent = _truncateWithEllipsis(
                                selected.content, _memoryContentMaxLength);
                            final wasTruncated = selected.content.length >
                                _memoryContentMaxLength;
                            setDialogState(() {
                              linkedMessage = selected;
                              contentController.text = clippedContent;
                              if (titleController.text.trim().isEmpty) {
                                titleController.text =
                                    _buildMemoryTitle(clippedContent);
                              }
                            });
                            if (wasTruncated && mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Linked message was trimmed to fit memory length.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text('Use Recent Chat Message'),
                        ),
                      ),
                    if (showAttachDocumentAction)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: isAttachingSource
                              ? null
                              : () async {
                                  final file =
                                      await FileService.pickDocumentFile();
                                  if (file == null) return;

                                  setDialogState(() {
                                    isAttachingSource = true;
                                  });

                                  try {
                                    final source = await _knowledgeSourceService
                                        .ingestFileSource(
                                      profileId: profileId,
                                      file: file,
                                      knowledgeItemId: knowledgeItemId,
                                    );
                                    if (!dialogContext.mounted) return;
                                    setDialogState(() {
                                      sourceDrafts
                                          .add(_SourceDraft(source: source));
                                      if (titleController.text.trim().isEmpty) {
                                        titleController.text =
                                            _buildMemoryTitleFromSourceName(
                                                source.displayName);
                                      }
                                    });
                                  } catch (_) {
                                    if (!dialogContext.mounted) return;
                                    ScaffoldMessenger.of(dialogContext)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Failed to attach and extract document.'),
                                      ),
                                    );
                                  } finally {
                                    if (dialogContext.mounted) {
                                      setDialogState(() {
                                        isAttachingSource = false;
                                      });
                                    }
                                  }
                                },
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: Text(
                            isAttachingSource
                                ? 'Attaching document...'
                                : 'Attach Document',
                          ),
                        ),
                      ),
                    if (sourceDrafts.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attached sources',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...sourceDrafts.map((sourceDraft) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        size: 16,
                                        color: _sourceStatusColor(sourceDraft
                                            .source.extractionStatus),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sourceDraft.source.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              _sourceStatusLabel(sourceDraft
                                                  .source.extractionStatus),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _sourceStatusColor(
                                                    sourceDraft.source
                                                        .extractionStatus),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.open_in_new,
                                            size: 16),
                                        splashRadius: 14,
                                        onPressed:
                                            sourceDraft.source.localUri == null
                                                ? null
                                                : () async {
                                                    await OpenFile.open(
                                                        sourceDraft
                                                            .source.localUri!);
                                                  },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16),
                                        splashRadius: 14,
                                        onPressed: () async {
                                          final sourceId =
                                              sourceDraft.source.id;
                                          if (sourceId != null &&
                                              !initialSourceIds
                                                  .contains(sourceId)) {
                                            await _knowledgeSourceService
                                                .deleteSource(sourceId);
                                          }
                                          if (!dialogContext.mounted) return;
                                          setDialogState(() {
                                            sourceDrafts.remove(sourceDraft);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                    if (linkedMessage != null && showRecentMessageAction)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.forum_outlined,
                                color: Color(0xFF0078D4), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                linkedMessage!.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                setDialogState(() {
                                  linkedMessage = null;
                                });
                              },
                              splashRadius: 14,
                            ),
                          ],
                        ),
                      ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      maxLength: _memoryTitleMaxLength,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    ),
                    if (showContentField)
                      TextField(
                        controller: contentController,
                        decoration: const InputDecoration(labelText: 'Content'),
                        maxLength: _memoryContentMaxLength,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        minLines: 2,
                        maxLines: 5,
                      ),
                    if (!showContentField)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Document text stays hidden here. HowAI will use extracted document content in memory context.',
                          style: TextStyle(fontSize: 12),
                        ),
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
                  onPressed: () async {
                    await cleanupTransientSources();
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var trimmedTitle = titleController.text.trim();
                    var trimmedContent = contentController.text.trim();

                    if (trimmedContent.isEmpty && sourceDrafts.isNotEmpty) {
                      final sourceId = sourceDrafts.first.source.id;
                      trimmedContent = await _buildSourceSummaryContent(
                        profileId: profileId,
                        sourceId: sourceId,
                      );
                    }

                    if (trimmedTitle.isEmpty && sourceDrafts.isNotEmpty) {
                      trimmedTitle = _buildMemoryTitleFromSourceName(
                        sourceDrafts.first.source.displayName,
                      );
                    }

                    if (trimmedTitle.isEmpty || trimmedContent.isEmpty) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Add text or attach a readable document before saving.',
                          ),
                        ),
                      );
                      return;
                    }

                    final tags = tagsController.text
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toSet()
                        .toList();

                    if (!dialogContext.mounted) return;
                    Navigator.pop(
                      dialogContext,
                      _KnowledgeDraft(
                        title: trimmedTitle,
                        content: trimmedContent,
                        sourceMessageId: linkedMessage?.messageId,
                        conversationId: linkedMessage?.conversationId,
                        sourceIds: sourceDrafts
                            .map((entry) => entry.source.id)
                            .whereType<int>()
                            .toList(),
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

  Future<_RecentMessageChoice?> _pickRecentMessageForMemory() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profileId = profileProvider.selectedProfileId;
    if (profileId == null) return null;

    final messages = await _databaseService.getChatMessages(
      profileId: profileId,
      limit: 80,
      offset: 0,
    );

    final recent = messages.reversed
        .where((m) => m.message.trim().isNotEmpty)
        .take(30)
        .map((m) => _RecentMessageChoice(
              messageId: m.id,
              conversationId: m.conversationId,
              isUser: m.isUserMessage,
              content: m.message.trim(),
            ))
        .toList();

    if (!mounted) return null;

    if (recent.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No recent messages found.')),
        );
      }
      return null;
    }

    return showModalBottomSheet<_RecentMessageChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select a message to link',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = recent[index];
                      return ListTile(
                        leading: Icon(
                          item.isUser ? Icons.person_outline : Icons.smart_toy,
                          color: item.isUser
                              ? Colors.green.shade600
                              : const Color(0xFF0078D4),
                        ),
                        title: Text(
                          item.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(item.isUser ? 'You' : 'HowAI'),
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<_NewMemoryMode?> _showNewMemoryModePicker() async {
    return showModalBottomSheet<_NewMemoryMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('From Chat'),
                subtitle: const Text('Save a recent message as memory'),
                onTap: () => Navigator.pop(context, _NewMemoryMode.fromChat),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text('Type Manually'),
                subtitle: const Text('Write a custom memory entry'),
                onTap: () => Navigator.pop(context, _NewMemoryMode.manual),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('From Document'),
                subtitle:
                    const Text('Attach file and store extracted knowledge'),
                onTap: () =>
                    Navigator.pop(context, _NewMemoryMode.fromDocument),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildMemoryTitle(String text) {
    final trimmed = text.replaceAll('\n', ' ').trim();
    if (trimmed.isEmpty) return 'Saved Memory';
    if (trimmed.length <= 48) return trimmed;
    return '${trimmed.substring(0, 48)}...';
  }

  String _truncateWithEllipsis(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    if (maxLength <= 3) return value.substring(0, maxLength);
    return '${value.substring(0, maxLength - 3)}...';
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

  String _sourceStatusLabel(KnowledgeExtractionStatus status) {
    switch (status) {
      case KnowledgeExtractionStatus.pending:
        return 'Processing';
      case KnowledgeExtractionStatus.ready:
        return 'Ready';
      case KnowledgeExtractionStatus.failed:
        return 'Failed';
    }
  }

  Color _sourceStatusColor(KnowledgeExtractionStatus status) {
    switch (status) {
      case KnowledgeExtractionStatus.pending:
        return Colors.orange.shade700;
      case KnowledgeExtractionStatus.ready:
        return Colors.green.shade700;
      case KnowledgeExtractionStatus.failed:
        return Colors.red.shade700;
    }
  }

  String _buildMemoryTitleFromSourceName(String displayName) {
    final base = displayName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '').trim();
    if (base.isEmpty) return 'Document Memory';
    if (base.length <= KnowledgeHubLimits.titleMaxLength) return base;
    return '${base.substring(0, KnowledgeHubLimits.titleMaxLength - 3)}...';
  }

  Future<String> _buildSourceSummaryContent({
    required int profileId,
    required int? sourceId,
  }) async {
    if (sourceId == null) return '';
    final chunks = await _databaseService.getKnowledgeSourceChunks(
      profileId: profileId,
      sourceId: sourceId,
      limit: 3,
    );
    if (chunks.isEmpty) return '';
    final merged = chunks
        .map((chunk) => chunk.content.trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n');
    if (merged.length <= KnowledgeHubLimits.contentMaxLength) {
      return merged;
    }
    return merged.substring(0, KnowledgeHubLimits.contentMaxLength);
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

  List<KnowledgeItem> _visibleItems() {
    final query = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      if (_showPinnedOnly && !item.isPinned) {
        return false;
      }
      if (_filterType != null && item.memoryType != _filterType) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }

      final titleMatch = item.title.toLowerCase().contains(query);
      final contentMatch = item.content.toLowerCase().contains(query);
      final tagMatch =
          item.tags.any((tag) => tag.toLowerCase().contains(query));
      return titleMatch || contentMatch || tagMatch;
    }).toList();
  }

  Future<void> _showFilterDialog() async {
    MemoryType? draftType = _filterType;
    bool draftPinnedOnly = _showPinnedOnly;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filters'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<MemoryType?>(
                    initialValue: draftType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      const DropdownMenuItem<MemoryType?>(
                        value: null,
                        child: Text('All types'),
                      ),
                      ...MemoryType.values.map(
                        (type) => DropdownMenuItem<MemoryType?>(
                          value: type,
                          child: Text(_memoryTypeLabel(type)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        draftType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pinned only'),
                    value: draftPinnedOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        draftPinnedOnly = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterType = null;
                      _showPinnedOnly = false;
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterType = draftType;
                      _showPinnedOnly = draftPinnedOnly;
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMemoryRow(KnowledgeItem item) {
    final theme = Theme.of(context);
    final bool isPinned = item.isPinned;
    final borderColor = isPinned
        ? const Color(0xFF0078D4).withValues(alpha: 0.55)
        : (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);
    final background = isPinned
        ? const Color(0xFF0078D4).withValues(alpha: 0.06)
        : (theme.brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.white);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _editItem(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isPinned ? 1.3 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isPinned)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.push_pin,
                    size: 16,
                    color: Color(0xFF0078D4),
                  ),
                ),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFF0078D4).withValues(alpha: 0.10),
                  border: Border.all(
                    color: const Color(0xFF0078D4).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  _memoryTypeLabel(item.memoryType),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF005EA8),
                  ),
                ),
              ),
              if (!item.isActive)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.visibility_off_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
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
                    child: Text(item.isPinned ? 'Unpin' : 'Pin'),
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final subscriptionService = Provider.of<SubscriptionService>(context);
    final visibleItems = _visibleItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Hub'),
        actions: [
          if (subscriptionService.isPremium)
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.filter_list),
                  if (_filterType != null || _showPinnedOnly)
                    const Positioned(
                      right: -1,
                      top: -1,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF0078D4),
                      ),
                    ),
                ],
              ),
              tooltip: 'Filters',
              onPressed: _showFilterDialog,
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
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search memory',
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  _searchQuery = '';
                                                });
                                              },
                                            )
                                          : null,
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  if (_filterType != null || _showPinnedOnly)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (_showPinnedOnly)
                                            InputChip(
                                              label: const Text('Pinned only'),
                                              onDeleted: () {
                                                setState(() {
                                                  _showPinnedOnly = false;
                                                });
                                              },
                                            ),
                                          if (_filterType != null)
                                            InputChip(
                                              label: Text(_memoryTypeLabel(
                                                  _filterType!)),
                                              onDeleted: () {
                                                setState(() {
                                                  _filterType = null;
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: visibleItems.isEmpty
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 24, 16, 100),
                                      children: const [
                                        Center(
                                          child: Text(
                                              'No memory items match your filters.'),
                                        ),
                                      ],
                                    )
                                  : ListView.separated(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: visibleItems.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 90),
                                      itemBuilder: (context, index) {
                                        final item = visibleItems[index];
                                        return _buildMemoryRow(item);
                                      },
                                    ),
                            ),
                          ],
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
  final int? sourceMessageId;
  final int? conversationId;
  final List<int> sourceIds;
  final MemoryType memoryType;
  final List<String> tags;
  final bool isPinned;
  final bool isActive;

  const _KnowledgeDraft({
    required this.title,
    required this.content,
    this.sourceMessageId,
    this.conversationId,
    this.sourceIds = const [],
    required this.memoryType,
    required this.tags,
    required this.isPinned,
    required this.isActive,
  });
}

enum _NewMemoryMode {
  fromChat,
  manual,
  fromDocument,
}

class _SourceDraft {
  final KnowledgeSource source;

  const _SourceDraft({required this.source});
}

class _RecentMessageChoice {
  final int? messageId;
  final int? conversationId;
  final bool isUser;
  final String content;

  const _RecentMessageChoice({
    required this.messageId,
    required this.conversationId,
    required this.isUser,
    required this.content,
  });
}
