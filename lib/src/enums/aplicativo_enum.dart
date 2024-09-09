enum AplicativoEnum {
  link (description: 'Link', value: 1),
  navi (description: 'Navi', value: 2);

  const AplicativoEnum({required this.description, required this.value});

  final String description;
  final int value;

  static AplicativoEnum getByValue(int value) => AplicativoEnum.values.firstWhere((e) => e.value == value);
}