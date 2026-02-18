import 'package:flutter_riverpod/legacy.dart';

final selectedFilterProvider = StateProvider<String>((ref) => 'All');

// Search query provider
final portfolioSearchQueryProvider = StateProvider<String>((ref) => '');