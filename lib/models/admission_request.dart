import 'dart:convert';
import 'package:equatable/equatable.dart';

class AdmissionRequest extends Equatable {
  final String? id;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String? birthDate;
  final String program;
  final String domain;
  final bool hasScholarship;
  final String status;
  final Map<String, String> documents; // {nom_fichier: url_public}
  final String submissionDate;
  final String? decisionDate;
  final String? comments;

  AdmissionRequest({
    this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.birthDate,
    required this.domain,
    required this.program,
    this.hasScholarship = false,
    this.status = 'pending',
    required this.documents,
    required this.submissionDate,
    this.decisionDate,
    this.comments,
  });

  factory AdmissionRequest.fromMap(Map<String, dynamic> map) {
    return AdmissionRequest(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      birthDate: map['birth_date']?.toString(),
      domain: map['domain']?.toString() ?? '',
      program: map['program']?.toString() ?? '',
      hasScholarship: map['has_scholarship'] as bool? ?? false,
      status: map['status']?.toString() ?? 'pending',
      documents: _parseDocuments(map['documents']),
      submissionDate: map['submission_date']?.toString() ?? '',
      decisionDate: map['decision_date']?.toString(),
      comments: map['comments']?.toString(),
    );
  }

  static Map<String, String> _parseDocuments(dynamic docs) {
    if (docs == null) return {};
    if (docs is Map) return Map<String, String>.from(docs);
    if (docs is String) {
      try {
        return Map<String, String>.from(json.decode(docs));
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'birth_date': birthDate,
      'domain': domain,
      'program': program,
      'has_scholarship': hasScholarship,
      'status': status,
      'documents': json.encode(documents), // Stockage en JSON pour Supabase
      'submission_date': submissionDate,
      'decision_date': decisionDate,
      'comments': comments,
    };
  }

  AdmissionRequest copyWith({
    String? status,
    String? decisionDate,
    String? comments,
  }) {
    return AdmissionRequest(
      id: id,
      userId: userId,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      birthDate: birthDate,
      domain: domain,
      program: program,
      hasScholarship: hasScholarship,
      status: status ?? this.status,
      documents: documents,
      submissionDate: submissionDate,
      decisionDate: decisionDate ?? this.decisionDate,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    email,
    phone,
    address,
    birthDate,
    program,
    hasScholarship,
    status,
    documents,
    submissionDate,
    decisionDate,
    comments,
  ];
}
