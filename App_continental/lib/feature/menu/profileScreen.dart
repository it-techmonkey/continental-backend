import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'profile_provider.dart';
import '../../services/s3_upload_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final S3UploadService _s3Service = S3UploadService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    
    // Initialize controllers when profile loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider).value;
      if (profile != null) {
        _initControllers(profile);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initControllers(UserProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

   
    ref.listen<AsyncValue<UserProfile>>(profileProvider, (_, next) {
      if (next is AsyncData && !next.isRefreshing) {
        _initControllers(next.value!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Profile', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          profileState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (profile) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    final image = await _s3Service.pickImage();
                    if (image != null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Uploading image...'), duration: Duration(seconds: 1)),
                      );
                      final url = await _s3Service.uploadImage(
                        imageFile: File(image.path),
                        uploadType: 'profile-image',
                        fileName: image.name,
                      );
                      if (mounted) {
                        if (url != null) {
                          final updatedProfile = profile.copyWith(imageUrl: url);
                          ref.read(profileProvider.notifier).saveProfile(updatedProfile);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile image uploaded!'), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upload failed'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profile.imageUrl),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                _buildTextField(label: 'Name', controller: _nameController),
                const SizedBox(height: 20),
                _buildTextField(label: 'Email', controller: _emailController, hint: 'Enter', readOnly: true),
                const SizedBox(height: 20),
                _buildTextField(label: 'Phone No', controller: _phoneController, isPhone: true),
                const SizedBox(height: 120), // Space for button
              ],
            ),
          ),
     
          if (profileState.isRefreshing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomSheet: _buildSaveButton(),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isPhone = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          enabled: !readOnly,
          style: TextStyle(color: readOnly ? Colors.grey[600] : Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: isPhone ? const Padding(padding: EdgeInsets.only(left: 12.0, top: 12.0), child: Text('+971 | ', style: TextStyle(color: Colors.white, fontSize: 16))) : null,
            filled: true,
            fillColor: Colors.grey[900],
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.yellow)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final currentProfile = ref.read(profileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
            );
            ref.read(profileProvider.notifier).saveProfile(updatedProfile).then((_) {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile Saved!'), backgroundColor: Colors.green),
              );
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text('Save', style: GoogleFonts.inter(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}