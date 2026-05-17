class ReportModel {
  final String id;
  final String reporterId;
  final String? reporterName;
  final String targetId;
  final String? targetName;
  final String? targetAuthorId;
  final String targetType;
  final String reason;
  final String? details;
  final String status;
  final DateTime? createdAt;
  final String? reportedContent;
  final String? mediaType;
  final String? mediaUrl;
  final String? replyToContent;
  final String? replyToAuthor;

  ReportModel({
    required this.id,
    required this.reporterId,
    this.reporterName,
    required this.targetId,
    this.targetName,
    this.targetAuthorId,
    required this.targetType,
    required this.reason,
    this.details,
    required this.status,
    this.createdAt,
    this.reportedContent,
    this.mediaType,
    this.mediaUrl,
    this.replyToContent,
    this.replyToAuthor,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      reporterId: json['reporter_id'],
      reporterName: json['reporter_name'],
      targetId: json['target_id'],
      targetName: json['target_name'],
      targetAuthorId: json['target_author_id'],
      targetType: json['target_type'],
      reason: json['reason'],
      details: json['details'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      reportedContent: json['reported_content'],
      mediaType: json['media_type'],
      mediaUrl: json['media_url'],
      replyToContent: json['reply_to_content'],
      replyToAuthor: json['reply_to_author'],
    );
  }

  String get localizedReason {
    const reasons = {
      'spam': 'Спам',
      'harassment': 'Оскорбление',
      'inappropriate': 'Неприемлемый контент',
      'violence': 'Насилие',
      'hate_speech': 'Враждебные высказывания',
      'other': 'Другое',
    };
    return reasons[reason] ?? reason;
  }

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? targetId,
    String? targetName,
    String? targetAuthorId,
    String? targetType,
    String? reason,
    String? details,
    String? status,
    DateTime? createdAt,
    String? reportedContent,
    String? mediaType,
    String? mediaUrl,
    String? replyToContent,
    String? replyToAuthor,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      targetAuthorId: targetAuthorId ?? this.targetAuthorId,
      targetType: targetType ?? this.targetType,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reportedContent: reportedContent ?? this.reportedContent,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToAuthor: replyToAuthor ?? this.replyToAuthor,
    );
  }
}
