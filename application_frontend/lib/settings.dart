import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Mongolian', 'Spanish'];
  final Color primaryAccent = const Color.fromARGB(255, 218, 175, 249);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setString('language', _selectedLanguage);
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeaderContainer(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('Appearance'),
                _buildCard(child: _buildDarkModeToggle()),
                const SizedBox(height: 20),
                _buildSectionTitle('Notifications'),
                _buildCard(child: _buildNotificationToggle()),
                const SizedBox(height: 20),
                _buildSectionTitle('Language'),
                _buildCard(child: _buildLanguageSelector()),
                const SizedBox(height: 20),
                _buildSectionTitle('Support'),
                _buildCard(child: _buildSupportButton()),
                const SizedBox(height: 20),
                _buildSectionTitle('Account'),
                _buildCard(child: _buildLogoutButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContainer() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: primaryAccent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 6,
      shadowColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _isDarkMode ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Dark Mode', style: TextStyle(fontSize: 18)),
        FlutterSwitch(
          width: 55,
          height: 30,
          toggleSize: 20,
          value: _isDarkMode,
          activeColor: primaryAccent,
          inactiveColor: Colors.grey,
          onToggle: (val) {
            setState(() {
              _isDarkMode = val;
            });
            _savePreferences();
          },
        ),
      ],
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Enable Notifications', style: TextStyle(fontSize: 18)),
        FlutterSwitch(
          width: 55,
          height: 30,
          toggleSize: 20,
          value: _notifications,
          activeColor: primaryAccent,
          inactiveColor: Colors.grey,
          onToggle: (val) {
            setState(() {
              _notifications = val;
            });
            _savePreferences();
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      decoration: InputDecoration(
        filled: true,
        fillColor: _isDarkMode ? Colors.grey[700] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelText: 'Select Language',
        labelStyle: TextStyle(
          color: _isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
      dropdownColor: _isDarkMode ? Colors.grey[850] : Colors.white,
      style: TextStyle(
        color: _isDarkMode ? Colors.white : Colors.black,
      ),
      items: _languages.map((String lang) {
        return DropdownMenuItem<String>(
          value: lang,
          child: Text(lang),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        _savePreferences();
      },
    );
  }

  Widget _buildSupportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Support contacted!')),
          );
        },
        icon: const Icon(Icons.support_agent),
        label: const Text('Contact Support'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
