import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? profileImage;
  File? coverImage;

  final picker = ImagePicker();

  final TextEditingController nameController = TextEditingController(
    text: "Karan Sharma",
  );

  final TextEditingController usernameController = TextEditingController(
    text: "karan_x11",
  );

  final TextEditingController bioController = TextEditingController(
    text: "Culture Explorer 🌍",
  );

  final TextEditingController cityController = TextEditingController(
    text: "Lucknow",
  );

  /// 📸 PICK PROFILE IMAGE
  Future<void> pickProfileImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  /// 🖼 PICK COVER IMAGE
  Future<void> pickCoverImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => coverImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔥 COVER + PROFILE SECTION
            Stack(
              clipBehavior: Clip.none,
              children: [
                /// 🌄 COVER IMAGE
                GestureDetector(
                  onTap: pickCoverImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: coverImage == null
                          ? const LinearGradient(
                              colors: [Color(0xFFFF5100), Color(0xFF1A0F0A)],
                            )
                          : null,
                      image: coverImage != null
                          ? DecorationImage(
                              image: FileImage(coverImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.camera_alt, color: Colors.white70),
                      ),
                    ),
                  ),
                ),

                /// 👤 PROFILE IMAGE
                Positioned(
                  bottom: -50,
                  left: 20,
                  child: GestureDetector(
                    onTap: pickProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : const AssetImage("assets/images/logo.jpg")
                                    as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5100),
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            /// 🧊 FORM SECTION
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _input(nameController, "Name", Icons.person),
                  const SizedBox(height: 12),

                  _input(usernameController, "Username", Icons.alternate_email),
                  const SizedBox(height: 12),

                  _input(bioController, "Bio", Icons.edit, maxLines: 3),
                  const SizedBox(height: 12),

                  _input(cityController, "City", Icons.location_on),

                  const SizedBox(height: 25),

                  /// 💾 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile Updated ✅")),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧊 GLASS INPUT FIELD
  Widget _input(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white70),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
