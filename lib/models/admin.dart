import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المدير
class Admin {
  final String uid;
  final String email;
  final String displayName;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const Admin({
    required this.uid,
    required this.email,
    required this.displayName,
    this.createdAt,
    this.lastLoginAt,
  });

  /// إنشاء Admin من بيانات Firestore
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Admin.fromMap(data..['uid'] = doc.id);
  }

  /// إنشاء Admin من Map
  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'مدير النظام',
      createdAt: _timestampToDateTime(map['createdAt']),
      lastLoginAt: _timestampToDateTime(map['lastLoginAt']),
    );
  }

  /// تحويل Admin إلى Map للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  /// تحويل Admin إلى Map للحفظ في Firestore مع ServerTimestamp
  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// نسخ Admin مع تغيير بعض الحقول
  Admin copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return Admin(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// الحصول على عدد الأيام منذ آخر تسجيل دخول
  int? get daysSinceLastLogin {
    if (lastLoginAt == null) return null;
    return DateTime.now().difference(lastLoginAt!).inDays;
  }

  /// تحويل Timestamp إلى DateTime
  static DateTime? _timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }

  @override
  String toString() {
    return 'Admin(uid: $uid, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Admin &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode;
  }
}
