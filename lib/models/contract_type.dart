/// تعداد أنواع العقود القانونية المختلفة
enum ContractType {
  /// عقد بيع
  sale('عقد بيع', 'sale'),
  
  /// عقد إيجار
  rental('عقد إيجار', 'rental'),
  
  /// عقد عمل
  employment('عقد عمل', 'employment'),
  
  /// عقد شراكة
  partnership('عقد شراكة', 'partnership'),
  
  /// عقد خدمات
  services('عقد خدمات', 'services'),
  
  /// عقد توريد
  supply('عقد توريد', 'supply'),
  
  /// عقد مقاولة
  contracting('عقد مقاولة', 'contracting'),
  
  /// عقد استشارة
  consulting('عقد استشارة', 'consulting'),
  
  /// عقد تأمين
  insurance('عقد تأمين', 'insurance'),
  
  /// عقد قرض
  loan('عقد قرض', 'loan'),
  
  /// عقد زواج
  marriage('عقد زواج', 'marriage'),
  
  /// اتفاقية سرية
  nda('اتفاقية سرية', 'nda'),
  
  /// وكالة قانونية
  powerOfAttorney('وكالة قانونية', 'power_of_attorney'),
  
  /// وصية
  will('وصية', 'will'),
  
  /// عقد أخر
  other('أخرى', 'other');

  const ContractType(this.arabicName, this.value);

  /// الاسم باللغة العربية
  final String arabicName;
  
  /// القيمة المخزنة في قاعدة البيانات
  final String value;

  /// الحصول على نوع العقد من القيمة المخزنة
  static ContractType fromValue(String value) {
    return ContractType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContractType.other,
    );
  }

  /// الحصول على نوع العقد من الاسم العربي
  static ContractType fromArabicName(String arabicName) {
    return ContractType.values.firstWhere(
      (type) => type.arabicName == arabicName,
      orElse: () => ContractType.other,
    );
  }

  /// الحصول على جميع الأنواع كقائمة من الأسماء العربية
  static List<String> get allArabicNames {
    return ContractType.values.map((type) => type.arabicName).toList();
  }

  /// الحصول على لون مميز لكل نوع عقد
  int get colorValue {
    switch (this) {
      case ContractType.sale:
        return 0xFF4CAF50; // أخضر
      case ContractType.rental:
        return 0xFF2196F3; // أزرق
      case ContractType.employment:
        return 0xFF9C27B0; // بنفسجي
      case ContractType.partnership:
        return 0xFFFF9800; // برتقالي
      case ContractType.services:
        return 0xFF00BCD4; // سماوي
      case ContractType.supply:
        return 0xFF795548; // بني
      case ContractType.contracting:
        return 0xFF607D8B; // رمادي أزرق
      case ContractType.consulting:
        return 0xFF3F51B5; // أزرق داكن
      case ContractType.insurance:
        return 0xFFE91E63; // وردي
      case ContractType.loan:
        return 0xFFF44336; // أحمر
      case ContractType.marriage:
        return 0xFFE91E63; // وردي
      case ContractType.nda:
        return 0xFF424242; // رمادي داكن
      case ContractType.powerOfAttorney:
        return 0xFF8BC34A; // أخضر فاتح
      case ContractType.will:
        return 0xFF673AB7; // بنفسجي داكن
      case ContractType.other:
        return 0xFF757575; // رمادي
    }
  }

  /// الحصول على أيقونة مناسبة لكل نوع عقد
  int get iconCodePoint {
    switch (this) {
      case ContractType.sale:
        return 0xe570; // shopping_cart
      case ContractType.rental:
        return 0xe88a; // home
      case ContractType.employment:
        return 0xe7fd; // work
      case ContractType.partnership:
        return 0xe7ef; // handshake
      case ContractType.services:
        return 0xe8d8; // build
      case ContractType.supply:
        return 0xe1c1; // local_shipping
      case ContractType.contracting:
        return 0xe8d8; // construction
      case ContractType.consulting:
        return 0xe8f4; // psychology
      case ContractType.insurance:
        return 0xe32a; // security
      case ContractType.loan:
        return 0xe227; // attach_money
      case ContractType.marriage:
        return 0xe87d; // favorite
      case ContractType.nda:
        return 0xe897; // gavel
      case ContractType.powerOfAttorney:
        return 0xe8e8; // assignment
      case ContractType.will:
        return 0xe873; // description
      case ContractType.other:
        return 0xe873; // description
    }
  }

  @override
  String toString() => arabicName;
}
