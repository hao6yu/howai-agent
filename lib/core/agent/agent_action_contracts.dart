enum AgentActionRisk { low, medium, high }

enum AgentActionOrigin { text, voice, notification, system }

enum AgentActionDecision { approved, rejected }

enum AgentActionStatus { succeeded, failed }

class AgentToolDefinition {
  AgentToolDefinition({
    required this.name,
    required this.description,
    required Map<String, dynamic> inputSchema,
    required this.risk,
    this.available = false,
  }) : inputSchema = Map.unmodifiable(inputSchema) {
    if (inputSchema['type'] != 'object' ||
        inputSchema['additionalProperties'] != false) {
      throw ArgumentError(
        'Agent tool schemas must be strict objects with additionalProperties=false',
      );
    }
  }

  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;
  final AgentActionRisk risk;
  final bool available;
}

class ActionProposal {
  ActionProposal({
    required this.proposalId,
    required this.actionType,
    required Map<String, dynamic> arguments,
    required this.summary,
    required List<String> warnings,
    required this.origin,
    required this.createdAt,
  })  : arguments = Map.unmodifiable(arguments),
        warnings = List.unmodifiable(warnings);

  factory ActionProposal.fromJson(Map<String, dynamic> json) {
    _rejectUnknownKeys(json, const {
      'proposal_id',
      'action_type',
      'arguments',
      'summary',
      'warnings',
      'origin',
      'created_at',
    });
    return ActionProposal(
      proposalId: _requiredString(json, 'proposal_id'),
      actionType: _requiredString(json, 'action_type'),
      arguments: _requiredMap(json, 'arguments'),
      summary: _requiredString(json, 'summary'),
      warnings: _stringList(json['warnings']),
      origin: AgentActionOrigin.values.byName(
        _requiredString(json, 'origin'),
      ),
      createdAt: DateTime.parse(_requiredString(json, 'created_at')).toUtc(),
    );
  }

  final String proposalId;
  final String actionType;
  final Map<String, dynamic> arguments;
  final String summary;
  final List<String> warnings;
  final AgentActionOrigin origin;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'proposal_id': proposalId,
        'action_type': actionType,
        'arguments': arguments,
        'summary': summary,
        'warnings': warnings,
        'origin': origin.name,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

class ActionApproval {
  const ActionApproval({
    required this.proposalId,
    required this.decision,
    required this.channel,
    required this.decidedAt,
  });

  final String proposalId;
  final AgentActionDecision decision;
  final AgentActionOrigin channel;
  final DateTime decidedAt;

  Map<String, dynamic> toJson() => {
        'proposal_id': proposalId,
        'decision': decision.name,
        'channel': channel.name,
        'decided_at': decidedAt.toUtc().toIso8601String(),
      };
}

class ActionResult {
  const ActionResult({
    required this.status,
    required this.displayMessage,
    required this.retryable,
    required this.auditId,
    this.resourceType,
    this.resourceId,
  });

  final AgentActionStatus status;
  final String displayMessage;
  final bool retryable;
  final String auditId;
  final String? resourceType;
  final String? resourceId;

  bool get isSuccess => status == AgentActionStatus.succeeded;

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'display_message': displayMessage,
        'retryable': retryable,
        'audit_id': auditId,
        if (resourceType != null) 'resource_type': resourceType,
        if (resourceId != null) 'resource_id': resourceId,
      };
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string');
  }
  return value;
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw FormatException('$key must be an object');
  }
  return Map<String, dynamic>.from(value);
}

List<String> _stringList(dynamic value) {
  if (value == null) return const [];
  if (value is! List || value.any((item) => item is! String)) {
    throw const FormatException('warnings must be a string array');
  }
  return List<String>.from(value);
}

void _rejectUnknownKeys(Map<String, dynamic> json, Set<String> allowed) {
  final unknown = json.keys.where((key) => !allowed.contains(key)).toList();
  if (unknown.isNotEmpty) {
    throw FormatException('Unknown fields: ${unknown.join(', ')}');
  }
}
