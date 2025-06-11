// Assigned Report Entity
class AssignedReport {
  final String id;
  final String category;
  final String location;
  final String issueDate;
  final String status;
  final String assignedTo;
  final String imageUrl;

  AssignedReport({
    required this.id,
    required this.category,
    required this.location,
    required this.issueDate,
    required this.status,
    required this.assignedTo,
    required this.imageUrl,
  });

  factory AssignedReport.fromJson(Map<String, dynamic> json) => AssignedReport(
    id: json['id'],
    category: json['category'],
    location: json['location'],
    issueDate: json['issueDate'],
    status: json['status'],
    assignedTo: json['assignedTo'],
    imageUrl: json['imageUrl'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'location': location,
    'issueDate': issueDate,
    'status': status,
    'assignedTo': assignedTo,
    'imageUrl': imageUrl,
  };

  AssignedReport copyWith({
    String? id,
    String? category,
    String? location,
    String? issueDate,
    String? status,
    String? assignedTo,
    String? imageUrl,
  }) {
    return AssignedReport(
      id: id ?? this.id,
      category: category ?? this.category,
      location: location ?? this.location,
      issueDate: issueDate ?? this.issueDate,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}