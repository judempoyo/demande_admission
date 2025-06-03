import 'package:demande_admission/models/admission_request.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  Future<void> saveRequest(AdmissionRequest request) async {
    final response = await _client
        .from('admission_requests')
        .insert(request.toMap())
        .then((_) => null, onError: (e, _) => e);

    if (response != null) {
      debugPrint('Erreur silencieuse: $response');
    }
  }

  Stream<List<AdmissionRequest>> getRequests(String userId) {
    return _client
        .from('admission_requests')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data.map(AdmissionRequest.fromMap).toList());
  }

  Future<void> updateRequest(AdmissionRequest request) async {
    final response = await _client
        .from('admission_requests')
        .update(request.toMap())
        .eq('id', request.id!)
        .then((_) => null, onError: (e, _) => e);

    if (response != null) {
      debugPrint('Erreur silencieuse: $response');
      throw response;
    }
  }

  Future<void> deleteRequest(String id) async {
    final response = await _client
        .from('admission_requests')
        .delete()
        .eq('id', id)
        .then((_) => null, onError: (e, _) => e);

    if (response != null) {
      debugPrint('Erreur silencieuse: $response');
      throw response;
    }
  }
}
