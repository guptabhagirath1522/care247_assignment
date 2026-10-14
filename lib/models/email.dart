class Email {
  final String id;
  final String type;
  final String address;
  final bool isPrimary;

  const Email({
    required this.id,
    required this.type,
    required this.address,
    required this.isPrimary,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'] as String,
      type: json['type'] as String,
      address: json['address'] as String,
      isPrimary: json['isPrimary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'address': address, 'isPrimary': isPrimary};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Email &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          address == other.address &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      id.hashCode ^ type.hashCode ^ address.hashCode ^ isPrimary.hashCode;

  @override
  String toString() =>
      'Email(id: $id, type: $type, address: $address, isPrimary: $isPrimary)';
}
