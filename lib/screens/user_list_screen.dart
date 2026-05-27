import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'add_user_screen.dart';
import 'user_details_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/users'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _users = json.decode(response.body);
          _filteredUsers = _users;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _users;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final devices = user['assignedDevices'] as List<dynamic>? ?? [];
        final deviceMatch = devices.any((d) => d.toString().toLowerCase().contains(lowercaseQuery));
        
        return name.contains(lowercaseQuery) || email.contains(lowercaseQuery) || deviceMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 28, errorBuilder: (c, e, s) => const Icon(Icons.waves, color: Colors.teal)),
            const SizedBox(width: 12),
            const Text(
              'Smart Synergies Admin',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.teal),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddUserScreen()),
              );
              if (result == true) {
                _fetchUsers();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : _filteredUsers.isEmpty
                      ? const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchUsers,
                          color: Colors.teal,
                          child: ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              return _buildUserCard(_filteredUsers[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search Users or Device IDs...',
        prefixIcon: const Icon(Icons.search, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onChanged: _filterUsers,
    );
  }

  Widget _buildUserCard(dynamic user) {
    final name = user['name'] ?? 'Unknown';
    final devices = user['assignedDevices'] as List<dynamic>? ?? [];
    final deviceId = devices.isNotEmpty ? devices.first : 'No Device';
    final isSharedUser = user['isSharedUser'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isSharedUser ? Colors.teal.shade50 : Colors.teal,
          child: Icon(
            isSharedUser ? Icons.people_outline : Icons.person,
            color: isSharedUser ? Colors.teal : Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(width: 8),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Device ID: $deviceId',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (user['sharedWith'] != null && (user['sharedWith'] as List).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${(user['sharedWith'] as List).length} Shared Access Granted',
                style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
              ),
            ]
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => UserDetailsScreen(user: user),
            ),
          );
          _fetchUsers(); // Refresh when coming back
        },
      ),
    );
  }
}
