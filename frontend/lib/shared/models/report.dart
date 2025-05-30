
class Issue {
  final String? id;
  final String category;
  final Location locations;
  final String description;
  final DateTime issueDate;
  final String status;
  final String imageURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  Issue({
    this.id,
    required this.category,
    required this.locations,
    required this.description,
    required this.issueDate,
    this.status = "Unresolved",
    required this.imageURL,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory Issue.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing issue: $json'); // Debug log
      
      // Handle locations - ensure it's properly parsed
      Location locationData;
      if (json['locations'] != null) {
        try {
          locationData = Location.fromJson(json['locations']);
        } catch (e) {
          print('Error parsing location: $e');
          // Fallback to default location if parsing fails
          locationData = Location(city: 'Unknown', specificArea: 'Unknown');
        }
      } else {
        // Fallback if locations is null
        locationData = Location(city: 'Unknown', specificArea: 'Unknown');
      }
      
      return Issue(
        id: json['_id']?.toString(),
        category: json['category'] ?? 'Unknown',
        locations: locationData,
        description: json['description'] ?? 'No description',
        issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate']) : DateTime.now(),
        status: json['status'] ?? 'Unresolved',
        imageURL: json['imageURL'] ?? '',
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Issue from JSON: $e');
      print('JSON data: $json');
      // Return a default issue instead of throwing
      return Issue(
        category: 'Error',
        locations: Location(city: 'Unknown', specificArea: 'Unknown'),
        description: 'Error parsing issue data',
        issueDate: DateTime.now(),
        imageURL: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'locations': locations.toJson(),
      'description': description,
      'issueDate': issueDate.toIso8601String(),
      'status': status,
      'imageURL': imageURL,
    };
  }
}

class Location {
  final String city;
  final String specificArea;

  Location({
    required this.city,
    required this.specificArea,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing location: $json'); // Debug log
      
      // Handle potential missing values
      return Location(
        city: json['city'] ?? 'Unknown',
        specificArea: json['specificArea'] ?? 'Unknown',
      );
    } catch (e) {
      print('Error parsing Location from JSON: $e');
      print('JSON data: $json');
      // Return a default location instead of crashing
      return Location(city: 'Unknown', specificArea: 'Unknown');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'specificArea': specificArea,
    };
  }
}

// List of valid cities and their areas based on backend model
class CityAreas {
  static const Map<String, List<String>> citySpecificAreas = {
    "Mumbai": ["Andheri", "Bandra", "Colaba", "Dadar", "Juhu"],
    "Delhi": ["Connaught Place", "Dwarka", "Hauz Khas", "Rohini", "Saket"],
    "Bangalore": ["Indiranagar", "Koramangala", "MG Road", "Whitefield", "Electronic City"],
    "Chennai": ["Adyar", "Anna Nagar", "T Nagar", "Velachery", "Mylapore"],
    "Kolkata": ["Park Street", "Salt Lake", "New Town", "Howrah", "Dum Dum"]
  };

  static List<String> getCities() {
    return citySpecificAreas.keys.toList();
  }

  static List<String> getAreasByCity(String city) {
    return citySpecificAreas[city] ?? [];
  }
}