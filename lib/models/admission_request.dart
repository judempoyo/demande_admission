class AdmissionRequest {
  final String? id;
  final String userId;
  final String program;
  final String status;
  final Map<String, String> documents; // {nom_fichier: url}
  final String submissionDate;

  AdmissionRequest({
    this.id,
    required this.userId,
    required this.program,
    this.status = 'pending',
    required this.documents,
    required this.submissionDate,
  });

  factory AdmissionRequest.fromMap(Map<String, dynamic> map) {
    return AdmissionRequest(
      id: map['id'],
      userId: map['userId'],
      program: map['program'],
      status: map['status'] ?? 'pending',
      documents: Map<String, String>.from(map['documents'] ?? {}),
      submissionDate: map['submissionDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'program': program,
      'status': status,
      'documents': documents,
      'submissionDate': submissionDate,
    };
  }
}
