class UserModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? avatar;
  String? bio;
  String? createdAt;
  String? updatedAt;
  int? isPremium;
  String? status;
  int? coins;


  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.isPremium,
    this.status,
    this.coins,
  });



  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isPremium: (json['is_premium'] == 1 || json['is_premium'] == '1' || json['is_premium'] == true || json['is_premium'] == 'true') ? 1 : 0,
      status: json['status']?.toString(),
      coins: json['coins'] != null ? int.tryParse(json['coins'].toString()) ?? 0 : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_premium': isPremium,
      'status': status,
      'coins': coins,
    };
  }
}

class AuthResponse {
  bool? success;
  String? message;
  UserModel? user;
  String? token;

  AuthResponse({
    this.success,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    UserModel? user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    
    // Eğer user objesi içinde status yoksa veya ana response'da farklı bir status varsa oradan al
    if (user != null && json['user_status'] != null) {
      user.status = json['user_status']?.toString();
    }
    
    bool? successValue;
    if (json['success'] is bool) {
      successValue = json['success'];
    } else if (json['success'] is String) {
      successValue = json['success'].toString().toLowerCase() == 'true' || json['success'] == '1';
    } else if (json['success'] is int) {
      successValue = json['success'] == 1;
    }

    return AuthResponse(
      success: successValue,
      message: json['message']?.toString(),
      user: user,
      token: json['token']?.toString(),
    );
  }
}
