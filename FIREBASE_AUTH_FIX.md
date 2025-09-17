# إصلاح مشكلة Firebase Authentication على الويب

## المشكلة:
```
PlatformException(channel-error, Unable to establish connection on channel: "dev.flutter.pigeon.firebase_auth_platform_interface.FirebaseAuthHostApi.registerIdTokenListener"., null, null)
```

## الحلول المطبقة:

### ✅ 1. إضافة Firebase Auth SDK إلى index.html:
تم تحديث `web/index.html` لتتضمن:
```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
```

### ✅ 2. إضافة Firebase Configuration إلى index.html:
```html
<script>
  const firebaseConfig = {
    apiKey: "AIzaSyBcGDUOid1HbMbKvW4Q8mOblFeEhbl_SxA",
    authDomain: "qanuni-499f2.firebaseapp.com",
    projectId: "qanuni-499f2",
    storageBucket: "qanuni-499f2.firebasestorage.app",
    messagingSenderId: "634000662238",
    appId: "1:634000662238:web:0ffffced75a95045ae2c4f"
  };
  
  firebase.initializeApp(firebaseConfig);
</script>
```

### ✅ 3. تحديث AuthWrapper لمعالجة الأخطاء:
تم إضافة معالج خطأ في `AuthWrapper` للتعامل مع مشاكل الاتصال.

### ✅ 4. استخدام Navigation مباشر:
تم تغيير التطبيق لاستخدام Navigation مباشر بدلاً من AuthWrapper المعقد.

## خطوات إضافية للتأكد من العمل:

### 1. تفعيل Authentication في Firebase Console:
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروع `qanuni-499f2`
3. من القائمة الجانبية، اختر **Authentication**
4. اضغط على **Get started**
5. اذهب إلى تبويب **Sign-in method**
6. فعّل **Email/Password**

### 2. التحقق من الدومين المصرح:
1. في Authentication → Settings → Authorized domains
2. تأكد من وجود:
   - `localhost`
   - `127.0.0.1:*`
   - دومين موقعك إذا كان منشور

### 3. إعداد قواعد الأمان:

#### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /legal_contracts/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /legal_contracts/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## الاستخدام الحالي:

### 🔐 تسجيل الدخول:
1. شغّل التطبيق
2. ستظهر شاشة تسجيل الدخول مباشرة
3. اضغط **"إنشاء حساب"** لإنشاء المدير الأول
4. أو استخدم حساب موجود

### 👤 إدارة الحساب:
- في الشاشة الرئيسية، اضغط على أيقونة المدير
- اختر من القائمة حسب الحاجة

### 🚪 تسجيل الخروج:
- من قائمة المدير، اختر "تسجيل الخروج"
- سيتم إرجاعك إلى شاشة تسجيل الدخول

## استكشاف الأخطاء:

### إذا استمرت مشاكل الاتصال:
1. **امسح cache المتصفح** (`Ctrl+Shift+R`)
2. **تحقق من Console** في Developer Tools
3. **تأكد من تفعيل Authentication** في Firebase Console
4. **تحقق من Authorized domains**

### أخطاء شائعة وحلولها:
- **"auth/invalid-email"**: تحقق من صيغة الإيميل
- **"auth/weak-password"**: استخدم كلمة مرور أقوى (6+ أحرف)
- **"auth/email-already-in-use"**: الإيميل مستخدم مسبقاً
- **"auth/user-not-found"**: تحقق من الإيميل أو أنشئ حساب جديد

## التحديثات المطبقة:
- ✅ Firebase Auth SDK مضاف إلى index.html
- ✅ Firebase Configuration محدث
- ✅ Navigation مبسط بدون AuthWrapper معقد
- ✅ معالجة أخطاء محسنة
- ✅ واجهة تسجيل دخول/خروج فعالة

الآن النظام يجب أن يعمل بشكل صحيح لتسجيل الدخول وإدارة المصادقة! 🚀
