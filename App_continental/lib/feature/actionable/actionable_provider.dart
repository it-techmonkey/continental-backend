// lib/actionable_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

enum ItemType { rental, offPlan }

@immutable
class ActionableItem {
  final int id; // occupantRecordId for navigation
  final String propertyName;
  final String name;
  final String installmentsPending;
  final String status;
  final ItemType type;

  const ActionableItem({
    required this.id,
    required this.propertyName,
    required this.name,
    required this.installmentsPending,
    required this.status,
    required this.type,
  });

  factory ActionableItem.fromJson(Map<String, dynamic> json) {
    return ActionableItem(
      id: json['id'] ?? 0,
      propertyName: json['propertyName'],
      name: json['name'],
      installmentsPending: json['installmentsPending'],
      status: json['status'],
      type: json['type'].toLowerCase() == 'rental' ? ItemType.rental : ItemType.offPlan,
    );
  }
}


final actionableFilterProvider = StateProvider<String>((ref) => 'All');

// Search query provider
final actionableSearchQueryProvider = StateProvider<String>((ref) => '');