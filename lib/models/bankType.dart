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

  String get name {
    switch (this) {
      case BankType.KAKAObank:
        return '카카오뱅크';
      case BankType.NH:
        return '농협';
      case BankType.KB:
        return '국민은행';
      case BankType.SHINHAN:
        return '신한은행';
      case BankType.WOORI:
        return '우리은행';
      case BankType.SAEMAEUL:
        return '새마을금고';
      case BankType.BUSAN:
        return '부산은행';
      case BankType.IBK:
        return '기업은행';
      case BankType.TOS:
        return '토스';
      case BankType.etc:
        return '기타';
      default:
        return '알 수 없음';
    }
  }


}