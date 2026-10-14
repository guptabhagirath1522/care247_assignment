class Address {
  final String id;
  final String type;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  const Address({
    required this.id,
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      type: json['type'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
    };
  }

  String get formatted => '$street, $city, $state $zipCode';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          street == other.street &&
          city == other.city &&
          state == other.state &&
          zipCode == other.zipCode;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      street.hashCode ^
      city.hashCode ^
      state.hashCode ^
      zipCode.hashCode;

  @override
  String toString() => 'Address(id: $id, type: $type, formatted: $formatted)';
}
