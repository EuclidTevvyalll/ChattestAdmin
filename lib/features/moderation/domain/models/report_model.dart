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
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      reportedContent: json['reported_content'],
      mediaType: json['media_type'],
      mediaUrl: json['media_url'],
      replyToContent: json['reply_to_content'],
      replyToAuthor: json['reply_to_author'],
    );
  }

  String get localizedReason {
    const reasons = {
      'spam': 'Спам / Реклама',
      'harassment': 'Оскорбление / Травля',
      'inappropriate': 'Непристойный контент',
      'violence': 'Насилие / Жестокость',
      'hate_speech': 'Враждебные высказывания',
      'other': 'Другое',
    };
    return reasons[reason] ?? reason;
  }
}
