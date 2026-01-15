import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/dashboard_api_service.dart';
import '../../data/models/dashboard_stats.dart';
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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handle401Error() {
    apiService.clearToken();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withOpacity(0.7),
              tabs: const [
                Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
                Tab(text: 'Pending Users', icon: Icon(Icons.pending)),
                Tab(text: 'Host Requests', icon: Icon(Icons.home_work)),
                Tab(text: 'Host Users', icon: Icon(Icons.business)),
                Tab(text: 'Tenant Users', icon: Icon(Icons.people)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StatisticsTab(on401Error: _handle401Error),
                UsersManagementTab(
                  on401Error: _handle401Error,
                  onShowUserDialog: _showUserDialog,
                ),
                HostRequestsTab(
                  on401Error: _handle401Error,
                  onShowUserDialog: _showUserDialog,
                ),
                HostUsersTab(
                  on401Error: _handle401Error,
                  onShowUserDialog: _showUserDialog,
                ),
                TenantUsersTab(
                  on401Error: _handle401Error,
                  onShowUserDialog: _showUserDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    apiService.clearToken();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _showUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with avatar and name
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.profileImage.isNotEmpty
                            ? NetworkImage(
                                AssetUtil.getProfile(user.profileImage),
                              )
                            : null,
                        child: user.profileImage.isEmpty
                            ? Text(
                                user.firstName.isNotEmpty
                                    ? user.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // User details
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('ID', user.id.toString()),
                      const SizedBox(height: 12),
                      _buildDetailRow('Phone', user.phoneNumber),
                      const SizedBox(height: 12),
                      _buildDetailRow('Date of Birth', user.dateOfBirth),

                      // ID Image section
                      if (user.idImage.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'ID Document',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                AssetUtil.getAssetUrl(user.idImage),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// StatisticsTab
class StatisticsTab extends ConsumerStatefulWidget {
  final VoidCallback on401Error;

  const StatisticsTab({super.key, required this.on401Error});

  @override
  ConsumerState<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends ConsumerState<StatisticsTab> {
  late Future<DashboardStats> _statsFuture;
  final apiService = DashboardApiService();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _fetchStats();
    });
  }

  Future<DashboardStats> _fetchStats() async {
    try {
      final response = await apiService.getDashboardStats();
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      if (e.toString().contains('401')) {
        widget.on401Error();
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadStats,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async => _loadStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      context,
                      'Total Users',
                      stats.totalUsers.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'Total Orders',
                      stats.totalOrders.toString(),
                      Icons.shopping_cart,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Pending Orders',
                      stats.pendingOrders.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'Approved Orders',
                      stats.approvedOrders.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Rejected Orders',
                      stats.rejectedOrders.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Order Status Distribution',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProgressBar(
                        context,
                        'Approved',
                        stats.approvedOrders,
                        stats.totalOrders,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildProgressBar(
                        context,
                        'Pending',
                        stats.pendingOrders,
                        stats.totalOrders,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildProgressBar(
                        context,
                        'Rejected',
                        stats.rejectedOrders,
                        stats.totalOrders,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${value} (${percentage.toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: total > 0 ? value / total : 0,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

// UsersManagementTab
class UsersManagementTab extends ConsumerStatefulWidget {
  final VoidCallback on401Error;
  final Function(BuildContext, User) onShowUserDialog;

  const UsersManagementTab({
    super.key,
    required this.on401Error,
    required this.onShowUserDialog,
  });

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
      if (e.toString().contains('401')) {
        widget.on401Error();
      }
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
      if (e.toString().contains('401')) {
        widget.on401Error();
      } else if (mounted) {
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
      if (e.toString().contains('401')) {
        widget.on401Error();
      } else if (mounted) {
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
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
          return RefreshIndicator(
            onRefresh: () async => _loadUsers(),
            child: ListView(
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.pending, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No pending users'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return InkWell(
                onTap: () => widget.onShowUserDialog(context, user),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.profileImage.isNotEmpty
                              ? NetworkImage(
                                  AssetUtil.getProfile(user.profileImage),
                                )
                              : null,
                          child: user.profileImage.isEmpty
                              ? Text(
                                  user.firstName.isNotEmpty
                                      ? user.firstName[0].toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Phone: ${user.phoneNumber}'),
                              Text('DOB: ${user.dateOfBirth}'),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
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
          ),
        );
      },
    );
  }
}

// HostRequestsTab
class HostRequestsTab extends ConsumerStatefulWidget {
  final VoidCallback on401Error;
  final Function(BuildContext, User) onShowUserDialog;

  const HostRequestsTab({
    super.key,
    required this.on401Error,
    required this.onShowUserDialog,
  });

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
      return (data ?? [])
          .map((r) => User.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e.toString().contains('401')) {
        widget.on401Error();
      }
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
      if (e.toString().contains('401')) {
        widget.on401Error();
      } else if (mounted) {
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
      if (e.toString().contains('401')) {
        widget.on401Error();
      } else if (mounted) {
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
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
          return RefreshIndicator(
            onRefresh: () async => _loadRequests(),
            child: ListView(
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.home_work, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No host requests'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return InkWell(
                onTap: () => widget.onShowUserDialog(context, request),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: request.profileImage.isNotEmpty
                              ? NetworkImage(
                                  AssetUtil.getProfile(request.profileImage),
                                )
                              : null,
                          child: request.profileImage.isEmpty
                              ? Text(
                                  request.firstName.isNotEmpty
                                      ? request.firstName[0].toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.fullName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Phone: ${request.phoneNumber}'),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
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
          ),
        );
      },
    );
  }
}

// HostUsersTab
class HostUsersTab extends ConsumerStatefulWidget {
  final VoidCallback on401Error;
  final Function(BuildContext, User) onShowUserDialog;

  const HostUsersTab({
    super.key,
    required this.on401Error,
    required this.onShowUserDialog,
  });

  @override
  ConsumerState<HostUsersTab> createState() => _HostUsersTabState();
}

class _HostUsersTabState extends ConsumerState<HostUsersTab> {
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
      final response = await apiService.getHosts();
      final data = response.data['users'] as List?;
      return (data ?? [])
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e.toString().contains('401')) {
        widget.on401Error();
      }
      rethrow;
    }
  }

  Future<void> _removeUser(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text(
          'Are you sure you want to remove $userName? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.removeUser(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User removed successfully')),
          );
        }
      } catch (e) {
        if (e.toString().contains('401')) {
          widget.on401Error();
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error removing user: $e')));
        }
      } finally {
        // Always refresh the list
        _loadUsers();
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
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
          return RefreshIndicator(
            onRefresh: () async => _loadUsers(),
            child: ListView(
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.business, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No host users found'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return InkWell(
                onTap: () => widget.onShowUserDialog(context, user),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.profileImage.isNotEmpty
                              ? NetworkImage(
                                  AssetUtil.getProfile(user.profileImage),
                                )
                              : null,
                          child: user.profileImage.isEmpty
                              ? Text(
                                  user.firstName.isNotEmpty
                                      ? user.firstName[0].toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Phone: ${user.phoneNumber}'),
                              Text('Joined: ${user.dateOfBirth}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeUser(user.id, user.fullName),
                          tooltip: 'Remove User',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// TenantUsersTab
class TenantUsersTab extends ConsumerStatefulWidget {
  final VoidCallback on401Error;
  final Function(BuildContext, User) onShowUserDialog;

  const TenantUsersTab({
    super.key,
    required this.on401Error,
    required this.onShowUserDialog,
  });

  @override
  ConsumerState<TenantUsersTab> createState() => _TenantUsersTabState();
}

class _TenantUsersTabState extends ConsumerState<TenantUsersTab> {
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
      final response = await apiService.getTenants();
      final data = response.data['users'] as List?;
      return (data ?? [])
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e.toString().contains('401')) {
        widget.on401Error();
      }
      rethrow;
    }
  }

  Future<void> _removeUser(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text(
          'Are you sure you want to remove $userName? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.removeUser(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User removed successfully')),
          );
        }
      } catch (e) {
        if (e.toString().contains('401')) {
          widget.on401Error();
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error removing user: $e')));
        }
      } finally {
        // Always refresh the list
        _loadUsers();
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
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
          return RefreshIndicator(
            onRefresh: () async => _loadUsers(),
            child: ListView(
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.people, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No tenant users found'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return InkWell(
                onTap: () => widget.onShowUserDialog(context, user),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.profileImage.isNotEmpty
                              ? NetworkImage(
                                  AssetUtil.getProfile(user.profileImage),
                                )
                              : null,
                          child: user.profileImage.isEmpty
                              ? Text(
                                  user.firstName.isNotEmpty
                                      ? user.firstName[0].toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Phone: ${user.phoneNumber}'),
                              Text('Joined: ${user.dateOfBirth}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeUser(user.id, user.fullName),
                          tooltip: 'Remove User',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
