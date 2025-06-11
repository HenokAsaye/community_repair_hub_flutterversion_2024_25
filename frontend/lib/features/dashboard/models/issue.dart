class Issue {
  final String id;
  final String title;
  final String description;
  final String location;
  final String status;
  final String priority;
  final String citizenId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<StatusUpdate> statusUpdates;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.priority,
    required this.citizenId,
    required this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.statusUpdates = const [],
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      citizenId: json['citizenId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      statusUpdates: (json['statusUpdates'] as List<dynamic>?)
              ?.map((update) => StatusUpdate.fromJson(update))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'location': location,
      'status': status,
      'priority': priority,
      'citizenId': citizenId,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'statusUpdates': statusUpdates.map((update) => update.toJson()).toList(),
    };
  }
}

class StatusUpdate {
  final String status;
  final String description;
  final DateTime date;

  StatusUpdate({
    required this.status,
    required this.description,
    required this.date,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
