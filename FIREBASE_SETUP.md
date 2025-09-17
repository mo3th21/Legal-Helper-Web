# إعداد Firebase لموقع رفع العقود القانونية

## خطوات الإعداد:

### 1. إنشاء مشروع Firebase:
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. أنشئ مشروع جديد
3. قم بتفعيل Firebase Storage و Firestore Database

### 2. إعداد Firebase للويب:
1. في Firebase Console، اذهب إلى Project Settings
2. اختر "Add app" واختر "Web"
3. سجل التطبيق واحصل على Firebase configuration

### 3. تحديث الإعدادات:
قم بتحديث الملفات التالية بإعدادات مشروعك:

#### في `lib/main.dart` (السطر 11-18):
```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "your-api-key-here",           // ضع API Key هنا
    authDomain: "your-project-id.firebaseapp.com",   // ضع Auth Domain هنا
    projectId: "your-project-id",         // ضع Project ID هنا
    storageBucket: "your-project-id.appspot.com",    // ضع Storage Bucket هنا
    messagingSenderId: "your-sender-id",  // ضع Messaging Sender ID هنا
    appId: "your-app-id"                  // ضع App ID هنا
  ),
);
```

### 4. إعداد Firebase Storage Rules:
في Firebase Console > Storage > Rules، استخدم هذه القوانين:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /legal_contracts/{allPaths=**} {
      allow read, write: if true; // يمكنك تخصيص هذا حسب احتياجاتك
    }
  }
}
```

### 5. إعداد Firestore Rules:
في Firebase Console > Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /legal_contracts/{document} {
      allow read, write: if true; // يمكنك تخصيص هذا حسب احتياجاتك
    }
  }
}
```

### 6. تشغيل التطبيق:
```bash
flutter pub get
flutter run -d web
```

## الميزات المتوفرة:
- رفع ملفات PDF إلى Firebase Storage
- عرض قائمة بالملفات المرفوعة
- حذف الملفات
- تحميل الملفات
- واجهة باللغة العربية
- تتبع حالة الرفع
- عرض تفاصيل الملف (الحجم، تاريخ الرفع)

## ملاحظات أمنية:
- تأكد من تحديث قوانين Firebase Security Rules حسب احتياجاتك
- لا تعرض Firebase configuration keys في الكود العام
- استخدم متغيرات البيئة للإعدادات الحساسة في الإنتاج
