import 'dart:io';
import 'package:cconnect/common/widgets/forms/custom_textformfield.dart';
import 'package:cconnect/common/widgets/texts/text_widget.dart';
import 'package:cconnect/data/models/userModel.dart' as model;
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:cconnect/utils/http/cloudinary_service.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final studentIdController = TextEditingController();
  final departmentController = TextEditingController();
  final sectionController = TextEditingController();
  final CloudinaryService _cloudinary = CloudinaryService();

  String? _selectedDepartment; // Track dropdown selection separately

  // File? _selectedImage; // Removed File dependency for web support
  XFile? _selectedImage; // Use XFile instead
  String? _uploadedImageUrl;
  bool isLoading = false;

  final RegExp pakistaniPhoneRegex = RegExp(r'^(?:\+92|0)?3[0-9]{9}$');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      nameController.text = user.displayName;
      
      if (user.phone != null) {
         phoneController.text = user.phone!;
      }
      
      if (user.studentId != null) {
        studentIdController.text = user.studentId!;
      }

      if (user.department != null && user.department!.isNotEmpty) {
        _selectedDepartment = user.department;
        departmentController.text = user.department!;
      }

      if (user.section != null) {
        sectionController.text = user.section!;
      }

      _uploadedImageUrl = user.photoUrl;
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    await _cloudinary.pickImage(ImageSource.gallery);

    if (_cloudinary.imageFile == null) {
      SnackbarService.error("No image selected");
      return;
    }

    setState(() {
      _selectedImage = _cloudinary.imageFile;
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Upload image if selected
      if (_selectedImage != null) {
        final url = await _cloudinary.uploadImage(
          (uploading) {
            // Optional: update progress
          },
          (error) {
            SnackbarService.error(error);
            throw Exception(error);
          },
        );
        if (url != null) {
          _uploadedImageUrl = url;
        }
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;
      
      if (currentUser != null) {
        final updatedUser = model.User(
          id: currentUser.id,
          displayName: nameController.text.trim(),
          email: currentUser.email,
          photoUrl: _uploadedImageUrl ?? currentUser.photoUrl,
          about: currentUser.about,
          lastSeen: currentUser.lastSeen,
          isOnline: currentUser.isOnline,
          role: currentUser.role,
          studentId: studentIdController.text.trim(),
          phone: phoneController.text.trim(),
          department: departmentController.text.trim(),
          section: sectionController.text.trim(),
          metadata: currentUser.metadata,
        );

        await UserRepository.instance.update(updatedUser);
        userProvider.setUser(updatedUser);

        SnackbarService.success("Profile updated successfully");

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.authGate,
            (route) => false,
          );
        }
      }
    } catch (e) {
      SnackbarService.error("Failed to update profile: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      if (kIsWeb) {
        imageProvider = NetworkImage(_selectedImage!.path); // On web, path is a blob URL
      } else {
        imageProvider = FileImage(File(_selectedImage!.path));
      }
    } else if (_uploadedImageUrl != null) {
      imageProvider = NetworkImage(_uploadedImageUrl!);
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Sizing.paddingAll16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Sizing.h32,
              AppText(
                AppStrings.completeProfile,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                useOutlineColor: true,
              ),
              Sizing.h8,
              AppText(
                AppStrings.completeProfileSubtext,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
                useOutlineColor: true,
              ),
              Sizing.h32,
              GestureDetector(
                onTap: isLoading ? null : _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: imageProvider as ImageProvider<Object>?,
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text("Tap image to upload"),
              Sizing.h24,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: nameController,
                      labelText: AppStrings.fullNameLabel,
                      hintText: AppStrings.fullNameHint,
                      svgIcon: userIcon,
                      validator: (value) => value == null || value.isEmpty
                          ? AppStrings.requiredField
                          : null,
                    ),
                    Sizing.h16,
                    CustomTextFormField(
                      controller: studentIdController,
                      labelText: "Student ID",
                      hintText: "e.g. l23XXXX",
                      svgIcon: userIcon,
                      validator: (value) => value == null || value.isEmpty
                          ? AppStrings.requiredField
                          : null,
                    ),
                    Sizing.h16,
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: "Department",
                        hintText: "Select your department",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: "Computer Science", child: Text("Computer Science")),
                        DropdownMenuItem(value: "Data Science", child: Text("Data Science")),
                        DropdownMenuItem(value: "Artificial Intelligence", child: Text("Artificial Intelligence")),
                        DropdownMenuItem(value: "Business", child: Text("Business")),
                        DropdownMenuItem(value: "Civil Engineering", child: Text("Civil Engineering")),
                        DropdownMenuItem(value: "Software Engineering", child: Text("Software Engineering")),
                        DropdownMenuItem(value: "Electrical Engineering", child: Text("Electrical Engineering")),
                        DropdownMenuItem(value: "Cyber Security", child: Text("Cyber Security")),
                        DropdownMenuItem(value: "Fintech", child: Text("Fintech")),
                      ],
                      validator: (value) => value == null || value.isEmpty
                          ? AppStrings.requiredField
                          : null,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          departmentController.text = value ?? '';
                        });
                      },
                    ),
                    Sizing.h16,
                    CustomTextFormField(
                      controller: sectionController,
                      labelText: "Section",
                      hintText: "e.g. A, B, C",
                      svgIcon: userIcon,
                      validator: (value) => value == null || value.isEmpty
                          ? AppStrings.requiredField
                          : null,
                    ),
                    Sizing.h16,
                    CustomTextFormField(
                      controller: phoneController,
                      labelText: AppStrings.phoneLabel,
                      hintText: "03XX-XXXXXXX or +923XX-XXXXXXX",
                      keyboardType: TextInputType.phone,
                      svgIcon: phoneIcon,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.requiredField;
                        }
                        final phone = value.trim();
                        final isValid = pakistaniPhoneRegex.hasMatch(phone);
                        if (!isValid) {
                          return 'Enter a valid Pakistani phone number';
                        }
                        return null;
                      },
                    ),
                    Sizing.h24,
                    ElevatedButton(
                      onPressed: isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: Sizing.allCircular16,
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(AppStrings.continueBtn),
                    ),
                  ],
                ),
              ),
              Sizing.h32,
              // AppText(
              //   AppStrings.editLaterNote,
              //   textAlign: TextAlign.center,
              //   useOutlineColor: true,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
