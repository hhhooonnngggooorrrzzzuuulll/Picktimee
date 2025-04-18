import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
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
        labelStyle: TextStyle(color: Colors.black87),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple.shade100),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        if (isEmail && !value.contains('@')) {
          return 'Зөв имэйл оруулна уу';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F6FC),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 10, left: 8),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.white,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Хувийн мэдээлэл засах',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 218, 175, 249),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gradient Header with Photo
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 218, 175, 249),
                      Color.fromARGB(255, 218, 175, 249),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 30, color: Colors.white),
                                  SizedBox(height: 4),
                                  Text(
                                    'Зураг нэмэх',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF872BC0),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              // Form Section
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
                          labelStyle: TextStyle(color: Colors.black87),
                          prefixIcon:
                              Icon(Icons.phone, color: Color(0xFF872BC0)),
                          prefixText: '+976 ',
                          prefixStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.deepPurple.shade100),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF872BC0)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Утасны дугаар оруулна уу';
                          }
                          if (value.length < 8) {
                            return 'Утасны дугаар буруу байна';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      // Save Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Профайл шинэчлэгдлээ')),
                            );
                          }
                        },
                        icon: Icon(Icons.save),
                        label: Text(
                          'Хадгалах',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF872BC0),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
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
