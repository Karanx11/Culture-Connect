import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? profileImage;
  File? coverImage;

  String profileUrl = "";
  String coverUrl = "";

  final picker = ImagePicker();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final cityController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// 🔥 LOAD EXISTING DATA
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        nameController.text = data['name'] ?? "";
        usernameController.text = data['username'] ?? "";
        bioController.text = data['bio'] ?? "";
        cityController.text = data['city'] ?? "";

        profileUrl = data['profileUrl'] ?? "";
        coverUrl = data['coverUrl'] ?? "";

        isLoading = false;
      });
    }
  }

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

  /// 🔥 UPLOAD IMAGE
  Future<String> uploadImage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  /// 💾 SAVE PROFILE
  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String updatedProfileUrl = profileUrl;
    String updatedCoverUrl = coverUrl;

    // upload profile image
    if (profileImage != null) {
      updatedProfileUrl = await uploadImage(
        profileImage!,
        "users/${user.uid}/profile.jpg",
      );
    }

    // upload cover image
    if (coverImage != null) {
      updatedCoverUrl = await uploadImage(
        coverImage!,
        "users/${user.uid}/cover.jpg",
      );
    }

    // update firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      "name": nameController.text.trim(),
      "username": usernameController.text.trim().toLowerCase(),
      "bio": bioController.text.trim(),
      "city": cityController.text.trim(),
      "profileUrl": updatedProfileUrl,
      "coverUrl": updatedCoverUrl,
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated ✅")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            /// 🔥 COVER + PROFILE
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: pickCoverImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: coverImage != null
                          ? DecorationImage(
                              image: FileImage(coverImage!),
                              fit: BoxFit.cover,
                            )
                          : coverUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(coverUrl),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage("assets/images/auth.jpg"),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -50,
                  left: 20,
                  child: GestureDetector(
                    onTap: pickProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : profileUrl.isNotEmpty
                          ? NetworkImage(profileUrl)
                          : const AssetImage("assets/images/logo.jpg")
                                as ImageProvider,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            /// FORM
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

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5100),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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

  /// INPUT FIELD
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
