class AppConstants {
  static const String appName = 'VidyuSaathi';
  static const String organizationName = 'Mahavitran';
  
  // Roles
  static const String roleCitizen = 'CITIZEN';
  static const String roleOfficer = 'OFFICER';
  static const String roleAdmin = 'ADMIN';

  // Officer Designations
  static const String desFieldEngineer = 'Field Engineer';
  static const String desJE = 'JE';
  static const String desAE = 'AE';
  static const String desDYEE = 'DYEE';
  static const String desEE = 'EE';
  static const String desSE = 'SE';
  static const String desCE = 'CE';

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
