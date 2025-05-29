import 'package:flutter/material.dart';

class Issue {
  final String imageAsset;
  final String category;
  final String location;
  final String issueDate;
  final String status;

  Issue({
    required this.imageAsset,
    required this.category,
    required this.location,
    required this.issueDate,
    required this.status,
  });
}

class AssignedIssuesScreen extends StatelessWidget {
  const AssignedIssuesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandGreen = const Color(0xFF7CFC00);
    final issues = [
      Issue(
        imageAsset: 'assets/images/img_3.png',
        category: 'Road',
        location: 'Garment,AA',
        issueDate: '3/17/2025',
        status: 'In Progress',
      ),
      Issue(
        imageAsset: 'assets/images/img_3.png',
        category: 'Road',
        location: 'Garment,AA',
        issueDate: '3/17/2025',
        status: 'In Progress',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: brandGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushReplacementNamed('repair_team_detail'),
        ),
        title: const Text(
          'Assigned Issues',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        itemCount: issues.length,
        itemBuilder: (context, index) {
          final issue = issues[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brandGreen, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: Image.asset(
                        issue.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFA500),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'In Progress',
                                style: TextStyle(
                                  color: Color(0xFF568B9F),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: ${issue.category}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'location: ${issue.location}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Issue Date: ${issue.issueDate}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed('update_status');
                              },
                              child: const Text(
                                'View & Update',
                                style: TextStyle(
                                  color: Color(0xFF568B9F),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 