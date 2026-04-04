import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class NlpResult {
  final String departmentId;
  final String category;
  final String subtype;
  final String priority;
  final String title;
  final int slaHours;
  final double confidence;
  final String method;
  final bool isCriticalOverride;

  NlpResult({
    required this.departmentId,
    required this.category,
    required this.subtype,
    required this.priority,
    required this.title,
    required this.slaHours,
    required this.confidence,
    required this.method,
    required this.isCriticalOverride,
  });

  Map<String, dynamic> toMap() {
    return {
      'departmentId': departmentId,
      'category': category,
      'subtype': subtype,
      'priority': priority,
      'title': title,
      'slaHours': slaHours,
      'confidence': confidence,
      'method': method,
      'isCriticalOverride': isCriticalOverride,
    };
  }

  NlpResult copyWith({
    String? departmentId,
    String? category,
    String? subtype,
    String? priority,
    String? title,
    int? slaHours,
    double? confidence,
    String? method,
    bool? isCriticalOverride,
  }) {
    return NlpResult(
      departmentId: departmentId ?? this.departmentId,
      category: category ?? this.category,
      subtype: subtype ?? this.subtype,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      slaHours: slaHours ?? this.slaHours,
      confidence: confidence ?? this.confidence,
      method: method ?? this.method,
      isCriticalOverride: isCriticalOverride ?? this.isCriticalOverride,
    );
  }
}

class NlpClassificationService {
  static const Map<String, List<String>> _keywordMap = {
    'dept_electricity': [
      'light', 'streetlight', 'street light', 'lamp post', 'lamp', 'dark area',
      'no light', 'bulb', 'pole', 'electric pole', 'hanging wire', 'loose wire',
      'electric risk', 'flickering', 'blinking light', 'dim light', 'lineman',
      'transformer', 'broken pole', 'fallen pole', 'short circuit', 'sparking',
      'no lighting', 'power cut', 'wire broken', 'wire hanging',
    ],
    'dept_water': [
      'water', 'leak', 'leakage', 'pipe', 'burst', 'sewage', 'drain',
      'choked drain', 'blocked drain', 'overflow', 'water supply', 'pressure',
      'tank', 'plumber', 'contaminated', 'muddy water', 'dirty water',
      'waterlog', 'waterlogging', 'stagnant water', 'no water', 'water not coming',
      'pipeline broken', 'pipe burst', 'valve', 'water theft', 'sewage overflow',
      'drain cover', 'drain smell', 'open drain', 'water seeping',
    ],
    'dept_garbage': [
      'garbage', 'waste', 'trash', 'dump', 'bin', 'dustbin', 'foul smell',
      'mosquito', 'mosquitoes', 'sweep', 'litter', 'sanitation', 'stray dog',
      'stray cow', 'stray cattle', 'dead animal', 'carcass', 'toilet dirty',
      'public toilet', 'encroachment', 'footpath blocked', 'illegal dumping',
      'construction waste', 'debris dump', 'overflowing bin', 'garbage pile',
      'bad smell', 'not cleaned', 'bus stop broken', 'bench broken',
    ],
    'dept_roads': [
      'pothole', 'road', 'crack', 'sinkhole', 'open manhole', 'manhole open',
      'footpath broken', 'broken footpath', 'pavement', 'divider', 'tar',
      'road debris', 'broken road', 'road collapsed', 'road surface',
      'construction not fixed', 'digging not repaired', 'road caved',
      'multiple potholes', 'stones on road', 'road damage',
    ],
    'dept_health': [
      'disease', 'outbreak', 'fever', 'dengue', 'malaria', 'cholera', 'epidemic',
      'food poisoning', 'contamination', 'vaccination', 'health worker', 'hospital',
      'clinic', 'illness spreading', 'sick', 'infection', 'mosquito breeding',
      'larva', 'illegal slaughter', 'slaughterhouse', 'health camp', 'immunization',
      'dead animal smell', 'decomposing', 'health risk',
    ],
  };

  static const List<String> _criticalKeywords = [
    'hanging wire', 'exposed wire', 'live wire', 'electric shock', 'electrocution',
    'open manhole', 'drain cover missing', 'road collapse', 'sinkhole',
    'sewage overflow', 'pipe burst', 'fire', 'accident', 'injury', 'dangerous',
    'broken pole', 'fallen pole', 'road caved', 'no barricade', 'disease outbreak',
    'food poisoning', 'epidemic', 'child fell', 'death', 'hospital nearby',
    'collapsed', 'gas leak', 'emergency', 'electrocution risk',
  ];

  static Future<NlpResult> classify(String inputText) async {
    bool isCriticalOverride = _criticalKeywords.any((k) => inputText.toLowerCase().contains(k));
    
    // LAYER 1 
    NlpResult? result = _classifyByKeywords(inputText, isCriticalOverride);

    // LAYER 2
    if (result == null) {
      result = await _classifyByLLM(inputText, isCriticalOverride);
    }

    // Completely unclassified fallback
    if (result == null) {
      return NlpResult(
        departmentId: '',
        category: 'Unclassified',
        subtype: 'Unclassified Issue',
        priority: isCriticalOverride ? 'Critical' : 'Medium',
        title: 'Unclassified: ${inputText.length > 20 ? inputText.substring(0, 20) + '...' : inputText}',
        slaHours: 24,
        confidence: 0.0,
        method: 'failed',
        isCriticalOverride: isCriticalOverride,
      );
    }

    // LAYER 3 
    return await _enrichFromFirestore(inputText, result, isCriticalOverride);
  }

  static NlpResult? _classifyByKeywords(String text, bool isCriticalOverride) {
    String cleanText = text.toLowerCase();
    Map<String, int> scores = {};
    
    for (var entry in _keywordMap.entries) {
      int score = 0;
      for (var k in entry.value) {
        if (cleanText.contains(k)) score++;
      }
      if (score >= 1) scores[entry.key] = score;
    }

    if (scores.isEmpty) return null;

    var sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    // Tie check or only 1 dept matched
    if (sorted.length > 1 && sorted[0].value <= sorted[1].value) return null;

    String bestDept = sorted.first.key;
    return NlpResult(
      departmentId: bestDept,
      category: 'General',
      subtype: 'General Issue',
      priority: isCriticalOverride ? 'Critical' : 'Medium',
      title: text.length > 30 ? text.substring(0, 27) + '...' : text,
      slaHours: 24,
      confidence: 0.7,
      method: 'keyword',
      isCriticalOverride: isCriticalOverride,
    );
  }

  static Future<NlpResult?> _classifyByLLM(String text, bool isCriticalOverride) async {
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${AppConfig.geminiApiKey}');
      final prompt = '''
You classify civic complaints for Pune city, India.
Input may be English, Hindi, Marathi, or mixed.

Departments:
- dept_electricity: streetlights, poles, wires, electrical hazards
- dept_garbage: garbage, sanitation, stray animals, encroachment, public facilities
- dept_water: water supply, pipe leaks, drainage, sewage
- dept_roads: potholes, road damage, manholes, broken footpaths
- dept_health: disease outbreaks, food poisoning, mosquito breeding, hospital complaints

Output ONLY this JSON, no markdown, no explanation:
{
  "departmentId": "",
  "category": "",
  "subtype": "",
  "priority": "Critical|High|Medium|Low",
  "title": "",
  "confidence": 0.0
}
''';
      
      final body = jsonEncode({
        "contents": [{"parts": [{"text": "$prompt\n\nInput: $text"}]}],
        "generationConfig": {
          "temperature": 0.1,
          "maxOutputTokens": 200,
        }
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawText = data['candidates'][0]['content']['parts'][0]['text'];
        
        final jsonStart = rawText.indexOf('{');
        final jsonEnd = rawText.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          String cleanJson = rawText.substring(jsonStart, jsonEnd + 1);
          final Map<String, dynamic> rData = jsonDecode(cleanJson);
          
          if ((rData['departmentId'] ?? '').isEmpty) return null;
          
          return NlpResult(
            departmentId: rData['departmentId'],
            category: rData['category'] ?? 'General',
            subtype: rData['subtype'] ?? 'General Issue',
            priority: isCriticalOverride ? 'Critical' : (rData['priority'] ?? 'Medium'),
            title: rData['title'] ?? text.substring(0, text.length > 20 ? 20 : text.length),
            slaHours: 24, // fallback before L3
            confidence: rData['confidence'] != null ? rData['confidence'].toDouble() : 0.8,
            method: 'llm',
            isCriticalOverride: isCriticalOverride, // will also dynamically upgrade in L3
          );
        }
      }
    } catch (e) {
      print("[NlpClassificationService] LLM failure: $e");
    }
    return null;
  }

  static Future<NlpResult> _enrichFromFirestore(String text, NlpResult current, bool isCriticalOverride) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('COMPLAINT_TYPES')
          .where('departmentId', isEqualTo: current.departmentId)
          .get();

      if (querySnapshot.docs.isEmpty) return current;

      String cleanText = text.toLowerCase();
      DocumentSnapshot? bestDoc;
      int maxScore = -1;

      for (var doc in querySnapshot.docs) {
        int score = 0;
        final data = doc.data() as Map<String, dynamic>;
        
        final keywords = data['keywords'] as List<dynamic>? ?? [];
        final synonyms = data['synonyms'] as List<dynamic>? ?? [];
        
        for (var k in keywords) {
          if (cleanText.contains(k.toString().toLowerCase())) score += 5; // keywords heavily weighted
        }
        for (var s in synonyms) {
          if (cleanText.contains(s.toString().toLowerCase())) score += 2; // synonyms lower weight
        }
        
        if (score > maxScore) {
          maxScore = score;
          bestDoc = doc;
        }
      }

      if (bestDoc != null) {
        final data = bestDoc.data() as Map<String, dynamic>;
        final String originalPriority = data['priority'] ?? current.priority;
        final bool forceCritical = isCriticalOverride || originalPriority == 'Critical';

        return current.copyWith(
          category: data['category'] ?? current.category,
          subtype: data['subtype'] ?? current.subtype,
          title: data['subtype'] ?? current.subtype, // English title
          priority: forceCritical ? 'Critical' : originalPriority,
          slaHours: data['slaHours'] ?? current.slaHours,
          isCriticalOverride: forceCritical && originalPriority != 'Critical',
        );
      }
    } catch (e) {
      print("[NlpClassificationService] Enrichment failure: $e");
    }

    return current;
  }
}
