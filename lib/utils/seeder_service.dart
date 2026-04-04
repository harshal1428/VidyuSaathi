import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/structure_models.dart';
import '../models/complaint_type_model.dart';
import '../models/department_model.dart';
import '../core/constants.dart';

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> performSafetyCheckAndSeed(BuildContext context) async {
    final docs = await _firestore.collection('DEPARTMENTS').limit(5).get();
    if (docs.docs.length >= 5) {
      if (!context.mounted) return;
      bool? wipe = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Data already seeded. Wipe and re-seed?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
          ]
        )
      );
      if (wipe != true) return;

      print("Wiping existing seeded data...");
      var depts = await _firestore.collection('DEPARTMENTS').get();
      for (var doc in depts.docs) { await doc.reference.delete(); }

      var cTypes = await _firestore.collection('COMPLAINT_TYPES').get();
      for (var doc in cTypes.docs) { await doc.reference.delete(); }
      
      var usersQuery = await _firestore.collection('USERS').where('employeeId', isGreaterThan: '').get();
      final batch = _firestore.batch();
      for (var doc in usersQuery.docs) {
        batch.delete(doc.reference);
      }
      // Since some seeded records might not be caught by isGreaterThan if they are missing entirely, let's also delete all from structured tables
      await batch.commit();
      
      for (String col in ['DIVISIONS', 'CIRCLES', 'REGIONS', 'OFFICES']) {
         var cdocs = await _firestore.collection(col).get();
         final cb = _firestore.batch();
         for(var d in cdocs.docs) cb.delete(d.reference);
         await cb.commit();
      }
    }

    await seedHierarchicalData();
    await seedComplaintTypes();
    
    print('''✅ CivicCore Seeder Complete:
 - 5 Departments
 - 10 Circles (2 per dept)
 - 20 Regions (4 per dept)
 - 40 Offices (8 per dept)
 - 175 Officers (35 per dept)
 - 61 Complaint Types''');
  }

  Future<void> seedHierarchicalData() async {
    print("Starting Hierarchical Data Seeding (5 Departments)...");

    final List<Map<String, dynamic>> regionsGeo = [
      {'idPrefix': 'shivajinagar', 'name': 'Shivajinagar Region', 'circle': 'urban'},
      {'idPrefix': 'swargate', 'name': 'Swargate Region', 'circle': 'urban'},
      {'idPrefix': 'hinjewadi', 'name': 'Hinjewadi Region', 'circle': 'rural'},
      {'idPrefix': 'baramati', 'name': 'Baramati Region', 'circle': 'rural'},
    ];

     final List<Map<String, dynamic>> officesGeo = [
       {'idPrefix': 'shivajinagar', 'name': 'Shivajinagar Division Office', 'lat': 18.5308, 'lng': 73.8474, 'region': 'shivajinagar', 'radius': 5},
       {'idPrefix': 'aundh', 'name': 'Aundh Division Office', 'lat': 18.5590, 'lng': 73.8077, 'region': 'shivajinagar', 'radius': 5},
       {'idPrefix': 'swgt', 'name': 'Swargate Division Office', 'lat': 18.5018, 'lng': 73.8636, 'region': 'swargate', 'radius': 5},
       {'idPrefix': 'katraj', 'name': 'Katraj Division Office', 'lat': 18.4529, 'lng': 73.8567, 'region': 'swargate', 'radius': 5},
       {'idPrefix': 'hinjewadi', 'name': 'Hinjewadi Division Office', 'lat': 18.5912, 'lng': 73.7389, 'region': 'hinjewadi', 'radius': 7},
       {'idPrefix': 'pirangut', 'name': 'Pirangut Division Office', 'lat': 18.5284, 'lng': 73.6710, 'region': 'hinjewadi', 'radius': 8},
       {'idPrefix': 'baramati', 'name': 'Baramati Division Office', 'lat': 18.1528, 'lng': 74.5826, 'region': 'baramati', 'radius': 10},
       {'idPrefix': 'indapur', 'name': 'Indapur Division Office', 'lat': 18.1147, 'lng': 75.0139, 'region': 'baramati', 'radius': 12},
    ];

    final List<Map<String, dynamic>> departments = [
      {
        'id': 'dept_electricity', 'name': 'Electricity (MSEDCL)', 'shortName': 'MSEDCL', 
        'categories': ['Streetlight', 'Safety'], 
        'slaConfig': {'Critical': 2, 'High': 12, 'Medium': 48, 'Low': 120},
        'prefix': 11000000,
        'hier': [
          {'level': 1, 'role': 'lineman', 'title': 'Lineman / Wireman'},
          {'level': 2, 'role': 'je_elec', 'title': 'Junior Engineer (JE)'},
          {'level': 3, 'role': 'ae_elec', 'title': 'Assistant Engineer (AE)'},
          {'level': 4, 'role': 'dee_elec', 'title': 'Deputy Executive Engineer (DEE)'},
          {'level': 5, 'role': 'ee_elec', 'title': 'Executive Engineer (EE)'},
          {'level': 6, 'role': 'se_elec', 'title': 'Superintending Engineer (SE)'},
          {'level': 7, 'role': 'ce_elec', 'title': 'Chief Engineer (CE)'},
        ]
      },
      {
        'id': 'dept_garbage', 'name': 'Garbage & Sanitation (PMC)', 'shortName': 'PMC-GBG',
        'categories': ['Garbage', 'Encroachment', 'Infrastructure', 'Animals', 'Governance'],
        'slaConfig': {'Critical': 4, 'High': 12, 'Medium': 48, 'Low': 120},
        'prefix': 22000000,
        'hier': [
          {'level': 1, 'role': 'sanitation_worker', 'title': 'Sanitation Worker'},
          {'level': 2, 'role': 'mukadam', 'title': 'Mukadam / Supervisor'},
          {'level': 3, 'role': 'sanitary_inspector', 'title': 'Sanitary Inspector'},
          {'level': 4, 'role': 'ward_officer', 'title': 'Ward Officer'},
          {'level': 5, 'role': 'amc_gbg', 'title': 'Assistant Municipal Commissioner (AMC)'},
          {'level': 6, 'role': 'dmc_gbg', 'title': 'Deputy Municipal Commissioner (DMC)'},
          {'level': 7, 'role': 'commissioner_gbg', 'title': 'Additional / Municipal Commissioner'},
        ]
      },
      {
        'id': 'dept_water', 'name': 'Water Supply (PMC Water)', 'shortName': 'PMC-WTR',
        'categories': ['Water', 'Drainage'],
        'slaConfig': {'Critical': 1, 'High': 6, 'Medium': 24, 'Low': 72},
        'prefix': 33000000,
        'hier': [
          {'level': 1, 'role': 'plumber', 'title': 'Plumber / Valve Operator'},
          {'level': 2, 'role': 'je_water', 'title': 'Junior Engineer (Water)'},
          {'level': 3, 'role': 'ae_water', 'title': 'Assistant Engineer (Water)'},
          {'level': 4, 'role': 'sde_water', 'title': 'Sub Divisional Engineer (SDE)'},
          {'level': 5, 'role': 'ee_water', 'title': 'Executive Engineer (Water)'},
          {'level': 6, 'role': 'se_water', 'title': 'Superintending Engineer (Water)'},
          {'level': 7, 'role': 'ce_water', 'title': 'Chief Engineer (Water)'},
        ]
      },
      {
        'id': 'dept_roads', 'name': 'Roads & PWD (PMC Roads)', 'shortName': 'PMC-PWD',
        'categories': ['Roads'],
        'slaConfig': {'Critical': 4, 'High': 24, 'Medium': 72, 'Low': 168},
        'prefix': 44000000,
        'hier': [
          {'level': 1, 'role': 'road_worker', 'title': 'Road Maintenance Worker'},
          {'level': 2, 'role': 'je_roads', 'title': 'Junior Engineer (Roads)'},
          {'level': 3, 'role': 'ae_roads', 'title': 'Assistant Engineer (Roads)'},
          {'level': 4, 'role': 'sde_roads', 'title': 'Sub Divisional Engineer (SDE)'},
          {'level': 5, 'role': 'ee_roads', 'title': 'Executive Engineer (Roads)'},
          {'level': 6, 'role': 'se_roads', 'title': 'Superintending Engineer (Roads)'},
          {'level': 7, 'role': 'ce_roads', 'title': 'Chief Engineer (Roads/PWD)'},
        ]
      },
      {
        'id': 'dept_health', 'name': 'Health Department (PMC Health)', 'shortName': 'PMC-HLT',
        'categories': ['Health', 'Epidemic', 'Sanitation_Health'],
        'slaConfig': {'Critical': 1, 'High': 6, 'Medium': 24, 'Low': 72},
        'prefix': 55000000,
        'hier': [
          {'level': 1, 'role': 'health_worker', 'title': 'ANM / Staff Nurse / Health Worker'},
          {'level': 2, 'role': 'mo', 'title': 'Medical Officer (MO)'},
          {'level': 3, 'role': 'smo', 'title': 'Senior Medical Officer'},
          {'level': 4, 'role': 'ho_ward', 'title': 'Health Officer (Ward Level)'},
          {'level': 5, 'role': 'amoh', 'title': 'Assistant Medical Officer of Health (AMOH)'},
          {'level': 6, 'role': 'dmoh', 'title': 'Deputy Medical Officer of Health (DMOH)'},
          {'level': 7, 'role': 'moh', 'title': 'Medical Officer of Health (MOH)'},
        ]
      }
    ];

    for (var dept in departments) {
      DepartmentModel dModel = DepartmentModel(
         id: dept['id'],
         name: dept['name'],
         shortName: dept['shortName'],
         categories: List<String>.from(dept['categories']),
         hierarchy: List<Map<String, dynamic>>.from(dept['hier']),
         slaConfig: Map<String, int>.from(dept['slaConfig']),
      );
      await _firestore.collection('DEPARTMENTS').doc(dModel.id).set(dModel.toMap());

      int _empCounter = 1;

      String divId = "div_pune_${dept['id']}";
      await _firestore.collection('DIVISIONS').doc(divId).set({
        'divisionId': divId, 'name': "Pune Zone - ${dept['name']}", 'departmentId': dept['id']
      });

      final l7 = dept['hier'].firstWhere((h) => h['level'] == 7);
      await _seedOfficer(
        empId: (dept['prefix'] + _empCounter++).toString(),
        dept: dept,
        hier: l7,
        officeName: "Pune Zone",
        divisionId: divId,
        emailTag: 'pune',
      );

      for (String circleType in ['urban', 'rural']) {
        String circleId = "circle_${circleType}_${dept['id']}";
        String circleName = circleType == 'urban' ? "Pune Urban Circle - ${dept['shortName']}" : "Pune Rural Circle - ${dept['shortName']}";
        await _firestore.collection('CIRCLES').doc(circleId).set({
          'circleId': circleId, 'divisionId': divId, 'name': circleName, 'departmentId': dept['id']
        });

        final l6 = dept['hier'].firstWhere((h) => h['level'] == 6);
        await _seedOfficer(
          empId: (dept['prefix'] + _empCounter++).toString(),
          dept: dept,
          hier: l6,
          officeName: circleName,
          divisionId: divId,
          circleId: circleId,
          emailTag: circleType == 'urban' ? 'urbn' : 'rural',
        );

        var circleRegions = regionsGeo.where((r) => r['circle'] == circleType).toList();
        for (var reg in circleRegions) {
          String regionId = "region_${reg['idPrefix']}_${dept['id']}";
          await _firestore.collection('REGIONS').doc(regionId).set({
            'regionId': regionId, 'circleId': circleId, 'divisionId': divId, 'name': reg['name'], 'departmentId': dept['id']
          });

          final l5 = dept['hier'].firstWhere((h) => h['level'] == 5);
          final l4 = dept['hier'].firstWhere((h) => h['level'] == 4);
          await _seedOfficer(
            empId: (dept['prefix'] + _empCounter++).toString(),
            dept: dept,
            hier: l5,
            officeName: reg['name'],
            divisionId: divId,
            circleId: circleId,
            regionId: regionId,
            emailTag: reg['idPrefix'] == 'swargate' ? 'swgt' : reg['idPrefix'],
          );
          await _seedOfficer(
            empId: (dept['prefix'] + _empCounter++).toString(),
            dept: dept,
            hier: l4,
            officeName: reg['name'],
            divisionId: divId,
            circleId: circleId,
            regionId: regionId,
            emailTag: reg['idPrefix'] == 'swargate' ? 'swgt' : reg['idPrefix'],
          );

          var regOffices = officesGeo.where((o) => o['region'] == reg['idPrefix']).toList();
          for (var off in regOffices) {
             String offId = "off_${off['idPrefix']}_${dept['id']}";
             await _firestore.collection('OFFICES').doc(offId).set({
                'officeId': offId, 'regionId': regionId, 'name': off['name'],
                'latitude': off['lat'], 'longitude': off['lng'], 'radiusKm': off['radius'], 'departmentId': dept['id']
             });

             final l3 = dept['hier'].firstWhere((h) => h['level'] == 3);
             final l2 = dept['hier'].firstWhere((h) => h['level'] == 2);
             final l1 = dept['hier'].firstWhere((h) => h['level'] == 1);
             final isSwargate = off['idPrefix'] == 'swgt';
             final officeTag = isSwargate ? 'swgt' : off['idPrefix'];
             await _seedOfficer(
               empId: (dept['prefix'] + _empCounter++).toString(),
               dept: dept,
               hier: l3,
               officeName: off['name'],
               divisionId: divId,
               circleId: circleId,
               regionId: regionId,
               officeId: offId,
               officePrefix: officeTag,
               emailTag: officeTag,
             );
             await _seedOfficer(
               empId: (dept['prefix'] + _empCounter++).toString(),
               dept: dept,
               hier: l2,
               officeName: off['name'],
               divisionId: divId,
               circleId: circleId,
               regionId: regionId,
               officeId: offId,
               officePrefix: officeTag,
               emailTag: officeTag,
             );
             await _seedOfficer(
               empId: (dept['prefix'] + _empCounter++).toString(),
               dept: dept,
               hier: l1,
               officeName: off['name'],
               divisionId: divId,
               circleId: circleId,
               regionId: regionId,
               officeId: offId,
               officePrefix: officeTag,
               emailTag: officeTag,
             );
          }
        }
      }
    }
    print("Seeding Hierarchies Complete.");
  }

  static final List<String> _firstNames = [
    'Sanjay', 'Milind', 'Pravin', 'Sachin', 'Rohit', 'Amol', 'Kunal',
    'Anil', 'Vijay', 'Rohan', 'Mahesh', 'Suresh', 'Rahul', 'Amit',
    'Nilesh', 'Dilip', 'Santosh', 'Umesh', 'Prakash', 'Sunil', 'Rajesh',
    'Smita', 'Priya', 'Sneha', 'Anita', 'Kavita', 'Pooja', 'Sheetal',
    'Ganesh', 'Yogesh', 'Tushar', 'Deepak', 'Sandeep', 'Swapnil', 'Ajay',
    'Akshay', 'Prashant', 'Neha', 'Sonali', 'Pallavi', 'Rupali', 'Sayali',
    'Pratik', 'Tejas', 'Ravi', 'Kiran', 'Vishal', 'Nitin', 'Manoj'
  ];

  static final List<String> _lastNames = [
    'Patil', 'Deshmukh', 'Kulkarni', 'Joshi', 'Bhosale', 'Jadhav',
    'Desai', 'Phadke', 'Chavan', 'Pawar', 'Gokhale', 'More', 'Kadam',
    'Shinde', 'Gaikwad', 'Kamble', 'Kale', 'Mane', 'Wagh', 'Thakare',
    'Raut', 'Chaudhari', 'Sutar', 'Naik', 'Satpute', 'Shirke', 'Surve',
    'Kharat', 'Sawant', 'Sable', 'Bapat', 'Ranade', 'Godbole', 'Kelkar',
    'Mundhe', 'Dhumal', 'Kakade', 'Magar', 'Mahadik', 'Pimpale'
  ];

  String _getRandomName() {
    final rand = Random();
    String first = _firstNames[rand.nextInt(_firstNames.length)];
    String last = _lastNames[rand.nextInt(_lastNames.length)];
    return "$first $last";
  }

  Future<void> _seedOfficer({
      required String empId, 
      required Map<String, dynamic> dept, 
      required Map<String, dynamic> hier, 
      required String officeName,
      String? divisionId, String? circleId, String? regionId, String? officeId, String officePrefix = 'hq'
      , String? emailTag
  }) async {
      String name = _getRandomName();
      String shortNameLow = dept['shortName'].toString().toLowerCase().replaceAll('-', '_');
      String emailSuffix = (emailTag != null && emailTag.isNotEmpty) ? emailTag : officePrefix;
      String email = emailTag != null && emailTag.isNotEmpty
        ? "${hier['role']}_${emailSuffix.toLowerCase()}@civiccore.pune.gov.in"
        : "${hier['role']}_${officePrefix}_$shortNameLow@civiccore.pune.gov.in";
      String password = "123456";

      String uid = _firestore.collection('USERS').doc().id;
      final user = UserModel(
        userId: uid,
        name: name,
        email: email,
        phone: '9800000000',
        role: hier['role'],
        designation: hier['title'],
        divisionId: divisionId,
        circleId: circleId,
        regionId: regionId,
        officeId: officeId,
        createdAt: DateTime.now(),
        isActive: true,
      );

      Map<String, dynamic> uMap = user.toMap();
      uMap['employeeId'] = empId;
      uMap['password'] = password;
      uMap['level'] = hier['level'];
      uMap['departmentId'] = dept['id'];

      await _firestore.collection('USERS').doc(user.userId).set(uMap);
  }

  Future<void> seedComplaintTypes() async {
    print("Seeding Complaint Types with Priority...");
    final List<Map<String, dynamic>> rawData = [
      {'category':'Garbage', 'subtype':'Garbage not collected', 'priority':'High', 'slaHours':12, 'keywords':['garbage not collected'], 'synonyms':['waste not picked','trash not collected'], 'departmentId':'dept_garbage'},
      {'category':'Garbage', 'subtype':'Overflowing garbage bin', 'priority':'High', 'slaHours':8, 'keywords':['overflowing bin'], 'synonyms':['full dustbin','bin full'], 'departmentId':'dept_garbage'},
      {'category':'Garbage', 'subtype':'Garbage pile on road', 'priority':'High', 'slaHours':8, 'keywords':['garbage pile'], 'synonyms':['trash heap','waste pile'], 'departmentId':'dept_garbage'},
      {'category':'Garbage', 'subtype':'Illegal dumping', 'priority':'High', 'slaHours':6, 'keywords':['illegal dumping'], 'synonyms':['unauthorized waste'], 'departmentId':'dept_garbage'},
      {'category':'Garbage', 'subtype':'Bad smell from garbage', 'priority':'Medium', 'slaHours':24, 'keywords':['bad smell garbage'], 'synonyms':['foul smell waste'], 'departmentId':'dept_garbage'},
      {'category':'Garbage', 'subtype':'Mosquitoes due to garbage', 'priority':'High', 'slaHours':12, 'keywords':['mosquito garbage'], 'synonyms':['insects from waste'], 'departmentId':'dept_garbage'},
      {'category':'Garbage', 'subtype':'Construction waste dump', 'priority':'High', 'slaHours':12, 'keywords':['construction waste'], 'synonyms':['debris dump'], 'departmentId':'dept_garbage'},
      {'category':'Garbage', 'subtype':'Street not cleaned', 'priority':'Medium', 'slaHours':24, 'keywords':['street not cleaned'], 'synonyms':['road not swept'], 'departmentId':'dept_garbage'},
      {'category':'Water', 'subtype':'Water leakage pipe', 'priority':'High', 'slaHours':6, 'keywords':['water leakage','pipe leak'], 'synonyms':['water seeping'], 'departmentId':'dept_water'},
      {'category':'Water', 'subtype':'Pipe burst', 'priority':'Critical', 'slaHours':2, 'keywords':['pipe burst'], 'synonyms':['major leak','pipeline broken'], 'departmentId':'dept_water'},
      {'category':'Water', 'subtype':'No water supply', 'priority':'High', 'slaHours':12, 'keywords':['no water supply'], 'synonyms':['water not coming'], 'departmentId':'dept_water'},
      {'category':'Water', 'subtype':'Low water pressure', 'priority':'Medium', 'slaHours':24, 'keywords':['low pressure'], 'synonyms':['slow water flow'], 'departmentId':'dept_water'},
      {'category':'Water', 'subtype':'Contaminated water', 'priority':'Critical', 'slaHours':4, 'keywords':['dirty water'], 'synonyms':['muddy water','smelly water'], 'departmentId':'dept_water'},
      {'category':'Water', 'subtype':'Overflowing tank', 'priority':'Medium', 'slaHours':12, 'keywords':['tank overflow'], 'synonyms':['water overflow tank'], 'departmentId':'dept_water'},
      {'category':'Water', 'subtype':'Water logging', 'priority':'High', 'slaHours':6, 'keywords':['water logging'], 'synonyms':['stagnant water'], 'departmentId':'dept_water'},
      {'category':'Water', 'subtype':'Illegal water connection', 'priority':'Medium', 'slaHours':24, 'keywords':['illegal connection'], 'synonyms':['water theft'], 'departmentId':'dept_water'},
      {'category':'Roads', 'subtype':'Pothole on road', 'priority':'High', 'slaHours':12, 'keywords':['pothole'], 'synonyms':['road hole','crater'], 'departmentId':'dept_roads'},
      {'category':'Roads', 'subtype':'Multiple potholes', 'priority':'High', 'slaHours':8, 'keywords':['many potholes'], 'synonyms':['road full holes'], 'departmentId':'dept_roads'},
      {'category':'Roads', 'subtype':'Road surface broken', 'priority':'High', 'slaHours':12, 'keywords':['road broken'], 'synonyms':['damaged road'], 'departmentId':'dept_roads'},
      {'category':'Roads', 'subtype':'Road caved in', 'priority':'Critical', 'slaHours':4, 'keywords':['road collapse'], 'synonyms':['sinkhole'], 'departmentId':'dept_roads'},
      {'category':'Roads', 'subtype':'Footpath broken', 'priority':'Medium', 'slaHours':24, 'keywords':['broken footpath'], 'synonyms':['damaged walkway'], 'departmentId':'dept_roads'},
      {'category':'Roads', 'subtype':'Open manhole', 'priority':'Critical', 'slaHours':2, 'keywords':['open manhole'], 'synonyms':['manhole open'], 'departmentId':'dept_roads'},
      {'category':'Roads', 'subtype':'Road digging not restored', 'priority':'High', 'slaHours':12, 'keywords':['road digging'], 'synonyms':['construction not fixed'], 'departmentId':'dept_roads'},
      {'category':'Roads', 'subtype':'Debris on road', 'priority':'Medium', 'slaHours':24, 'keywords':['road debris'], 'synonyms':['stones on road'], 'departmentId':'dept_roads'},
      {'category':'Streetlight', 'subtype':'Streetlight not working', 'priority':'High', 'slaHours':12, 'keywords':['light not working'], 'synonyms':['streetlight off'], 'departmentId':'dept_electricity'},
      {'category':'Streetlight', 'subtype':'Multiple lights not working', 'priority':'High', 'slaHours':8, 'keywords':['many lights off'], 'synonyms':['area dark'], 'departmentId':'dept_electricity'},
      {'category':'Streetlight', 'subtype':'Flickering light', 'priority':'Medium', 'slaHours':24, 'keywords':['flickering light'], 'synonyms':['blinking light'], 'departmentId':'dept_electricity'},
      {'category':'Streetlight', 'subtype':'Dim streetlight', 'priority':'Medium', 'slaHours':24, 'keywords':['low light'], 'synonyms':['poor lighting'], 'departmentId':'dept_electricity'},
      {'category':'Streetlight', 'subtype':'Broken pole', 'priority':'Critical', 'slaHours':4, 'keywords':['broken pole'], 'synonyms':['fallen pole'], 'departmentId':'dept_electricity'},
      {'category':'Streetlight', 'subtype':'Hanging wires', 'priority':'Critical', 'slaHours':2, 'keywords':['hanging wire'], 'synonyms':['electric risk'], 'departmentId':'dept_electricity'},
      {'category':'Streetlight', 'subtype':'Loose connection', 'priority':'High', 'slaHours':8, 'keywords':['loose wire'], 'synonyms':['connection issue'], 'departmentId':'dept_electricity'},
      {'category':'Streetlight', 'subtype':'Dark area', 'priority':'High', 'slaHours':12, 'keywords':['dark street'], 'synonyms':['no lighting area'], 'departmentId':'dept_electricity'},
      {'category':'Drainage', 'subtype':'Choked drain', 'priority':'High', 'slaHours':8, 'keywords':['choked drain'], 'synonyms':['blocked drain'], 'departmentId':'dept_water'},
      {'category':'Drainage', 'subtype':'Open drain', 'priority':'High', 'slaHours':12, 'keywords':['open drain'], 'synonyms':['exposed drainage'], 'departmentId':'dept_water'},
      {'category':'Drainage', 'subtype':'Sewage overflow', 'priority':'Critical', 'slaHours':4, 'keywords':['sewage overflow'], 'synonyms':['drain overflow'], 'departmentId':'dept_water'},
      {'category':'Drainage', 'subtype':'Drain blockage due to garbage', 'priority':'High', 'slaHours':8, 'keywords':['drain blocked garbage'], 'synonyms':['garbage clog drain'], 'departmentId':'dept_water'},
      {'category':'Drainage', 'subtype':'Water stagnation', 'priority':'High', 'slaHours':6, 'keywords':['stagnant water'], 'synonyms':['water accumulation'], 'departmentId':'dept_water'},
      {'category':'Drainage', 'subtype':'Drain cover missing', 'priority':'Critical', 'slaHours':2, 'keywords':['drain cover missing'], 'synonyms':['open drain hole'], 'departmentId':'dept_water'},
      {'category':'Drainage', 'subtype':'Drain smell', 'priority':'Medium', 'slaHours':24, 'keywords':['drain smell'], 'synonyms':['bad odor drain'], 'departmentId':'dept_water'},
      {'category':'Safety', 'subtype':'Open manhole hazard', 'priority':'Critical', 'slaHours':2, 'keywords':['open manhole'], 'synonyms':['danger hole'], 'departmentId':'dept_electricity'},
      {'category':'Safety', 'subtype':'Hanging electric wire', 'priority':'Critical', 'slaHours':2, 'keywords':['hanging wire'], 'synonyms':['electric risk'], 'departmentId':'dept_electricity'},
      {'category':'Safety', 'subtype':'Construction hazard', 'priority':'Critical', 'slaHours':4, 'keywords':['construction unsafe'], 'synonyms':['no barricade'], 'departmentId':'dept_electricity'},
      {'category':'Safety', 'subtype':'Exposed cables', 'priority':'Critical', 'slaHours':2, 'keywords':['exposed wire'], 'synonyms':['electric cable open'], 'departmentId':'dept_electricity'},
      {'category':'Safety', 'subtype':'Fire hazard', 'priority':'Critical', 'slaHours':2, 'keywords':['fire risk'], 'synonyms':['flammable danger'], 'departmentId':'dept_electricity'},
      {'category':'Encroachment', 'subtype':'Illegal street encroachment', 'priority':'Medium', 'slaHours':48, 'keywords':['encroachment'], 'synonyms':['illegal structure'], 'departmentId':'dept_garbage'},
      {'category':'Encroachment', 'subtype':'Footpath blocked', 'priority':'Medium', 'slaHours':48, 'keywords':['footpath blocked'], 'synonyms':['walking path blocked'], 'departmentId':'dept_garbage'},
      {'category':'Encroachment', 'subtype':'Construction material on road', 'priority':'Medium', 'slaHours':48, 'keywords':['construction material'], 'synonyms':['road blocked materials'], 'departmentId':'dept_garbage'},
      {'category':'Encroachment', 'subtype':'Illegal parking blockage', 'priority':'Medium', 'slaHours':48, 'keywords':['illegal parking'], 'synonyms':['vehicle blockage'], 'departmentId':'dept_garbage'},
      {'category':'Infrastructure', 'subtype':'Public toilet dirty', 'priority':'Medium', 'slaHours':24, 'keywords':['toilet dirty'], 'synonyms':['unclean toilet'], 'departmentId':'dept_garbage'},
      {'category':'Infrastructure', 'subtype':'Public toilet not working', 'priority':'High', 'slaHours':12, 'keywords':['toilet not working'], 'synonyms':['facility broken'], 'departmentId':'dept_garbage'},
      {'category':'Infrastructure', 'subtype':'Broken bench', 'priority':'Low', 'slaHours':48, 'keywords':['bench broken'], 'synonyms':['seat damaged'], 'departmentId':'dept_garbage'},
      {'category':'Infrastructure', 'subtype':'Bus stop damaged', 'priority':'Medium', 'slaHours':24, 'keywords':['bus stop broken'], 'synonyms':['damaged shelter'], 'departmentId':'dept_garbage'},
      {'category':'Infrastructure', 'subtype':'Public tap not working', 'priority':'Medium', 'slaHours':24, 'keywords':['public tap issue'], 'synonyms':['tap broken'], 'departmentId':'dept_garbage'},
      {'category':'Animals', 'subtype':'Stray dogs', 'priority':'Medium', 'slaHours':24, 'keywords':['stray dogs'], 'synonyms':['street dogs'], 'departmentId':'dept_garbage'},
      {'category':'Animals', 'subtype':'Stray cattle', 'priority':'Medium', 'slaHours':24, 'keywords':['stray cattle'], 'synonyms':['loose cows'], 'departmentId':'dept_garbage'},
      {'category':'Animals', 'subtype':'Dead animal removal', 'priority':'High', 'slaHours':8, 'keywords':['dead animal'], 'synonyms':['carcass removal'], 'departmentId':'dept_garbage'},
      {'category':'Governance', 'subtype':'Complaint not resolved', 'priority':'High', 'slaHours':12, 'keywords':['not resolved'], 'synonyms':['no action taken'], 'departmentId':'dept_garbage'},
      {'category':'Governance', 'subtype':'Wrongly closed complaint', 'priority':'High', 'slaHours':12, 'keywords':['wrong closure'], 'synonyms':['closed incorrectly'], 'departmentId':'dept_garbage'},
      {'category':'Governance', 'subtype':'Poor quality repair', 'priority':'Medium', 'slaHours':24, 'keywords':['poor repair'], 'synonyms':['bad work quality'], 'departmentId':'dept_garbage'},
      {'category':'Governance', 'subtype':'Repeated issue', 'priority':'High', 'slaHours':12, 'keywords':['repeated problem'], 'synonyms':['issue again'], 'departmentId':'dept_garbage'},
      {'category':'Health', 'subtype':'Disease outbreak suspected', 'priority':'Critical', 'slaHours':2, 'keywords':['disease outbreak','epidemic'], 'synonyms':['illness spreading'], 'departmentId':'dept_health'},
      {'category':'Health', 'subtype':'Fever cluster in area', 'priority':'Critical', 'slaHours':4, 'keywords':['fever spreading','dengue'], 'synonyms':['multiple fever cases'], 'departmentId':'dept_health'},
      {'category':'Health', 'subtype':'Mosquito breeding', 'priority':'High', 'slaHours':8, 'keywords':['mosquito breeding','malaria risk'], 'synonyms':['larva found'], 'departmentId':'dept_health'},
      {'category':'Health', 'subtype':'Food poisoning', 'priority':'Critical', 'slaHours':2, 'keywords':['food poisoning'], 'synonyms':['food contamination'], 'departmentId':'dept_health'},
      {'category':'Health', 'subtype':'Dead animal health risk', 'priority':'High', 'slaHours':6, 'keywords':['dead animal smell','carcass'], 'synonyms':['decomposing animal'], 'departmentId':'dept_health'},
      {'category':'Health', 'subtype':'Illegal slaughter', 'priority':'High', 'slaHours':8, 'keywords':['illegal slaughter','slaughterhouse'], 'synonyms':['unlicensed meat'], 'departmentId':'dept_health'},
      {'category':'Health', 'subtype':'Vaccination camp needed', 'priority':'Medium', 'slaHours':48, 'keywords':['vaccination','immunization'], 'synonyms':['health camp'], 'departmentId':'dept_health'},
      {'category':'Health', 'subtype':'Hospital / clinic complaint', 'priority':'High', 'slaHours':12, 'keywords':['hospital complaint','clinic issue'], 'synonyms':['medical facility problem'], 'departmentId':'dept_health'}
    ];

    WriteBatch batch = _firestore.batch();
    for (var raw in rawData) {
      DocumentReference ref = _firestore.collection('COMPLAINT_TYPES').doc();
      ComplaintTypeModel model = ComplaintTypeModel(
         id: ref.id,
         category: raw['category'],
         subtype: raw['subtype'],
         priority: raw['priority'],
         slaHours: raw['slaHours'],
         keywords: List<String>.from(raw['keywords']),
         synonyms: List<String>.from(raw['synonyms']),
         departmentId: raw['departmentId'],
      );
      batch.set(ref, model.toMap());
    }
    await batch.commit();
    print("Seeded ${rawData.length} Complaint Types.");
  }
}
