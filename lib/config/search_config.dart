enum FieldType { text, date, dropdown }

class FieldConfig {
  final String key;
  final FieldType type;
  final String label;
  final String? placeholder;
  final int renderOrder;

  final List<String>? options;

  const FieldConfig({
    required this.key,
    required this.type,
    required this.label,
    this.placeholder,
    required this.renderOrder,
    this.options,
  });
}

final List<FieldConfig> searchConfig = [
  const FieldConfig(
    key: 'firstName',
    type: FieldType.text,
    label: 'First Name',
    placeholder: 'Enter first name',
    renderOrder: 1,
  ),
  const FieldConfig(
    key: 'lastName',
    type: FieldType.text,
    label: 'Last Name',
    placeholder: 'Enter last name',
    renderOrder: 2,
  ),
  const FieldConfig(
    key: 'dateOfBirth',
    type: FieldType.date,
    label: 'Date of Birth',
    placeholder: 'YYYY-MM-DD',
    renderOrder: 3,
  ),
];
