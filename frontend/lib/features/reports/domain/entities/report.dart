// Report Entity
class Report {
  final String id;
  final String category;
  final String location;
  final String description;
  final String imageUrl;
  final String status;
  final String date;
  Report({
    required this.id,
    required this.category,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.date,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'],
    category: json['category'],
    location: json['location'],
    description: json['description'],
    imageUrl: json['imageUrl'] ?? '',
    status: json['status'],
    date: json['date'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'location': location,
    'description': description,
    'imageUrl': imageUrl,
    'status': status,
    'date': date,
  };
}