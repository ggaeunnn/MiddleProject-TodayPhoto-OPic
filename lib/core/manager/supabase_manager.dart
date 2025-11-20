import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager shared = SupabaseManager._internal();

  factory SupabaseManager() => shared;

  SupabaseManager._internal() {
    debugPrint("SupabaseManager init");
  }

  SupabaseClient get supabase => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['Supabase_URL']!,
      anonKey: dotenv.env['Supabase_Anonkey']!,
    );
  }
}
