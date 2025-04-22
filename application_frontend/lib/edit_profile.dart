import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  Uint8List? _webImage;
  io.File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
      } else {
        _imageFile = io.File(pickedFile.path);
      }
      setState(() {});
    }
  }

  Future<void> updateCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Нэвтэрч орно уу')),
      );
      return;
    }

    final uri = Uri.parse('http://127.0.0.1:8000/update/');
    var request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['cname'] = _nameController.text
      ..fields['cemail'] = _emailController.text
      ..fields['cphone'] = _phoneController.text;

    if (!kIsWeb && _imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('cimage', _imageFile!.path));
    } else if (kIsWeb && _webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('cimage', _webImage!,
          filename: 'profile.png'));
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Профайл шинэчлэгдлээ')),
        );
      } else {
        final data = json.decode(respStr);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Алдаа гарлаа')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа')),
      );
    }
  }

  Widget _buildProfileImage() {
    if (kIsWeb && _webImage != null) {
      return CircleAvatar(radius: 60, backgroundImage: MemoryImage(_webImage!));
    } else if (_imageFile != null) {
      return CircleAvatar(radius: 60, backgroundImage: FileImage(_imageFile!));
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 30, color: Colors.white),
            SizedBox(height: 4),
            Text('Зураг нэмэх',
                style: TextStyle(fontSize: 12, color: Color(0xFF872BC0))),
          ],
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return validatorMsg;
        if (isEmail && !value.contains('@')) return 'Зөв имэйл оруулна уу';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F6FC),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 218, 175, 249),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text('Хувийн мэдээлэл засах',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 218, 175, 249),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _buildProfileImage(),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Нэр',
                        icon: Icons.person_outline,
                        validatorMsg: 'Нэрээ оруулна уу',
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Имэйл',
                        icon: Icons.email_outlined,
                        validatorMsg: 'Имэйл оруулна уу',
                        isEmail: true,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Утасны дугаар',
                          prefixIcon:
                              Icon(Icons.phone, color: Color(0xFF872BC0)),
                          prefixText: '+976 ',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Утасны дугаар оруулна уу';
                          if (value.length < 8)
                            return 'Утасны дугаар буруу байна';
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateCustomer();
                          }
                        },
                        icon: Icon(Icons.save),
                        label: Text('Хадгалах', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF872BC0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
