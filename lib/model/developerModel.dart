class DeveloperModel {
  final String id;
  final String name;
  final String email;
  final String message;
  String response;

  DeveloperModel({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    this.response = '', // ✅ default empty string
  });

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "email": email, "message": message};
  }
}
