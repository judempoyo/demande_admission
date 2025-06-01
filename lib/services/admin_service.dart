import 'package:demande_admission/models/admission_request.dart';
import 'package:demande_admission/models/user.dart' as userModel;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  // Récupérer tous les utilisateurs
  Stream<List<userModel.User>> getAllUsers() {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map(userModel.User.fromMap).toList());
  }

  // Récupérer toutes les demandes d'admission (version corrigée)
  Stream<List<AdmissionRequest>> getAllAdmissionRequests({
    String? statusFilter,
  }) {
    // Créer une requête de base
    final query = _client.from('admission_requests').select();

    // Appliquer le filtre si nécessaire
    if (statusFilter != null) {
      query.eq('status', statusFilter);
    }

    // Utiliser .stream() directement sur la table avec les paramètres
    return _client
        .from('admission_requests')
        .stream(primaryKey: ['id'])
        .order('submission_date', ascending: false)
        .map((data) {
          // Filtrer les données si nécessaire
          final filteredData =
              statusFilter != null
                  ? data
                      .where((item) => item['status'] == statusFilter)
                      .toList()
                  : data;

          return filteredData.map(AdmissionRequest.fromMap).toList();
        });
  }

  // Alternative plus simple pour les requêtes filtrées
  Future<List<AdmissionRequest>> getFilteredAdmissionRequests({
    String? statusFilter,
  }) async {
    try {
      var query = _client.from('admission_requests').select();

      if (statusFilter != null) {
        query = query.eq('status', statusFilter);
      }

      final List<Map<String, dynamic>> data = await query
          .order('submission_date', ascending: false)
          .then((response) => (response as List).cast<Map<String, dynamic>>());

      return data.map(AdmissionRequest.fromMap).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des demandes: $e');
      throw Exception('Échec de la récupération des demandes: $e');
    }
  }

  // Mettre à jour le statut d'une demande
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? comments,
  }) async {
    final updates = {
      'status': status,
      'decision_date': DateTime.now().toIso8601String(),
      if (comments != null) 'comments': comments,
    };

    final response = await _client
        .from('admission_requests')
        .update(updates)
        .eq('id', requestId)
        .then((_) => null, onError: (e, _) => e);

    if (response != null) {
      debugPrint('Erreur lors de la mise à jour: $response');
      throw Exception('Échec de la mise à jour');
    }
  }

  // Mettre à jour le rôle d'un utilisateur
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    final response = await _client
        .from('profiles')
        .update({'role': newRole})
        .eq('id', userId)
        .then((_) => null, onError: (e, _) => e);

    if (response != null) {
      debugPrint('Erreur lors de la mise à jour du rôle: $response');
      throw Exception('Échec de la mise à jour du rôle');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    final response = await _client
        .from('profiles')
        .delete()
        .eq('id', userId)
        .then((_) => null, onError: (e, _) => e);

    if (response != null) {
      debugPrint('Erreur lors de la suppression: $response');
      throw Exception('Échec de la suppression de l\'utilisateur');
    }
  }

  // Statistiques pour le dashboard admin
  Future<Map<String, dynamic>> getAdminStatistics() async {
    final totalRequests = await _client
        .from('admission_requests')
        .select('count')
        .single()
        .then((data) => data['count'] as int);

    final pendingRequests = await _client
        .from('admission_requests')
        .select('count')
        .eq('status', 'pending')
        .single()
        .then((data) => data['count'] as int);

    final totalUsers = await _client
        .from('profiles')
        .select('count')
        .single()
        .then((data) => data['count'] as int);

    return {
      'totalRequests': totalRequests,
      'pendingRequests': pendingRequests,
      'totalUsers': totalUsers,
    };
  }
}
