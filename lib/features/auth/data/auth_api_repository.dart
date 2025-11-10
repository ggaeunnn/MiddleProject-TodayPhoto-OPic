import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/user_model.dart';

class AuthRepository {
  //public.user정보가져오기(uuid)
  Future<UserInfo> fetchUserDataWithUUID(String uuid) async {
    final Map<String, dynamic> data = await SupabaseManager.shared.supabase
        .from('user')
        .select("*")
        .eq("uuid", uuid)
        .single();

    UserInfo result = UserInfo.fromJson(data);

    return result;
  }
}
