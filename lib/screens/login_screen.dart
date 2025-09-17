// شاشة تسجيل الدخول مع شرح لكل جزئية في الكود
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

// ويدجت الشاشة الرئيسية لتسجيل الدخول أو إنشاء حساب
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// الحالة الخاصة بشاشة تسجيل الدخول
class _LoginScreenState extends State<LoginScreen> {
  // مفاتيح وأدوات التحكم بالنموذج وحقول الإدخال
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final AuthService _authService = AuthService();
  
  // متغيرات الحالة: تحميل، إظهار كلمة المرور، عرض نموذج إنشاء حساب
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showCreateAccount = false;

  @override
  void dispose() {
    // تحرير الموارد عند التخلص من الشاشة
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  // دالة تسجيل الدخول
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        // النجاح - الانتقال إلى الشاشة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مرحباً بك في نظام إدارة العقود'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // دالة إنشاء حساب مدير جديد
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.createAdminAccount(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _showCreateAccount = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // بناء واجهة المستخدم
  return Scaffold(
  // خلفية الشاشة بتدرج لوني هادئ
  body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFe3f0fd),
              Color(0xFFf5f5f5),
            ],
          ),
        ),
  child: Center(
          // تمرير عمودي في حال صغر الشاشة
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            // البطاقة الرئيسية التي تحتوي على النموذج
            child: Card(
              elevation: 16,
              shadowColor: AppColors.primary.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 370),
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
                // نموذج الإدخال (Form) مع التحقق من صحة البيانات
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الشعار والعنوان الرئيسي
                      // دائرة الشعار
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary.withOpacity(0.13),
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 54,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // عنوان الشاشة (تسجيل دخول أو إنشاء حساب)
                      Text(
                        _showCreateAccount ? 'إنشاء حساب مدير' : 'تسجيل دخول المدير',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // نص فرعي يوضح وظيفة النظام
                      Text(
                        'نظام إدارة العقود القانونية',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 22),

                      // حقل إدخال الإيميل
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'الإيميل',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الإيميل';
                          }
                          if (!_authService.isValidEmail(value)) {
                            return 'الرجاء إدخال إيميل صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // حقل اسم المدير (يظهر فقط عند إنشاء حساب)
                      if (_showCreateAccount)
                        ...[
                          TextFormField(
                            controller: _displayNameController,
                            textDirection: TextDirection.rtl,
                            decoration: const InputDecoration(
                              labelText: 'اسم المدير',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال اسم المدير';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                      // حقل كلمة المرور مع زر إظهار/إخفاء
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          if (_showCreateAccount && !_authService.isValidPassword(value)) {
                            return 'كلمة المرور يجب أن تكون على الأقل 6 أحرف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // حقل تأكيد كلمة المرور (يظهر فقط عند إنشاء حساب)
                      if (_showCreateAccount)
                        ...[
                          TextFormField(
                            obscureText: _obscurePassword,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء تأكيد كلمة المرور';
                              }
                              if (value != _passwordController.text) {
                                return 'كلمة المرور غير متطابقة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                      const SizedBox(height: 18),

                      // زر تسجيل الدخول أو إنشاء الحساب
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_showCreateAccount ? _createAccount : _signIn),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _showCreateAccount ? 'إنشاء الحساب' : 'تسجيل الدخول',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ...إمكان إضافة عناصر أخرى هنا...

                      // زر التبديل بين تسجيل الدخول وإنشاء حساب
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showCreateAccount ? 'لديك حساب؟ ' : 'لا تملك حساب؟ ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showCreateAccount = !_showCreateAccount;
                              });
                            },
                            child: Text(
                              _showCreateAccount ? 'تسجيل الدخول' : 'إنشاء حساب',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
