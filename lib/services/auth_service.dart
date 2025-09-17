import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'admin_service.dart';

/// خدمة المصادقة للمديرين
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdminService _adminService = AdminService();

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// التحقق من حالة تسجيل الدخول
  bool get isLoggedIn => currentUser != null;

  /// تدفق حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// التحقق من صحة الإيميل
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// التحقق من قوة كلمة المرور
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// تسجيل الدخول بالإيميل وكلمة المرور
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign in with email: $email');
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // تحديث آخر تسجيل دخول في سجل المديرين
      if (result.user != null) {
        await _adminService.updateLastLogin(result.user!.uid);
      }
      
      debugPrint('Sign in successful for user: ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      debugPrint('General Auth Error: $e');
      throw Exception('حدث خطأ غير متوقع أثناء تسجيل الدخول');
    }
  }

  /// إنشاء حساب مدير جديد
  Future<UserCredential?> createAdminAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      debugPrint('Creating admin account for email: $email');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // تحديث اسم العرض
      await result.user?.updateDisplayName(displayName ?? 'مدير النظام');
      
      // إضافة المدير إلى مجموعة المديرين
      if (result.user != null) {
        await _adminService.createAdminRecord(
          uid: result.user!.uid,
          email: result.user!.email!,
          displayName: displayName ?? 'مدير النظام',
        );
      }
      
      debugPrint('Admin account created successfully for: ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      debugPrint('General Auth Error: $e');
      throw Exception('حدث خطأ غير متوقع أثناء إنشاء الحساب');
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      debugPrint('Signing out user: ${currentUser?.email}');
      await _auth.signOut();
      debugPrint('Sign out successful');
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('حدث خطأ أثناء تسجيل الخروج');
    }
  }

 
  /// معالجة أخطاء Firebase Auth وتحويلها لرسائل عربية
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم مسجل بهذا الإيميل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'الإيميل غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح. حاول لاحقاً';
      case 'email-already-in-use':
        return 'هذا الإيميل مستخدم مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة. يجب أن تكون على الأقل 6 أحرف';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة';
      case 'network-request-failed':
        return 'خطأ في الاتصال بالإنترنت';
      case 'operation-not-allowed':
        return 'عملية تسجيل الدخول غير مفعلة';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
