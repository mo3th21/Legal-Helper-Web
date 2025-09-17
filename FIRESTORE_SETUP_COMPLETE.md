# إعداد Firestore الكامل - المؤشرات والقواعد

## ✅ تم إصلاح مشكلة Firebase Auth
تم حل مشكلة `channel-error` بنجاح! الآن يمكن إنشاء حسابات المديرين بنجاح.

## 🔍 المشكلة الحالية: مؤشرات Firestore
الخطأ الحالي:
```
[cloud_firestore/failed-precondition] The query requires an index.
```

## 🛠️ الحلول المطبقة:

### 1. ✅ إنشاء خدمة المديرين (AdminService)
- تم إنشاء `lib/services/admin_service.dart`
- إدارة مجموعة المديرين في Firestore
- تتبع صلاحيات وحالة المديرين
- تسجيل آخر تسجيل دخول

### 2. ✅ تحديث خدمة المصادقة (AuthService)
- دمج مع خدمة المديرين
- إنشاء سجل مدير تلقائياً عند إنشاء حساب جديد
- تحديث آخر تسجيل دخول

### 3. ✅ إصلاح مؤقت للفلترة
- إضافة آلية fallback في `getContractsByType`
- إذا فشل الاستعلام المفهرس، يتم جلب جميع العقود والفلترة محلياً

## 📋 خطوات الإعداد المطلوبة:

### الخطوة 1: إنشاء المؤشرات في Firestore Console

1. **اذهب إلى Firebase Console:**
   - افتح [https://console.firebase.google.com](https://console.firebase.google.com)
   - اختر مشروع `qanuni-499f2`

2. **انتقل إلى Firestore Database:**
   - من القائمة الجانبية: `Firestore Database`
   - اختر تبويب `Indexes`

3. **إنشاء المؤشر المطلوب:**
   - اضغط `Create Index`
   - اختر Collection: `legal_contracts`
   - أضف الحقول التالية بالترتيب:
     ```
     Field: contractType, Order: Ascending
     Field: uploadedAt, Order: Descending
     ```
   - اضغط `Create`

4. **أو استخدم الرابط المباشر:**
   ```
   https://console.firebase.google.com/v1/r/project/qanuni-499f2/firestore/indexes?create_composite=ClRwcm9qZWN0cy9xYW51bmktNDk5ZjIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2xlZ2FsX2NvbnRyYWN0cy9pbmRleGVzL18QARoQCgxjb250cmFjdFR5cGUQARoOCgp1cGxvYWRlZEF0EAIaDAoIX19uYW1lX18QAg
   ```

### الخطوة 2: تحديث قواعد الأمان

انسخ والصق قواعد الأمان التالية في Firestore Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // قواعد مجموعة العقود القانونية
    match /legal_contracts/{document} {
      allow read, write: if request.auth != null && isAdmin(request.auth.uid);
    }
    
    // قواعد مجموعة المديرين
    match /admins/{document} {
      allow read: if request.auth != null && request.auth.uid == document;
      allow write: if request.auth != null && isAdmin(request.auth.uid);
    }
    
    // دالة للتحقق من كون المستخدم مدير
    function isAdmin(uid) {
      return exists(/databases/$(database)/documents/admins/$(uid)) &&
             get(/databases/$(database)/documents/admins/$(uid)).data.isActive == true &&
             get(/databases/$(database)/documents/admins/$(uid)).data.role == 'admin';
    }
  }
}
```

### الخطوة 3: تحديث قواعد Firebase Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /legal_contracts/{allPaths=**} {
      allow read, write: if request.auth != null && isAdmin();
    }
    
    function isAdmin() {
      return firestore.exists(/databases/(default)/documents/admins/$(request.auth.uid)) &&
             firestore.get(/databases/(default)/documents/admins/$(request.auth.uid)).data.isActive == true;
    }
  }
}
```

## 🔄 اختبار النظام:

### 1. إنشاء حساب مدير:
```bash
flutter run -d chrome --web-port=8080
```

### 2. التحقق من إنشاء سجل المدير:
- انتقل إلى Firestore Console
- تحقق من وجود مجموعة `admins`
- تأكد من وجود وثيقة للمدير الجديد

### 3. اختبار الفلترة:
- ارفع ملف PDF
- اختبر فلترة العقود بالنوع
- يجب أن تعمل الفلترة الآن (مع أو بدون المؤشر)

## 📊 هيكل البيانات:

### مجموعة `admins`:
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "role": "admin",
  "isActive": true,
  "permissions": {
    "canUpload": true,
    "canDelete": true,
    "canManageUsers": true,
    "canViewStats": true
  },
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

### مجموعة `legal_contracts`:
```json
{
  "fileName": "string",
  "downloadUrl": "string",
  "fileSize": "number",
  "contractType": "string",
  "description": "string",
  "uploadedAt": "timestamp",
  "uploadFileName": "string",
  "contentType": "application/pdf"
}
```

## ✨ الميزات الجديدة:

### 1. إدارة المديرين:
- ✅ إنشاء سجل مدير تلقائياً
- ✅ تتبع آخر تسجيل دخول
- ✅ إدارة الصلاحيات
- ✅ تفعيل/تعطيل المديرين

### 2. الأمان المحسن:
- ✅ قواعد أمان متقدمة
- ✅ التحقق من صلاحيات المديرين
- ✅ حماية البيانات الحساسة

### 3. معالجة الأخطاء:
- ✅ آلية fallback للاستعلامات
- ✅ رسائل خطأ واضحة باللغة العربية
- ✅ تسجيل مفصل للأخطاء

## 🚀 الخطوات التالية:

1. **إنشاء المؤشرات** (الأولوية القصوى)
2. **تحديث قواعد الأمان**
3. **اختبار النظام الكامل**
4. **إضافة واجهة إدارة المديرين** (اختياري)

بعد تطبيق هذه الخطوات، سيعمل النظام بكفاءة عالية وأمان محسن! 🎉
