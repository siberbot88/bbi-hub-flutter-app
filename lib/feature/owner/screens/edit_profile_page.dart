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
  final _emailC = TextEditingController(text: "");
  final _usernameC = TextEditingController(text: "");
  final _fullNameC = TextEditingController(text: "");

  ImageProvider? _pickedImage;

  @override
  void dispose() {
    _emailC.dispose();
    _usernameC.dispose();
    _fullNameC.dispose();
    super.dispose();
  }

  // Placeholder pemilihan gambar (tanpa dependency).
  void _pickImageMock() {
    // Demo: pakai gambar mockup yang kamu punya
    setState(() {
      _pickedImage = const AssetImage("assets/image/profil_image.png");
      // kalau mau benar2 pilih dari gallery/camera, tinggal ganti
      // dengan image_picker / file_picker.
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    CustomAlert.show(
      context,
      title: "Berhasil",
      message: "Profil disimpan",
      type: AlertType.success,
    );
    Navigator.pop(context);
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
          "Edit Profil",
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
                      label: "Email",
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    AppSpacing.verticalSpaceLG,
                    _LabeledField(
                      label: "Username",
                      controller: _usernameC,
                      prefixIcon: Icons.person_outline,
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
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusXL,
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryRed.withAlpha(100),
                  ),
                  child: Text(
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
            onTap: _pickImageMock,
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
                    ? DecorationImage(image: _pickedImage!, fit: BoxFit.cover)
                    : null,
              ),
              child: _pickedImage == null
                  ? const Icon(Icons.person_rounded, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImageMock,
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
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
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
          keyboardType: keyboardType,
          validator: (v) => (v == null || v.isEmpty) ? "Tidak boleh kosong" : null,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primaryRed)
                : null,
            filled: true,
            fillColor: AppColors.backgroundLight,
            hintText: "Masukkan $label",
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
