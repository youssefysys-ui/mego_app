class PlaceModel {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String placeId;

  PlaceModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    // Handle autocomplete response format
    String name = '';
    String address = '';
    double lat = 0.0;
    double lng = 0.0;
    String placeId = json['place_id'] ?? '';

    // For autocomplete responses
    if (json.containsKey('structured_formatting')) {
      name = json['structured_formatting']['main_text'] ?? '';
      address = json['description'] ?? '';
    }
    // For place details responses
    else if (json.containsKey('name')) {
      name = json['name'] ?? '';
      address = json['formatted_address'] ?? '';
    }
    // Fallback
    else {
      name = json['description'] ?? json['name'] ?? '';
      address = json['formatted_address'] ?? json['description'] ?? '';
    }

    // Handle geometry/location
    if (json.containsKey('geometry') && json['geometry'] != null) {
      final geometry = json['geometry'];
      if (geometry.containsKey('location') && geometry['location'] != null) {
        final location = geometry['location'];
        lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
        lng = (location['lng'] as num?)?.toDouble() ?? 0.0;
      }
    }

    return PlaceModel(
      name: name,
      address: address,
      latitude: lat,
      longitude: lng,
      placeId: placeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
    };
  }

  @override
  String toString() {
    return 'PlaceModel(name: $name, address: $address, lat: $latitude, lng: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceModel && other.placeId == placeId;
  }

  @override
  int get hashCode {
    return placeId.hashCode;
  }

  /// Creates a copy of this PlaceModel with the given fields replaced with new values
  PlaceModel copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
  }) {
    return PlaceModel(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
    );
  }

  /// Check if this is the current location placeholder
  bool get isCurrentLocation => placeId == 'current_location';

  /// Check if this place has valid coordinates
  bool get hasValidCoordinates => latitude != 0.0 || longitude != 0.0;
  
  /// Alias for hasValidCoordinates to match controller usage
  bool get hasCoordinates => hasValidCoordinates;

  /// Check if the place model is valid
  bool get isValid {
    return name.isNotEmpty && 
           address.isNotEmpty && 
           placeId.isNotEmpty &&
           hasCoordinates;
  }

  /// Get formatted coordinates string
  String get coordinatesString => '$latitude, $longitude';
}