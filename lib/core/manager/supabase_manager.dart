import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager shared = SupabaseManager._internal();

  factory SupabaseManager() => shared;

  SupabaseManager._internal() {
    debugPrint("SupabaseManager init");
  }

  SupabaseClient get supabase => Supabase.instance.client;
}
