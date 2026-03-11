import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/structure_models.dart';
import '../models/complaint_type_model.dart';
import '../core/constants.dart';

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedHierarchicalData() async {
    print("Starting Hierarchical Data Seeding (Pune Zone)...");
    
    final divisionId = 'zone_pune'; // Using 'zone' conceptually as CE Head
    // CE 10000001
    await _seedUser('10000001', 'Sanjay Patil', 'sanjay.patil@mahavitaran.in', 'CE', 'Chief Engineer', 
        divisionId: divisionId, officeId: 'office_pune_hq');

    // === CIRCLE 1: PUNE CITY ZONE 1 ===
    final c1Id = 'circle_pune_1';
    await _firestore.collection('CIRCLES').doc(c1Id).set(
      CircleModel(circleId: c1Id, divisionId: divisionId, name: 'Pune City Zone 1').toMap()
    );
    // SE 1
    await _seedUser('10000002', 'Milind Deshmukh', 'milind.deshmukh@mahavitaran.in', 'SE', 'Superintending Engineer', 
        divisionId: divisionId, circleId: c1Id, officeId: 'office_circle_1');

    // -- Region 1: Central --
    await _seedRegion(
      regionId: 'reg_central', circleId: c1Id, regionName: 'Central',
      eeData: ['10000004', 'Pravin Kulkarni', 'pravin.kulkarni@mahavitaran.in'],
      dyeeData: ['10000005', 'Sachin Joshi', 'sachin.joshi@mahavitaran.in'],
      offices: [
        _OfficeSeed('off_shivajinagar', 'Shivajinagar Office', 
            '10000012', 'Rohit Bhosale', 'rohit.bhosale@mahavitaran.in', 
            '10000013', 'Amol Jadhav', 'amol.jadhav@mahavitaran.in', 
            ['10000014', 'Nilesh Pawar', 'nilesh.pawar@mahavitaran.in'],
            admin: '10000015', adminName: 'Admin Shivajinagar', adminEmail: 'admin.shivajinagar@mahavitaran.in',
            lat: 18.5303, lng: 73.8499), // Updated as per user request (Shivajinagar)
        _OfficeSeed('off_swargate', 'Swargate Office', 
            '10000020', 'Rahul Jagtap', 'rahul.jagtap@mahavitaran.in', 
            '10000021', 'Sandeep More', 'sandeep.more@mahavitaran.in', 
            ['10000022', 'Manoj Patil', 'manoj.patil@mahavitaran.in'],
             admin: '10000023', adminName: 'Admin Swargate', adminEmail: 'admin.swargate@mahavitaran.in',
             lat: 18.5008, lng: 73.8584),
      ]
    );

    // -- Region 2: East-South --
    await _seedRegion(
      regionId: 'reg_east_south', circleId: c1Id, regionName: 'East-South',
      eeData: ['10000006', 'Mahesh Gokhale', 'mahesh.gokhale@mahavitaran.in'],
      dyeeData: ['10000008', 'Vijay Chavan', 'vijay.chavan@mahavitaran.in'],
      offices: [
        _OfficeSeed('off_hadapsar', 'Hadapsar Office', 
            '10000028', 'Yogesh Patil', 'yogesh.patil@mahavitaran.in', 
            '10000029', 'Shailesh Jadhav', 'shailesh.jadhav@mahavitaran.in', 
            ['10000030', 'Ganesh Shinde', 'ganesh.shinde@mahavitaran.in'],
            admin: '10000031', adminName: 'Admin Hadapsar', adminEmail: 'admin.hadapsar@mahavitaran.in',
            lat: 18.5089, lng: 73.9259),
        _OfficeSeed('off_katraj', 'Katraj Office', 
            '10000024', 'Amit Kulkarni', 'amit.kulkarni@mahavitaran.in', 
            '10000025', 'Pankaj Deshmukh', 'pankaj.deshmukh@mahavitaran.in', 
            ['10000026', 'Vinod Pawar', 'vinod.pawar@mahavitaran.in'],
             admin: '10000027', adminName: 'Admin Katraj', adminEmail: 'admin.katraj@mahavitaran.in',
             lat: 18.4529, lng: 73.8552), // Adjusted for better separation
      ]
    );


    // === CIRCLE 2: PUNE CITY ZONE 2 ===
    final c2Id = 'circle_pune_2';
    await _firestore.collection('CIRCLES').doc(c2Id).set(
      CircleModel(circleId: c2Id, divisionId: divisionId, name: 'Pune City Zone 2').toMap()
    );
    // SE 2
    await _seedUser('10000003', 'Anil Phadke', 'anil.phadke@mahavitaran.in', 'SE', 'Superintending Engineer', 
        divisionId: divisionId, circleId: c2Id, officeId: 'office_circle_2');

    // -- Region 3: West --
    await _seedRegion(
      regionId: 'reg_west', circleId: c2Id, regionName: 'West',
      eeData: ['10000010', 'Ketan Shirole', 'ketan.shirole@mahavitaran.in'],
      dyeeData: ['10000011', 'Harish Naik', 'harish.naik@mahavitaran.in'],
      offices: [
        _OfficeSeed('off_kothrud', 'Kothrud Office', 
            '10000036', 'Kunal Desai', 'kunal.desai@mahavitaran.in', 
            '10000037', 'Ajay Chavan', 'ajay.chavan@mahavitaran.in', 
            ['10000038', 'Prashant Kale', 'prashant.kale@mahavitaran.in'],
            admin: '10000039', adminName: 'Admin Kothrud', adminEmail: 'admin.kothrud@mahavitaran.in',
            lat: 18.5074, lng: 73.8077),
        _OfficeSeed('off_aundh', 'Aundh Office', 
            '10000016', 'Akshay Gaikwad', 'akshay.gaikwad@mahavitaran.in', 
            '10000017', 'Swapnil More', 'swapnil.more@mahavitaran.in', 
            ['10000018', 'Suresh Kapse', 'suresh.kapse@mahavitaran.in'],
            admin: '10000019', adminName: 'Admin Aundh', adminEmail: 'admin.aundh@mahavitaran.in',
            lat: 18.5639, lng: 73.8073),
      ]
    );

     // -- Region 4: North --
    await _seedRegion(
      regionId: 'reg_north', circleId: c2Id, regionName: 'North',
      eeData: ['10000050', 'Suresh Raina', 'suresh.raina@mahavitaran.in'],
      dyeeData: ['10000051', 'Zaheer Khan', 'zaheer.khan@mahavitaran.in'],
      offices: [
        _OfficeSeed('off_yerwada', 'Yerwada Office', 
            '10000040', 'Ramesh Patil', 'ramesh.patil@mahavitaran.in', 
            '10000041', 'Sunil Pawar', 'sunil.pawar@mahavitaran.in', 
            ['10000042', 'Deepak Shinde', 'deepak.shinde@mahavitaran.in'],
            admin: '10000043', adminName: 'Admin Yerwada', adminEmail: 'admin.yerwada@mahavitaran.in',
            lat: 18.5529, lng: 73.8797),
        _OfficeSeed('off_pimpri', 'Pimpri Office', 
            '10000044', 'Virat Kohli', 'virat.kohli@mahavitaran.in', 
            '10000045', 'Rohit Sharma', 'rohit.sharma@mahavitaran.in', 
            ['10000046', 'Hardik Pandya', 'hardik.pandya@mahavitaran.in'],
            admin: '10000047', adminName: 'Admin Pimpri', adminEmail: 'admin.pimpri@mahavitaran.in',
            lat: 18.6298, lng: 73.7997),
      ]
    );

    print("Seeding Complete. All Users & Structures Created.");
  }

  Future<void> _seedRegion({
    required String regionId, 
    required String circleId, 
    required String regionName,
    required List<String> eeData,
    required List<String> dyeeData,
    required List<_OfficeSeed> offices
  }) async {
    // Create Region
    await _firestore.collection('REGIONS').doc(regionId).set(
      RegionModel(regionId: regionId, circleId: circleId, name: regionName).toMap()
    );

    // EE User
    await _seedUser(eeData[0], eeData[1], eeData[2], 'EE', 'Executive Engineer', 
        divisionId: 'zone_pune', circleId: circleId, regionId: regionId, officeId: 'office_${regionName.toLowerCase()}_ee');
    
    // DyEE User
    await _seedUser(dyeeData[0], dyeeData[1], dyeeData[2], 'DyEE', 'Deputy Executive Engineer', 
        divisionId: 'zone_pune', circleId: circleId, regionId: regionId, officeId: 'office_${regionName.toLowerCase()}_dyee');

    // Create Offices and their Staff
    for (var off in offices) {
      double radius = 15;
      if (off.name.contains('Shivajinagar')) radius = 3; // Explicit User Rule for Shivajinagar

      await _firestore.collection('OFFICES').doc(off.id).set(
        OfficeModel(officeId: off.id, regionId: regionId, name: off.name, 
            latitude: off.lat, longitude: off.lng, radiusKm: radius).toMap() 
      );

      // JE
      await _seedUser(off.jeId, off.jeName, off.jeEmail, 'JE', 'Junior Engineer',
          divisionId: 'zone_pune', circleId: circleId, regionId: regionId, officeId: off.id);
      
      // AE
      await _seedUser(off.aeId, off.aeName, off.aeEmail, 'AE', 'Assistant Engineer',
          divisionId: 'zone_pune', circleId: circleId, regionId: regionId, officeId: off.id);
      
      // Admin
      if (off.admin != null) {
         await _seedUser(off.admin!, off.adminName!, off.adminEmail!, 'OFFICE_ADMIN', 'Admin',
            divisionId: 'zone_pune', circleId: circleId, regionId: regionId, officeId: off.id);
      }

      // Field Officers
      for (int i = 0; i < off.foData.length; i+=3) {
        await _seedUser(off.foData[i], off.foData[i+1], off.foData[i+2], 'FieldOfficer', 'Field Officer',
            divisionId: 'zone_pune', circleId: circleId, regionId: regionId, officeId: off.id);
      }
    }
  }

  Future<void> _seedUser(String uid, String name, String email, String role, String designation, 
      {String? divisionId, String? circleId, String? regionId, String? officeId}) async {
    
    final user = UserModel(
      userId: uid,
      name: name,
      email: email,
      phone: '9890000000', // Dummy
      role: role,
      designation: designation,
      divisionId: divisionId,
      circleId: circleId,
      regionId: regionId,
      officeId: officeId,
      createdAt: DateTime.now(),
      isActive: true,
    );
    
    await _firestore.collection('USERS').doc(uid).set(user.toMap());
  }

  // From Previous Steps: seedComplaintTypes
  Future<void> seedComplaintTypes() async {
    print("Seeding Complaint Types with Priority...");
    final List<String> csvLines = [
"Forest Fire,E (Critical),1 min,2 min",
"Noise from transformer,A1 (High),1 hour,6 hours",
"Major blackout in entire colony,E (Critical),15 minutes,2 hours",
"Loose wire hanging without danger,A3 (Low),12 hours,72 hours",
"Wires hanging low on street,A2 (Medium),6 hours,24 hours",
"Frequent voltage fluctuation in house,A1 (High),1 hour,6 hours",
"Complaint of high bill without usage,A3 (Low),12 hours,72 hours",
"Fuse blown at transformer,A1 (High),1 hour,6 hours",
"Loose connection at electric pole,A1 (High),1 hour,6 hours",
"Old wooden electric pole needs replacement,A3 (Low),12 hours,72 hours",
"Electric pole fallen on road,E (Critical),15 minutes,2 hours",
"School building exposed to live wires,E (Critical),15 minutes,2 hours",
"Sparking in electric substation,E (Critical),15 minutes,2 hours",
"High voltage fluctuation risking appliances,E (Critical),15 minutes,2 hours",
"Street lights flickering in entire lane,A1 (High),1 hour,6 hours",
"One or two houses without power,A2 (Medium),6 hours,24 hours",
"Electric bill not generated,A3 (Low),12 hours,72 hours",
"Single phase outage in colony,A1 (High),1 hour,6 hours",
"Need new street light installation,A3 (Low),12 hours,72 hours",
"Street light wire cut,A2 (Medium),6 hours,24 hours",
"Transformer blast in the area,E (Critical),15 minutes,2 hours",
"Power cut during daytime,A2 (Medium),6 hours,24 hours",
"Phase imbalance in area,A1 (High),1 hour,6 hours",
"Meter reading not updated,A3 (Low),12 hours,72 hours",
"Low voltage supply at night,A2 (Medium),6 hours,24 hours",
"Fan speed very low due to low supply,A2 (Medium),6 hours,24 hours",
"Damaged meter causing sparks,A1 (High),1 hour,6 hours",
"Sudden outage in half of the colony,A1 (High),1 hour,6 hours",
"Electric pole rusted,A3 (Low),12 hours,72 hours",
"Meter box broken cover,A2 (Medium),6 hours,24 hours",
"Appliances damaged due to fluctuations,A2 (Medium),6 hours,24 hours",
"Burning smell from transformer,E (Critical),15 minutes,2 hours",
"Water pump not working due to electric fault,A1 (High),1 hour,6 hours",
"Hospital power outage,E (Critical),15 minutes,2 hours",
"Street light cover missing,A3 (Low),12 hours,72 hours",
"Frequent power cuts in evening,A2 (Medium),6 hours,24 hours",
"Tree branches touching electric wire (no sparks),A3 (Low),12 hours,72 hours",
"Electric fire due to short circuit,E (Critical),15 minutes,2 hours",
"Street light not working,A2 (Medium),6 hours,24 hours",
"Live wire in water puddle,E (Critical),15 minutes,2 hours",
"Small fuse replacement required,A3 (Low),12 hours,72 hours",
"Transformer oil leakage,E (Critical),15 minutes,2 hours",
"Transformer overheating,E (Critical),15 minutes,2 hours",
"Distribution box open and unsafe,A3 (Low),12 hours,72 hours",
"Street light pole rusted and unstable,A2 (Medium),6 hours,24 hours",
"Electric meter sparking,E (Critical),15 minutes,2 hours",
"Meter seal broken,A2 (Medium),6 hours,24 hours",
"Power supply tripping repeatedly,A1 (High),1 hour,6 hours",
"Cable joint damaged,A3 (Low),12 hours,72 hours",
"Underground cable fault,A3 (Low),12 hours,72 hours",
"Overloaded transformer in area,A3 (Low),12 hours,72 hours",
"Electric pole leaning dangerously,A2 (Medium),6 hours,24 hours",
"Tree branches touching power lines,A3 (Low),12 hours,72 hours",
"Substation fence damaged,E (Critical),15 minutes,2 hours",
"Unauthorized load causing outage,A1 (High),1 hour,6 hours",
"Phase failure in locality,A1 (High),1 hour,6 hours",
"Power surge damaging appliances,A1 (High),1 hour,6 hours",
"Frequent fuse burnouts,A3 (Low),12 hours,72 hours",
"Service line snapped,E (Critical),15 minutes,2 hours",
"Water leakage near electric cables,A3 (Low),12 hours,72 hours",
"Open junction box on roadside,A2 (Medium),6 hours,24 hours"
    ];

    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (String line in csvLines) {
      List<String> parts = line.split(',');
      if (parts.length >= 4) {
        String title = parts[0].trim();
        String cat = parts[1].trim();
        String slaResp = parts[2].trim();
        String slaReso = parts[3].trim();

        String priority = 'Medium';
        if (cat.contains('Critical')) priority = 'Critical';
        else if (cat.contains('High')) priority = 'High';
        else if (cat.contains('Low')) priority = 'Low';
        
        ComplaintTypeModel model = ComplaintTypeModel(
          title: title,
          category: cat,
          priority: priority,
          slaResponse: slaResp,
          slaResolution: slaReso,
        );
        
        DocumentReference ref = _firestore.collection('COMPLAINT_TYPES').doc();
        batch.set(ref, model.toMap());
        count++;
      }
    }
    
    await batch.commit();
    print("Seeded $count Complaint Types.");
  }
}

class _OfficeSeed {
  final String id;
  final String name;
  final String jeId;
  final String jeName;
  final String jeEmail;
  final String aeId;
  final String aeName;
  final String aeEmail;
  final List<String> foData; // [id, name, email...]
  final String? admin;
  final String? adminName;
  final String? adminEmail;
  final double lat;
  final double lng;

  _OfficeSeed(this.id, this.name, this.jeId, this.jeName, this.jeEmail, 
      this.aeId, this.aeName, this.aeEmail, this.foData, 
      {this.admin, this.adminName, this.adminEmail, this.lat = 18.52, this.lng = 73.85});
}


