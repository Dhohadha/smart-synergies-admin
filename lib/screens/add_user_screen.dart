import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _pondsController = TextEditingController();
  final _aeratorsController = TextEditingController();
  final _relayCountController = TextEditingController(text: '2'); // Default to 2 relays

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'User Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField('Full Name', _nameController, Icons.person),
                const SizedBox(height: 15),
                _buildTextField(
                  'Email Address',
                  _emailController,
                  Icons.email,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  'Primary Phone (Optional)',
                  _phoneController,
                  Icons.phone,
                  type: TextInputType.phone,
                  isOptional: true,
                ),
                const SizedBox(height: 30),

                const Text(
                  'Device Assignment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  'Device ID (e.g., PMS_001)',
                  _deviceIdController,
                  Icons.developer_board,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'No. of Ponds (Optional)',
                        _pondsController,
                        Icons.water_drop_outlined,
                        type: TextInputType.number,
                        isOptional: true,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildTextField(
                        'No. of Aerators (Optional)',
                        _aeratorsController,
                        Icons.air_outlined,
                        type: TextInputType.number,
                        isOptional: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  'Relay Count (Switches)',
                  _relayCountController,
                  Icons.power_settings_new,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saving user and initializing device...')),
                        );

                        try {
                          final response = await http.post(
                            Uri.parse('${ApiService.baseUrl}/api/users/register'),
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({
                              'name': _nameController.text.trim(),
                              'phone': _phoneController.text.trim(),
                              'email': _emailController.text.trim().toLowerCase(),
                              'deviceId': _deviceIdController.text.trim(),
                              'ponds': int.tryParse(_pondsController.text) ?? 1,
                              'aerators': int.tryParse(_aeratorsController.text) ?? 1,
                              'relayCount': int.tryParse(_relayCountController.text) ?? 2,
                            }),
                          );

                          if (response.statusCode == 201) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User registered and Device configured successfully!'),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                              Navigator.pop(context, true); // Return true to refresh list
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed: ${response.body}'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error connecting to backend: $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'REGISTER CLIENT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: isOptional ? null : (val) => val == null || val.trim().isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.teal.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
