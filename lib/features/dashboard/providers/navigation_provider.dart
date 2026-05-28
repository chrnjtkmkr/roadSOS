import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider to manage the active bottom navigation tab in MainLayout.
final currentTabProvider = StateProvider<int>((ref) => 0);
