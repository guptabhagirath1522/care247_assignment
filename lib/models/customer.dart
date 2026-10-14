import 'address.dart';
import 'email.dart';
import 'phone.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String maritalStatus;
  final String secureId;
  final List<Address> addresses;
  final List<Phone> phones;
  final List<Email> emails;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.secureId,
    required this.addresses,
    required this.phones,
    required this.emails,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      maritalStatus: json['maritalStatus'] as String,
      secureId: json['secureId'] as String,
      addresses: (json['addresses'] as List<dynamic>)
          .map((a) => Address.fromJson(a as Map<String, dynamic>))
          .toList(),
      phones: (json['phones'] as List<dynamic>)
          .map((p) => Phone.fromJson(p as Map<String, dynamic>))
          .toList(),
      emails: (json['emails'] as List<dynamic>)
          .map((e) => Email.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'secureId': secureId,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'phones': phones.map((p) => p.toJson()).toList(),
      'emails': emails.map((e) => e.toJson()).toList(),
    };
  }

  String get fullName => '$firstName $lastName';

  Phone? get primaryPhone {
    try {
      return phones.firstWhere((p) => p.isPrimary);
    } catch (_) {
      return phones.isNotEmpty ? phones.first : null;
    }
  }

  Email? get primaryEmail {
    try {
      return emails.firstWhere((e) => e.isPrimary);
    } catch (_) {
      return emails.isNotEmpty ? emails.first : null;
    }
  }

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? maritalStatus,
    String? secureId,
    List<Address>? addresses,
    List<Phone>? phones,
    List<Email>? emails,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      secureId: secureId ?? this.secureId,
      addresses: addresses ?? this.addresses,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Customer(id: $id, name: $fullName)';
}
