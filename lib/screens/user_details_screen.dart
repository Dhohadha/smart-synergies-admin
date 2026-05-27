import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final dynamic user;
  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late dynamic _user;
  bool _isLoading = false;
  List<dynamic> _sharedUsers = [];
  bool _isLoadingSharedUsers = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadSharedUsers();
  }

  Future<void> _loadSharedUsers() async {
    setState(() => _isLoadingSharedUsers = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/users/${_user['email']}/shared-details-admin'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _sharedUsers = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error loading shared users: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSharedUsers = false);
      }
    }
  }

  Future<void> _addDevice(String deviceId) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/users/${_user['email']}/devices'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'deviceId': deviceId}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _user = json.decode(response.body)['user'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device added successfully'), backgroundColor: Colors.teal),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeDevice(String deviceId) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/api/users/${_user['email']}/devices/$deviceId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _user = json.decode(response.body)['user'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device removed successfully'), backgroundColor: Colors.teal),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareAccess(String email, List<String> deviceIds) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/users/${_user['email']}/share'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sharedEmail': email.toLowerCase().trim(),
          'deviceIds': deviceIds,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access shared successfully'), backgroundColor: Colors.teal),
          );
        }
        _loadSharedUsers();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _revokeAccess(String workerEmail) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/api/users/revoke-access-admin/${_user['email']}/$workerEmail'),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access revoked successfully'), backgroundColor: Colors.teal),
          );
        }
        _loadSharedUsers();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editSharedDevices(String workerEmail, List<String> deviceIds) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/users/share/devices-admin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ownerEmail': _user['email'],
          'sharedEmail': workerEmail,
          'deviceIds': deviceIds,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shared devices updated successfully'), backgroundColor: Colors.teal),
          );
        }
        _loadSharedUsers();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditSharedDevicesDialog(dynamic worker) {
    final workerEmail = worker['email'] as String;
    final List<String> currentlyShared = (worker['devices'] as List<dynamic>? ?? []).cast<String>();
    final List<String> ownerDevices = (_user['assignedDevices'] as List<dynamic>? ?? []).cast<String>();
    final Map<String, bool> selectedDevices = {
      for (var id in ownerDevices) id: currentlyShared.contains(id)
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit Devices for $workerEmail', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Devices to Share:',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                if (ownerDevices.isEmpty)
                  const Text('No devices available to share.', style: TextStyle(color: Colors.grey, fontSize: 13))
                else
                  ...ownerDevices.map((id) => CheckboxListTile(
                        title: Text(id, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        value: selectedDevices[id],
                        activeColor: Colors.teal,
                        onChanged: (val) {
                          setDialogState(() {
                            selectedDevices[id] = val ?? false;
                          });
                        },
                      )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final selectedIds = selectedDevices.entries.where((e) => e.value).map((e) => e.key).toList();
                Navigator.pop(context);
                _editSharedDevices(workerEmail, selectedIds);
              },
              child: const Text('Save', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateDeviceSettings(String deviceId, Map<String, dynamic> settings) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/devices/config/$deviceId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(settings),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device settings updated'), backgroundColor: Colors.teal),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/api/users/${_user['email']}'),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.teal,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh list screen
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete user: ${response.body}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteUserConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete User', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete user ${_user['name']} (${_user['email']})?\n\nThis will also revoke access for any workers they shared devices with and clean up their associated data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Assign New Device', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter Device ID (e.g. PMS_002)',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _addDevice(controller.text.trim());
              }
            },
            child: const Text('Assign', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRemoveDeviceConfirmation(String deviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text('Are you sure you want to remove device $deviceId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeDevice(deviceId);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showShareAccessDialog() {
    final TextEditingController emailController = TextEditingController();
    final List<String> devices = (_user['assignedDevices'] as List<dynamic>? ?? []).cast<String>();
    final Map<String, bool> selectedDevices = {for (var id in devices) id: true};

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign at least one device to the user first.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Share Device Access', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter Client/Worker Email',
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Devices to Share:',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ...devices.map((id) => CheckboxListTile(
                      title: Text(id, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      value: selectedDevices[id],
                      activeColor: Colors.teal,
                      onChanged: (val) {
                        setDialogState(() {
                          selectedDevices[id] = val ?? false;
                        });
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final selectedIds = selectedDevices.entries.where((e) => e.value).map((e) => e.key).toList();
                if (emailController.text.trim().isNotEmpty && selectedIds.isNotEmpty) {
                  Navigator.pop(context);
                  _shareAccess(emailController.text.trim(), selectedIds);
                } else if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one device'), backgroundColor: Colors.orange),
                  );
                }
              },
              child: const Text('Share', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceSettingsDialog(String deviceId) async {
    setState(() => _isLoading = true);
    dynamic deviceData;
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/api/devices/status/$deviceId'));
      if (response.statusCode == 200) {
        deviceData = json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching device data: $e');
    } finally {
      setState(() => _isLoading = false);
    }

    if (deviceData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load device status'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    final TextEditingController nameController = TextEditingController(text: deviceData['name'] ?? '');
    final TextEditingController locationController = TextEditingController(text: deviceData['location'] ?? '');
    final TextEditingController relayCountController = TextEditingController(text: (deviceData['relayCount'] ?? 2).toString());
    final TextEditingController aeratorsController = TextEditingController(text: (deviceData['totalAerators'] ?? 0).toString());

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Edit Device: $deviceId', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Device Name (e.g. Pond A)', labelStyle: TextStyle(color: Colors.teal)),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location (City/Village)', labelStyle: TextStyle(color: Colors.teal)),
              ),
              TextField(
                controller: relayCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Relay Count (Switches)', labelStyle: TextStyle(color: Colors.teal)),
              ),
              TextField(
                controller: aeratorsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Aerators', labelStyle: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateDeviceSettings(deviceId, {
                'name': nameController.text.trim(),
                'location': locationController.text.trim(),
                'relayCount': int.tryParse(relayCountController.text) ?? 2,
                'totalAerators': int.tryParse(aeratorsController.text) ?? 0,
              });
            },
            child: const Text('Save', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = _user['assignedDevices'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _showDeleteUserConfirmation,
            tooltip: 'Delete User',
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assigned Devices',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
                        onPressed: _showAddDeviceDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  devices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('No devices assigned.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            return _buildDeviceCard(devices[index]);
                          },
                        ),
                  const SizedBox(height: 30),
                  const Text(
                    'Shared Access Control',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _showShareAccessDialog,
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    label: const Text('Share Devices with Worker/User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'People with Access',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 15),
                  _isLoadingSharedUsers
                      ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                      : _sharedUsers.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text('No workers/users have shared access.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _sharedUsers.length,
                              itemBuilder: (context, index) {
                                final worker = _sharedUsers[index];
                                final email = worker['email'] ?? '';
                                final status = worker['status'] ?? 'Pending';
                                final isPending = status == 'Pending';
                                final List<String> wDevices = (worker['devices'] as List<dynamic>? ?? []).cast<String>();

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: isPending ? Colors.orange.shade50 : Colors.teal.shade50,
                                      child: Icon(
                                        Icons.person_outline,
                                        color: isPending ? Colors.orange : Colors.teal,
                                      ),
                                    ),
                                    title: Text(
                                      email,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isPending ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: isPending ? Colors.orange.withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.4),
                                                ),
                                              ),
                                              child: Text(
                                                status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: isPending ? Colors.orange : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Shared Devices: ${wDevices.isEmpty ? 'None' : wDevices.join(', ')}',
                                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.teal, size: 20),
                                          onPressed: () => _showEditSharedDevicesDialog(worker),
                                          tooltip: 'Edit Shared Devices',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent, size: 20),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Revoke Access'),
                                                content: Text('Revoke device access for $email?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _revokeAccess(email);
                                                    },
                                                    child: const Text('Revoke', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          tooltip: 'Revoke Access',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.teal)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final isSharedUser = _user['isSharedUser'] == true;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isSharedUser ? Colors.teal.shade50 : Colors.teal,
                  child: Icon(
                    isSharedUser ? Icons.people_outline : Icons.person,
                    size: 32,
                    color: isSharedUser ? Colors.teal : Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user['name'] ?? 'N/A',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSharedUser ? Colors.orange.withValues(alpha: 0.1) : Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSharedUser ? Colors.orange.withValues(alpha: 0.5) : Colors.teal.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          isSharedUser ? 'SHARED WORKER' : 'CLIENT / OWNER',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSharedUser ? Colors.orange : Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30, color: Color(0xFFF1F1F1)),
            Row(
              children: [
                Icon(Icons.email, color: Colors.teal.withValues(alpha: 0.6), size: 18),
                const SizedBox(width: 12),
                Text(_user['email'] ?? 'N/A', style: const TextStyle(color: Colors.black54, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.teal.withValues(alpha: 0.6), size: 18),
                const SizedBox(width: 12),
                Text(_user['phone'] ?? 'N/A', style: const TextStyle(color: Colors.black54, fontSize: 14)),
              ],
            ),
            if (isSharedUser && _user['mainUserEmail'] != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.link, color: Colors.teal.withValues(alpha: 0.6), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Managed by: ${_user['mainUserEmail']}',
                      style: const TextStyle(color: Colors.black54, fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String deviceId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.developer_board, color: Colors.teal),
        ),
        title: Text(
          deviceId,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.teal, size: 22),
              onPressed: () => _showDeviceSettingsDialog(deviceId),
              tooltip: 'Device Settings',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
              onPressed: () => _showRemoveDeviceConfirmation(deviceId),
              tooltip: 'Remove Device',
            ),
          ],
        ),
      ),
    );
  }
}
