enum BankType {
  KAKAObank,
  NH,
  KB,
  SHINHAN,
  WOORI,
  SAEMAEUL,
  BUSAN,
  IBK,
  TOS,
  etc
}

extension BankTypeExtension on BankType {
  static BankType fromString(String value) {
    return BankType.values.firstWhere((e) => e.toString().split('.').last == value,
        orElse: () => throw ArgumentError('No enum constant with value $value'));
  }

  String get name => toString().split('.').last;
}