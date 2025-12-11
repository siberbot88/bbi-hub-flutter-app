import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_alert.dart';
import '../../../../core/models/workshop.dart';

class EditProfilePage extends StatefulWidget {
  final Workshop workshop;
  
  const EditProfilePage({super.key, required this.workshop});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _nameC;
  late TextEditingController _openingTimeC;
  late TextEditingController _closingTimeC;
  late TextEditingController _operationalDaysC;
  late TextEditingController _informationC;
  
  bool _isActive = false;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.workshop.name);
    _openingTimeC = TextEditingController(text: widget.workshop.openingTime);
    _closingTimeC = TextEditingController(text: widget.workshop.closingTime);
    _operationalDaysC = TextEditingController(text: widget.workshop.operationalDays);
    _informationC = TextEditingController(text: widget.workshop.description ?? '');
    _isActive = widget.workshop.isActive;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _openingTimeC.dispose();
    _closingTimeC.dispose();
    _operationalDaysC.dispose();
    _informationC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format ke HH:mm:ss
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = "$hour:$minute:00";
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.updateWorkshop(
        id: widget.workshop.id,
        name: _nameC.text,
        photo: _pickedImage,
        openingTime: _openingTimeC.text,
        closingTime: _closingTimeC.text,
        operationalDays: _operationalDaysC.text,
        isActive: _isActive,
        information: _informationC.text,
      );

      if (!mounted) return;

      CustomAlert.show(
        context,
        title: "Berhasil",
        message: "Profil workshop berhasil diperbarui",
        type: AlertType.success,
      );
      
      Navigator.pop(context, true); 

    } catch (e) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Gagal",
        message: e.toString().replaceAll('Exception: ', ''),
        type: AlertType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Profil Workshop",
          style: AppTextStyles.heading4(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              AppSpacing.verticalSpaceXL,
              Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusXL,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _LabeledField(
                      label: "Nama Workshop",
                      controller: _nameC,
                      prefixIcon: Icons.store_rounded,
                    ),
                    AppSpacing.verticalSpaceLG,
                    
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: "Jam Buka",
                            controller: _openingTimeC,
                            prefixIcon: Icons.access_time_rounded,
                            readOnly: true,
                            onTap: () => _selectTime(context, _openingTimeC),
                          ),
                        ),
                        AppSpacing.horizontalSpaceMD,
                        Expanded(
                          child: _LabeledField(
                            label: "Jam Tutup",
                            controller: _closingTimeC,
                            prefixIcon: Icons.access_time_filled_rounded,
                            readOnly: true,
                            onTap: () => _selectTime(context, _closingTimeC),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpaceLG,

                    _LabeledField(
                      label: "Hari Operasional",
                      controller: _operationalDaysC,
                      prefixIcon: Icons.calendar_today_rounded,
                      hintText: "Contoh: Senin - Jumat",
                    ),
                    AppSpacing.verticalSpaceLG,

                    _LabeledField(
                      label: "Nama Lengkap",
                      controller: _fullNameC,
                      prefixIcon: Icons.person_add_alt,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusXL,
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryRed.withAlpha(100),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "SIMPAN PERUBAHAN",
                          style: AppTextStyles.button(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryRed, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: _pickedImage != null
                    ? DecorationImage(
                        image: FileImage(_pickedImage!),
                        fit: BoxFit.cover,
                      )
                    : (widget.workshop.photo != null
                        ? DecorationImage(
                            image: NetworkImage(widget.workshop.photo!),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              child: (_pickedImage == null && widget.workshop.photo == null)
                  ? const Icon(Icons.store_rounded, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final String? hintText;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(color: AppColors.textSecondary)),
        AppSpacing.verticalSpaceXS,
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          validator: (v) => (v == null || v.isEmpty) ? "Tidak boleh kosong" : null,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primaryRed)
                : null,
            filled: true,
            fillColor: AppColors.backgroundLight,
            hintText: hintText ?? "Masukkan $label",
            hintStyle: AppTextStyles.bodyMedium(color: AppColors.textHint),
            contentPadding: AppSpacing.paddingMD,
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          style: AppTextStyles.bodyMedium(),
        ),
      ],
    );
  }
}
