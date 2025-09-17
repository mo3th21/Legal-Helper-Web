import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/admin.dart';

/// خدمة إدارة المديرين
class AdminService {
  static const String _collectionName = 'admins';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إضافة مدير جديد إلى مجموعة المديرين
  Future<void> createAdminRecord({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    try {
      final admin = Admin(
        uid: uid,
        email: email,
        displayName: displayName ?? 'مدير النظام',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .set(admin.toFirestoreMap());

      debugPrint('Admin record created for: $email');
    } catch (e) {
      debugPrint('Error creating admin record: $e');
      throw Exception('فشل في إنشاء سجل المدير: $e');
    }
  }

  /// التحقق من كون المستخدم مدير
  Future<bool> isUserAdmin(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(uid)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  /// تحديث آخر تسجيل دخول
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }
}
