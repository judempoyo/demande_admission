import 'package:demande_admission/models/admission_request.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Sauvegarder une demande
  Future<void> saveRequest(AdmissionRequest request) async {
    try {
      final newRequestRef = _dbRef.child('requests').push();
      await newRequestRef.set(request.toMap());
    } catch (e) {
      throw 'Erreur de sauvegarde: $e';
    }
  }

  // Récupérer les demandes d'un utilisateur
  Stream<List<AdmissionRequest>> getRequests(String userId) {
    return _dbRef
        .child('requests')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
          final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
          if (data == null) return [];

          return data.entries.map((e) {
            return AdmissionRequest.fromMap({
              'id': e.key,
              ...Map<String, dynamic>.from(e.value),
            });
          }).toList();
        });
  }
}
