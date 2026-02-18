import 'dart:convert';
import 'package:flutter/services.dart';

class Developer {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? logo;
  final String? type;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;

  Developer({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.logo,
    this.type,
    this.website,
    this.email,
    this.phone,
    this.address,
  });

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      type: json['type'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }
}

class DevelopersService {
  static List<Developer>? _cachedDevelopers;
  
  static Future<List<Developer>> loadDevelopers() async {
    if (_cachedDevelopers != null) {
      return _cachedDevelopers!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/developers.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      if (jsonData['data'] != null && jsonData['data'] is List) {
        final List<dynamic> developersList = jsonData['data'] as List;
        _cachedDevelopers = developersList
            .map((developerJson) => Developer.fromJson(developerJson as Map<String, dynamic>))
            .toList();
        return _cachedDevelopers!;
      }
      
      return [];
    } catch (e) {
      print('Error loading developers.json: $e');
      return [];
    }
  }
  
  static List<String> getDeveloperNames(List<Developer> developers) {
    return developers.map((dev) => dev.name).toList();
  }
}

