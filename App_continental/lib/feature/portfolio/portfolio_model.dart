// lib/portfolio_models.dart
import 'package:flutter/foundation.dart';
 // We need the Enum from the UI file
enum PortfolioStatus { overDue, completed, due }

@immutable
class DashboardStats {
  final String totalPropertiesRented;
  final String rentalsDue;
  final String rentalAmountDue;
  final String vacantProperties;
  final String totalOffPlanProperties;
  final String totalPropertyPrice;

  const DashboardStats({
    required this.totalPropertiesRented,
    required this.rentalsDue,
    required this.rentalAmountDue,
    required this.vacantProperties,
    required this.totalOffPlanProperties,
    required this.totalPropertyPrice,
  });


  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPropertiesRented: json['totalPropertiesRented'],
      rentalsDue: json['rentalsDue'],
      rentalAmountDue: json['rentalAmountDue'],
      vacantProperties: json['vacantProperties'],
      totalOffPlanProperties: json['totalOffPlanProperties'],
      totalPropertyPrice: json['totalPropertyPrice'],
    );
  }
}

// Model for a single item in the portfolio list
@immutable
class PortfolioItem {
  final int id; // occupantRecordId for navigation
  final String propertyName;
  final String tenantName;
  final String pendingAmount;
  final String roi;
  final PortfolioStatus status;

  const PortfolioItem({
    required this.id,
    required this.propertyName,
    required this.tenantName,
    required this.pendingAmount,
    required this.roi,
    required this.status,
  });

  // A factory constructor to create a PortfolioItem from a JSON map
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'] ?? 0,
      propertyName: json['propertyName'],
      tenantName: json['tenantName'],
      pendingAmount: json['pendingAmount'],
      roi: json['roi'],
      // Convert the status string from the API to our enum
      status: _statusFromString(json['status']),
    );
  }

  static PortfolioStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
        return PortfolioStatus.overDue;
      case 'completed':
      case 'paid':
        return PortfolioStatus.completed;
      case 'due':
        return PortfolioStatus.due;
      default:
        return PortfolioStatus.due; // A safe default
    }
  }
}

// A top-level model to hold all the data for the page
@immutable
class PortfolioPageData {
  final DashboardStats stats;
  final List<PortfolioItem> portfolioItems;

  const PortfolioPageData({required this.stats, required this.portfolioItems});

  factory PortfolioPageData.fromJson(Map<String, dynamic> json) {
    var itemsList = json['portfolioItems'] as List;
    List<PortfolioItem> portfolioItems = itemsList.map((i) => PortfolioItem.fromJson(i)).toList();

    return PortfolioPageData(
      stats: DashboardStats.fromJson(json['stats']),
      portfolioItems: portfolioItems,
    );
  }
}