class DashboardStats {
  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
  final int escalated;
  final int critical;
  final int high;
  final int medium;
  final int low;

  DashboardStats({
    this.total = 0,
    this.pending = 0,
    this.inProgress = 0,
    this.resolved = 0,
    this.escalated = 0,
    this.critical = 0,
    this.high = 0,
    this.medium = 0,
    this.low = 0,
  });
}
