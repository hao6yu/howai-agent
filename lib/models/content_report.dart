enum ReportReason { inappropriate, harmful, misinformation, spam, other }

class ContentReport {
  final int? id;
  final int messageId;
  final ReportReason reason;
  final String? description;
  final String createdAt;
  final bool isResolved;
  final String? resolutionAction;

  ContentReport({
    this.id,
    required this.messageId,
    required this.reason,
    this.description,
    required this.createdAt,
    this.isResolved = false,
    this.resolutionAction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message_id': messageId,
      'report_reason': reason.name,
      'report_description': description,
      'created_at': createdAt,
      'is_resolved': isResolved ? 1 : 0,
      'resolution_action': resolutionAction,
    };
  }

  factory ContentReport.fromMap(Map<String, dynamic> map) {
    return ContentReport(
      id: map['id'],
      messageId: map['message_id'],
      reason: ReportReason.values.firstWhere(
        (r) => r.name == map['report_reason'],
        orElse: () => ReportReason.other,
      ),
      description: map['report_description'],
      createdAt: map['created_at'],
      isResolved: map['is_resolved'] == 1,
      resolutionAction: map['resolution_action'],
    );
  }

  String getReasonDisplayName() {
    switch (reason) {
      case ReportReason.inappropriate:
        return 'Inappropriate content';
      case ReportReason.harmful:
        return 'Harmful or offensive';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.spam:
        return 'Spam or repetitive';
      case ReportReason.other:
        return 'Other issue';
    }
  }
}
