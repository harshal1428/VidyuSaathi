class AppConstants {
  static const String appName = 'NagarSetu';
  static const String organizationName = 'Pune Municipal Corporation';
  
  // Roles
  static const String roleCitizen = 'CITIZEN';
  static const String roleOfficer = 'OFFICER';
  static const String roleAdmin = 'ADMIN';

  // Officer Designations
  static const String desFieldEngineer = 'Field Engineer (FE)';
  static const String desJE = 'Junior Engineer (JE)';
  static const String desAE = 'Assistant Engineer (AE)';
  static const String desDYEE = 'Deputy Executive Engineer (DYEE)';
  static const String desEE = 'Executive Engineer (EE)';
  static const String desSE = 'Superintending Engineer (SE)';
  static const String desCE = 'Chief Engineer (CE)';

  static const List<String> officerDesignations = [
    desFieldEngineer,
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
  
  // Routes
  static const String routeLogin = '/';
  static const String routeAdminDashboard = '/admin_dashboard';
  static const String routeOfficerDashboard = '/officer_dashboard';
  static const String routeCitizenDashboard = '/citizen_dashboard';

  // Ticket Categories (Example)
  static const List<String> ticketCategories = [
    'Power Failure',
    'Voltage Fluctuation',
    'Meter Issue',
    'Billing Issue',
    'New Connection',
    'Street Light',
    'Other',
  ];
}


