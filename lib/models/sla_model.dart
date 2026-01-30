class SlaConfig {
  final String priorityLevel;
  final String label;
  final int slaHours;
  final String escalationSequence;

  SlaConfig({
    required this.priorityLevel,
    required this.label,
    required this.slaHours,
    required this.escalationSequence,
  });

  Map<String, dynamic> toMap() => {
    'priorityLevel': priorityLevel,
    'label': label,
    'slaHours': slaHours,
    'escalationSequence': escalationSequence,
  };
}


