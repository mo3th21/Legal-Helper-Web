import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/auth_service.dart';
import '../services/legal_contract_service.dart';
import '../models/legal_contract.dart';
import '../models/contract_type.dart';
import 'login_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ...existing code...

  Widget _buildContractTypeDropdown(BuildContext dialogContext, void Function(void Function()) setStateDialog) {
  final theme = Theme.of(dialogContext);
  final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.25), width: 1.2),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ContractType>(
          value: _selectedContractType,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          style: GoogleFonts.notoSansArabic(fontSize: 15, color: Colors.black),
          dropdownColor: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          items: ContractType.values.map((type) {
            return DropdownMenuItem<ContractType>(
              value: type,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    decoration: BoxDecoration(
                      color: Color(type.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    type.arabicName,
                    style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (ContractType? newValue) {
            if (newValue != null) {
              setStateDialog(() {
                _selectedContractType = newValue;
              });
            }
          },
        ),
      ),
    );
  }
  final AuthService _authService = AuthService();
  final LegalContractService _contractService = LegalContractService();

  bool _isUploading = false;
  ContractType _selectedContractType = ContractType.other;
  String _contractDescription = '';
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  List<LegalContract> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadUploadedFiles();
  }

  Future<void> _loadUploadedFiles() async {
    try {
      final contracts = await _contractService.getContracts();
      setState(() {
        _uploadedFiles = contracts;
      });
    } catch (e) {
      debugPrint('Error loading files: $e');
    }
  }


  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      if (result != null) {
        final file = result.files.first;
        final lowerName = file.name.toLowerCase();
        if (!(lowerName.endsWith('.pdf') || lowerName.endsWith('.doc') || lowerName.endsWith('.docx'))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى اختيار ملف PDF أو Word فقط'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        setState(() {
          _selectedFile = file;
          _fileBytes = file.bytes;
        });
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار ملف أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _isUploading = true;
    });
    try {
      LegalContract contract = await _contractService.uploadContract(
        fileBytes: _fileBytes!,
        fileName: _selectedFile!.name,
        contractType: _selectedContractType,
        description: _contractDescription.isNotEmpty ? _contractDescription : null,
        onProgress: (progress) {
          setState(() {});
        },
      );
      setState(() {
        _selectedFile = null;
        _fileBytes = null;
        _contractDescription = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفع العقد بنجاح: ${contract.fileName}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUploadedFiles();
      }
    } catch (e) {
  setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تسجيل الخروج: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final primaryGradient = LinearGradient(
      colors: [
        colorScheme.primary,
        colorScheme.primary.withOpacity(0.85),
        colorScheme.secondary,
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'العقود',
          style: GoogleFonts.notoSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: _signOut,
            color: colorScheme.onPrimary,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: primaryGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: colorScheme.primary.withOpacity(0.13),
                      child: Icon(Icons.gavel, size: 48, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'مرحباً بك 👋',
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إدارة وتنظيم العقود القانونية بسهولة',
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 15,
                        color: textTheme.bodyMedium?.color ?? colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 26),
                  label: Text(
                    'إنشاء عقد جديد',
                    style: GoogleFonts.notoSansArabic(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onPrimary,
                    foregroundColor: colorScheme.primary,
                    elevation: 2,
                    textStyle: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    shadowColor: colorScheme.primary.withOpacity(0.12),
                  ),
                  onPressed: _showCreateContractDialog,
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'العقود المرفوعة',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _uploadedFiles.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        children: [
                          Icon(Icons.description_outlined, size: 64, color: colorScheme.onPrimary.withOpacity(0.7)),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد عقود بعد',
                            style: GoogleFonts.notoSansArabic(
                              fontSize: 17,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'اضغط على "إنشاء عقد جديد" لإضافة أول عقد',
                            style: GoogleFonts.notoSansArabic(
                              fontSize: 14,
                              color: colorScheme.onPrimary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final contract = _uploadedFiles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 4,
                          color: colorScheme.surface.withOpacity(0.97),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Color(contract.contractType.colorValue).withOpacity(0.13),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.description, color: Color(contract.contractType.colorValue), size: 28),
                            ),
                            title: Text(
                              contract.fileName,
                              style: GoogleFonts.notoSansArabic(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: textTheme.titleMedium?.color ?? colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (contract.description != null && contract.description!.isNotEmpty)
                                  Text(
                                    contract.description!,
                                    style: GoogleFonts.notoSansArabic(
                                      fontSize: 13,
                                      color: textTheme.bodySmall?.color ?? colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                Text(
                                  'تاريخ الرفع: ${contract.formattedUploadDate}',
                                  style: GoogleFonts.notoSansArabic(
                                    fontSize: 12,
                                    color: textTheme.bodySmall?.color?.withOpacity(0.7) ?? colorScheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'حذف',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('تأكيد الحذف', style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold)),
                                        content: Text('هل أنت متأكد من حذف الملف "${contract.fileName}"؟', style: GoogleFonts.notoSansArabic()),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('إلغاء', style: GoogleFonts.notoSansArabic()),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              try {
                                                await _contractService.deleteContract(contract); // مرر كائن العقد المناسب هنا
                                                Navigator.pop(context);
                                                _loadUploadedFiles(); // لإعادة تحميل القائمة بعد الحذف
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('تم حذف العقد بنجاح', style: GoogleFonts.notoSansArabic())),
                                                );
                                              } catch (e) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('فشل في حذف العقد: $e', style: GoogleFonts.notoSansArabic())),
                                                );
                                              }
                                            },
                                            child: Text('حذف', style: GoogleFonts.notoSansArabic(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateContractDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    showDialog(
      context: context,
      barrierDismissible: !_isUploading,
      builder: (context) {
        return Dialog(
          elevation: 16,
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(Icons.add_circle_outline, color: colorScheme.primary, size: 28),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('إنشاء عقد جديد', style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, fontSize: 21, color: textTheme.titleLarge?.color ?? colorScheme.onSurface)),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: 'إغلاق',
                                color: colorScheme.onSurface,
                                onPressed: _isUploading ? null : () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Contract Name
                          Text('اسم العقد', style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, fontSize: 16, color: textTheme.titleMedium?.color ?? colorScheme.onSurface)),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              hintText: 'أدخل اسم العقد...',
                              hintStyle: GoogleFonts.notoSansArabic(color: textTheme.bodySmall?.color?.withOpacity(0.7) ?? colorScheme.onSurface.withOpacity(0.7)),
                              filled: true,
                              fillColor: colorScheme.surface,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            style: GoogleFonts.notoSansArabic(fontSize: 15, color: textTheme.bodyMedium?.color ?? colorScheme.onSurface),
                            onChanged: (value) {
                              setStateDialog(() {
                                _contractDescription = value;
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          // Contract Type
                          Text('نوع العقد', style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, fontSize: 16, color: textTheme.titleMedium?.color ?? colorScheme.onSurface)),
                          const SizedBox(height: 10),
                          _buildContractTypeDropdown(context, setStateDialog),
                          const SizedBox(height: 18),
                          // File Upload
                          Text('رفع الملف', style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, fontSize: 16, color: textTheme.titleMedium?.color ?? colorScheme.onSurface)),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _isUploading
                                ? null
                                : () async {
                                    await _pickFile();
                                    setStateDialog(() {});
                                  },
                            icon: const Icon(Icons.upload_file),
                            label: Text('اختر ملف PDF', style: GoogleFonts.notoSansArabic(color: colorScheme.onPrimary)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              textStyle: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, fontSize: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(0, 44),
                            ),
                          ),
                          if (_selectedFile != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.description, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_selectedFile!.name, style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, color: textTheme.bodyMedium?.color ?? colorScheme.onSurface)),
                                        Text('الحجم: ${_formatFileSize(_selectedFile!.size)}', style: GoogleFonts.notoSansArabic(color: textTheme.bodySmall?.color ?? colorScheme.onSurface)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setStateDialog(() {
                                        _selectedFile = null;
                                        _fileBytes = null;
                                      });
                                    },
                                    icon: Icon(Icons.close, color: colorScheme.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Upload Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isUploading || _selectedFile == null
                                  ? null
                                  : () async {
                                      setStateDialog(() { _isUploading = true; });
                                      await _uploadFile();
                                      setStateDialog(() { _isUploading = false; });
                                      if (mounted && !_isUploading) Navigator.pop(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                textStyle: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, fontSize: 17),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isUploading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('جاري الرفع...', style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                                      ],
                                    )
                                  : Text('رفع العقد', style: GoogleFonts.notoSansArabic(color: colorScheme.onPrimary)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        color: colorScheme.surface.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: colorScheme.primary),
                              const SizedBox(height: 16),
                              Text('جاري رفع الملف...', style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
