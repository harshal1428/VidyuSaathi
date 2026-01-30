/// Application-wide constants for Mahavitran VidyuSaathi
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  static const String appName = 'VidyuSaathi';
  static const String organizationName = 'Mahavitran';

  // Roles
  static const String roleCitizen = 'CITIZEN';
  static const String roleOfficer = 'OFFICER';
  static const String roleAdmin = 'ADMIN';

  // Officer Designations (Hierarchy: CE -> SE -> EE/DyEE -> AE/JE/FE)
  static const String desFE = 'FE'; // Field Officer
  static const String desJE = 'JE';
  static const String desAE = 'AE';
  static const String desDYEE = 'DYEE';
  static const String desEE = 'EE';
  static const String desSE = 'SE';
  static const String desCE = 'CE';

  static const List<String> officerDesignations = [
    desFE,
    desJE,
    desAE,
    desDYEE,
    desEE,
    desSE,
    desCE,
  ];

  // Ticket Statuses
  static const String statusCreated = 'Created';
  static const String statusAssigned = 'Assigned';
  static const String statusAcknowledged = 'Acknowledged';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusSupervisorReview = 'Supervisor Review';
  static const String statusResolved = 'Resolved';
  static const String statusClosed = 'Closed';
  static const String statusRejected = 'Rejected'; // Soft delete with reason

  // Ticket Categories
  static const List<String> ticketCategories = [
    'Power Failure',
    'Voltage Fluctuation',
    'Meter Issue',
    'Billing Issue',
    'New Connection',
    'Street Light',
    'Other',
  ];

  // Route Names
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeSeeder = '/seeder';
  static const String routeCitizenDashboard = '/citizen_dashboard';
  static const String routeCitizenProfile = '/citizen_profile';
  static const String routeReportIssue = '/report_issue';
  static const String routeMyReports = '/my_reports';
  static const String routeOfficerDashboard = '/officer_dashboard';
  static const String routeAdminDashboard = '/admin_dashboard';
}
