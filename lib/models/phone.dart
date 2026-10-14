class Phone {
  final String id;
  final String type;
  final String number;
  final bool isPrimary;

  const Phone({
    required this.id,
    required this.type,
    required this.number,
    required this.isPrimary,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      id: json['id'] as String,
      type: json['type'] as String,
      number: json['number'] as String,
      isPrimary: json['isPrimary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'number': number, 'isPrimary': isPrimary};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phone &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          number == other.number &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      id.hashCode ^ type.hashCode ^ number.hashCode ^ isPrimary.hashCode;

  @override
  String toString() =>
      'Phone(id: $id, type: $type, number: $number, isPrimary: $isPrimary)';
}
