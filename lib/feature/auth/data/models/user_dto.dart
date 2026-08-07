class UserDTO {
  final String userId;
  final String name;
  final String email;
  final String role;

  UserDTO({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      userId: (json['user_id'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? 'PATIENT') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
