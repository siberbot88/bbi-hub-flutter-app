import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';

class Employment {
  final String id;
  final String userUuid;
  final String workshopUuid;
  final String code;
  final String? specialist;
  final String? jobdesk;
  final User? user;
  final Workshop? workshop;

  Employment({
    required this.id,
    required this.userUuid,
    required this.workshopUuid,
    required this.code,
    this.specialist,
    this.jobdesk,
    this.user,
    this.workshop,
  });

  factory Employment.fromJson(Map<String, dynamic> json) {
    return Employment(
      id: json['id'] as String,
      userUuid: json['user_uuid'] as String,
      workshopUuid: json['workshop_uuid'] as String,
      code: json['code'] as String,
      specialist: json['specialist'] as String?,
      jobdesk: json['jobdesk'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      workshop: json['workshop'] != null
          ? Workshop.fromJson(json['workshop'] as Map<String, dynamic>)
          : null,
    );
  }
}
