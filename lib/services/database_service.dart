import 'package:demande_admission/models/admission_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Sauvegarder une demande
  Future<void> saveRequest(AdmissionRequest request) async {
    try {
      await _client
          .from('requests')
          .insert(request.toMap());
    } catch (e) {
      throw 'Erreur de sauvegarde: $e';
    }
  }

  // Récupérer les demandes d'un utilisateur
  Stream<List<AdmissionRequest>> getRequests(String userId) {
    return _client
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data
            .map((e) => AdmissionRequest.fromMap(e))
            .toList());
  }
}