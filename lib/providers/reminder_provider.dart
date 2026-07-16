import 'package:flutter/foundation.dart';

import '../core/agent/agent_action_contracts.dart';
import '../models/generated_automation.dart';
import '../models/reminder.dart';
import '../services/automation_service.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider({
    ReminderService? service,
    AutomationService? automationService,
  })  : _service = service ?? ReminderService(),
        _automationService = automationService ?? AutomationService();

  final ReminderService _service;
  final AutomationService _automationService;
  bool _isAvailable = false;
  bool _remindersAvailable = false;
  bool _automationsAvailable = false;
  bool _isLoading = false;
  bool _rowsLoaded = false;
  String? _loadedUserId;
  String? _errorMessage;
  List<Reminder> _reminders = const [];
  List<GeneratedAutomation> _automations = const [];
  List<ActionProposal> _pendingProposals = const [];

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<GeneratedAutomation> get automations => List.unmodifiable(_automations);
  List<ActionProposal> get pendingProposals =>
      List.unmodifiable(_pendingProposals);

  Future<void> ensureInitialized({bool force = false}) async {
    final userId = _service.currentUser?.id;
    if (!force && userId != null && _loadedUserId == userId && _rowsLoaded) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await ensureCapability(force: force);
      if (_isAvailable) {
        await _loadRows();
      } else {
        _reminders = const [];
        _automations = const [];
        _pendingProposals = const [];
        _rowsLoaded = false;
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> ensureCapability({bool force = false}) async {
    final userId = _service.currentUser?.id;
    if (!force && userId != null && _loadedUserId == userId) {
      return _isAvailable;
    }
    if (_loadedUserId != userId) {
      _reminders = const [];
      _automations = const [];
      _pendingProposals = const [];
      _rowsLoaded = false;
    }
    _errorMessage = null;
    final capabilities = await Future.wait([
      _service.checkAvailability(force: force),
      _automationService.checkAvailability(force: force),
    ]);
    _remindersAvailable = capabilities[0];
    _automationsAvailable = capabilities[1];
    _isAvailable = _remindersAvailable || _automationsAvailable;
    _loadedUserId = userId;
    notifyListeners();
    return _isAvailable;
  }

  Future<void> refresh() async {
    if (!_isAvailable) {
      await ensureInitialized(force: true);
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _loadRows();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ActionProposal> propose({
    required String actionType,
    required Map<String, dynamic> arguments,
    AgentActionOrigin origin = AgentActionOrigin.text,
    String? conversationId,
  }) async {
    final proposal = await _service.propose(
      actionType: actionType,
      arguments: arguments,
      origin: origin,
      conversationId: conversationId,
    );
    _pendingProposals = [proposal, ..._pendingProposals];
    notifyListeners();
    return proposal;
  }

  Future<ActionProposal> proposeToolCall(
    Map<String, dynamic> toolCall, {
    required AgentActionOrigin origin,
    String? conversationId,
    ActionProposal? replacesProposal,
  }) async {
    final proposal = await _service.proposeToolCall(
      toolCall,
      origin: origin,
      conversationId: conversationId,
      replacesProposal: replacesProposal,
    );
    _pendingProposals = [
      proposal,
      ..._pendingProposals.where(
        (candidate) =>
            candidate.proposalId != proposal.proposalId &&
            candidate.proposalId != replacesProposal?.proposalId,
      ),
    ];
    notifyListeners();
    return proposal;
  }

  Future<ActionProposal> proposeAutomation({
    required String actionType,
    required Map<String, dynamic> arguments,
    AgentActionOrigin origin = AgentActionOrigin.text,
    String? conversationId,
  }) async {
    final proposal = await _automationService.propose(
      actionType: actionType,
      arguments: arguments,
      origin: origin,
      conversationId: conversationId,
    );
    _pendingProposals = [
      proposal,
      ..._pendingProposals.where(
        (candidate) => candidate.proposalId != proposal.proposalId,
      ),
    ];
    notifyListeners();
    return proposal;
  }

  Future<ActionResult?> decide(
    ActionProposal proposal,
    AgentActionDecision decision, {
    AgentActionOrigin channel = AgentActionOrigin.text,
  }) async {
    final result = await _service.decide(
      proposal: proposal,
      decision: decision,
      channel: channel,
    );
    _pendingProposals = _pendingProposals
        .where((candidate) => candidate.proposalId != proposal.proposalId)
        .toList(growable: false);
    await _loadRows();
    notifyListeners();
    return result;
  }

  Future<void> _loadRows() async {
    _reminders = _remindersAvailable
        ? await _service.fetchReminders()
        : const <Reminder>[];
    _automations = _automationsAvailable
        ? await _automationService.fetchAutomations()
        : const <GeneratedAutomation>[];
    _pendingProposals = await _service.fetchPendingProposals();
    _rowsLoaded = true;
  }
}
