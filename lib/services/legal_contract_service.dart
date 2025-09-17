import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/legal_contract.dart';
import '../models/contract_type.dart';

/// Service class to handle all Firebase operations for legal contracts
class LegalContractService {
  static const String _collectionName = 'legal_contracts';
  static const String _storageFolder = 'legal_contracts';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get all legal contracts as a future (one-time fetch)
  Future<List<LegalContract>> getContracts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('uploadedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => LegalContract.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching contracts: $e');
      throw Exception('فشل في تحميل العقود: $e');
    }
  }

  /// Upload a PDF file and save its metadata
  Future<LegalContract> uploadContract({
    required Uint8List fileBytes,
    required String fileName,
    required ContractType contractType,
    String? description,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file size (max 10MB)
      if (fileBytes.length > 10 * 1024 * 1024) {
        throw Exception('حجم الملف كبير جداً. الحد الأقصى 10 ميجابايت');
      }

      // Create unique filename
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String uploadFileName = '${timestamp}_$fileName';

      debugPrint('Uploading file: $fileName (${fileBytes.length} bytes)');

      // Upload to Firebase Storage
      Reference storageRef = _storage
          .ref()
          .child(_storageFolder)
          .child(uploadFileName);

      UploadTask uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );

      // Listen to progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('File uploaded successfully. Getting download URL...');

      // Create contract object
      LegalContract contract = LegalContract(
        fileName: fileName,
        downloadUrl: downloadUrl,
        uploadFileName: uploadFileName,
        contractType: contractType,
        description: description,
      );

      // Save to Firestore
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(contract.toFirestoreMap());

      debugPrint('Contract metadata saved to Firestore');

      // Return contract with ID
      return contract.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Upload error: $e');
      throw Exception('فشل في رفع الملف: $e');
    }
  }

  /// Delete a contract and its file from storage
  Future<void> deleteContract(LegalContract contract) async {
    try {
      if (contract.id == null) {
        throw Exception('معرف العقد غير صحيح');
      }

      // Delete from Storage
      Reference storageRef = _storage
          .ref()
          .child(_storageFolder)
          .child(contract.uploadFileName);
      
      await storageRef.delete();
      debugPrint('File deleted from storage: ${contract.uploadFileName}');

      // Delete from Firestore
      await _firestore
          .collection(_collectionName)
          .doc(contract.id!)
          .delete();
      
      debugPrint('Contract deleted from Firestore: ${contract.id}');
    } catch (e) {
      debugPrint('Delete error: $e');
      throw Exception('فشل في حذف العقد: $e');
    }
  }

  /// Get contracts by type
  Future<List<LegalContract>> getContractsByType(ContractType contractType) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('contractType', isEqualTo: contractType.value)
          .orderBy('uploadedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => LegalContract.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Filter by type error: $e');
      // Fallback: Get all contracts and filter client-side
      List<LegalContract> allContracts = await getContracts();
      return allContracts
          .where((contract) => contract.contractType == contractType)
          .toList();
    }
  }
}
