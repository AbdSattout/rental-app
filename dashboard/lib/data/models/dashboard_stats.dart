class DashboardStats {
  final int totalUsers;
  final int totalOrders;
  final int pendingOrders;
  final int approvedOrders;
  final int rejectedOrders;

  const DashboardStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.pendingOrders,
    required this.approvedOrders,
    required this.rejectedOrders,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DashboardStats(
      totalUsers: data['total_users'] ?? 0,
      totalOrders: data['total_orders'] ?? 0,
      pendingOrders: data['pending_orders'] ?? 0,
      approvedOrders: data['approved_orders'] ?? 0,
      rejectedOrders: data['rejected_orders'] ?? 0,
    );
  }
}
