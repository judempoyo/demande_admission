import 'package:demande_admission/models/admission_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> saveRequest(AdmissionRequest request) async {
    try {
      final response = await _client
          .from('admission_requests')
          .insert(request.toMap());

      if (response.error != null) {
        throw 'Erreur Supabase: ${response.error!.message}';
      }
    } catch (e) {
      throw 'Erreur de sauvegarde: ${e.toString()}';
    }
  }

  Stream<List<AdmissionRequest>> getRequests(String userId) {
    return _client
        .from('admission_requests') // Utilisez le bon nom de table
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('submission_date', ascending: false)
        .map((data) => data.map((e) => AdmissionRequest.fromMap(e)).toList());
  }
}
