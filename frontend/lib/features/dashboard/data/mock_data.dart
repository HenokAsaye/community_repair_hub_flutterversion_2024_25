import '../../../shared/models/report.dart';

// Mock data for testing
class MockDataProvider {
  static List<Issue> getMockIssues() {
    return [
      Issue(
        id: '1',
        category: 'Pothole',
        locations: Location(city: 'Mumbai', specificArea: 'Andheri'),
        description: 'Large pothole causing traffic issues',
        issueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'pending',
        imageURL: 'https://via.placeholder.com/300',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Issue(
        id: '2',
        category: 'Street Light',
        locations: Location(city: 'Delhi', specificArea: 'Connaught Place'),
        description: 'Street light not working for the past week',
        issueDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'in progress',
        imageURL: 'https://via.placeholder.com/300',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Issue(
        id: '3',
        category: 'Garbage Collection',
        locations: Location(city: 'Bangalore', specificArea: 'Indiranagar'),
        description: 'Garbage not collected for the past 3 days',
        issueDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'resolved',
        imageURL: 'https://via.placeholder.com/300',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
