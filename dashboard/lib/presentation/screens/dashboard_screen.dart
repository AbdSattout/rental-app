import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/dashboard_api_service.dart';
import '../../data/models/user.dart';
import '../../utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final apiService = DashboardApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Users', icon: Icon(Icons.people)),
              Tab(text: 'Host Requests', icon: Icon(Icons.home)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [UsersManagementTab(), HostRequestsTab()],
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed('/');
  }
}

class UsersManagementTab extends ConsumerStatefulWidget {
  const UsersManagementTab({super.key});

  @override
  ConsumerState<UsersManagementTab> createState() => _UsersManagementTabState();
}

class _UsersManagementTabState extends ConsumerState<UsersManagementTab> {
  late Future<List<User>> _usersFuture;
  final apiService = DashboardApiService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  Future<List<User>> _fetchUsers() async {
    try {
      final response = await apiService.getPendingUsers();
      final data = response.data['users'] as List?;
      return (data ?? [])
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _approveUser(int userId) async {
    try {
      await apiService.approveUser(userId);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User approved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _rejectUser(int userId) async {
    try {
      await apiService.rejectUser(userId);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User rejected')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUsers,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No pending users'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return InkWell(
              onTap: () => _showUserDialog(context, user),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: user.profileImage.isNotEmpty
                            ? NetworkImage(
                                    AssetUtil.getProfile(user.profileImage),
                                  )
                                  as ImageProvider
                            : null,
                        child: user.profileImage.isEmpty
                            ? Text(
                                user.firstName.isNotEmpty
                                    ? user.firstName[0].toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text('Phone: ${user.phoneNumber}'),
                            const SizedBox(height: 4),
                            Text('DOB: ${user.dateOfBirth}'),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveUser(user.id),
                            tooltip: 'Approve',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectUser(user.id),
                            tooltip: 'Reject',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void _showUserDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.profileImage.isNotEmpty) ...[
                Image.network(
                  AssetUtil.getProfile(user.profileImage),
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${user.phoneNumber}'),
                    Text('DOB: ${user.dateOfBirth}'),
                    Text('ID: ${user.id}'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (user.idImage.isNotEmpty) ...[
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ID Image',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Image.network(AssetUtil.getAssetUrl(user.idImage)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class HostRequestsTab extends ConsumerStatefulWidget {
  const HostRequestsTab({super.key});

  @override
  ConsumerState<HostRequestsTab> createState() => _HostRequestsTabState();
}

class _HostRequestsTabState extends ConsumerState<HostRequestsTab> {
  late Future<List<User>> _requestsFuture;
  final apiService = DashboardApiService();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _requestsFuture = _fetchRequests();
    });
  }

  Future<List<User>> _fetchRequests() async {
    try {
      final response = await apiService.getHostRequests();
      final data = response.data['users'] as List?;
      // print(data);
      return (data ?? [])
          .map((r) => User.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _approveRequest(int userId) async {
    try {
      await apiService.approveHostRequest(userId);
      _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Host request approved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _rejectRequest(int userId) async {
    try {
      await apiService.rejectHostRequest(userId);
      _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Host request rejected')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRequests,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(child: Text('No host requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return InkWell(
              onTap: () => _showUserDialog(context, request),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: request.profileImage.isNotEmpty
                            ? NetworkImage(
                                    AssetUtil.getProfile(request.profileImage),
                                  )
                                  as ImageProvider
                            : null,
                        child: request.profileImage.isEmpty
                            ? Text(
                                request.firstName.isNotEmpty
                                    ? request.firstName[0].toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.fullName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text('Phone: ${request.phoneNumber}'),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveRequest(request.id),
                            tooltip: 'Approve',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectRequest(request.id),
                            tooltip: 'Reject',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
