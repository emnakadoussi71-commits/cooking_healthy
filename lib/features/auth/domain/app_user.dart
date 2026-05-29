class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user' | 'admin' | 'nutritionist'
  final String? photoUrl;
  final UserProfile? profile;
  final int dailyCalorieTarget;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.profile,
    this.dailyCalorieTarget = 2000,
  });

  bool get isAdmin => role == 'admin';
  bool get isNutritionist => role == 'nutritionist';
  bool get hasProfile => profile != null;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      photoUrl: map['photoUrl'] as String?,
      dailyCalorieTarget: (map['dailyCalorieTarget'] as num?)?.toInt() ?? 2000,
      profile: map['profile'] != null
          ? UserProfile.fromMap(map['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': photoUrl,
        'dailyCalorieTarget': dailyCalorieTarget,
        'profile': profile?.toMap(),
      };
}

class UserProfile {
  final int age;
  final double weight; // kg
  final double height; // cm
  final String goal; // 'perdre' | 'maintenir' | 'prendre'
  final String dietType; // 'standard' | 'diabetique' | 'sans_gluten' | 'vegan'

  const UserProfile({
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    required this.dietType,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        age: (map['age'] as num?)?.toInt() ?? 0,
        weight: (map['weight'] as num?)?.toDouble() ?? 0,
        height: (map['height'] as num?)?.toDouble() ?? 0,
        goal: map['goal'] ?? 'maintenir',
        dietType: map['dietType'] ?? 'standard',
      );

  Map<String, dynamic> toMap() => {
        'age': age,
        'weight': weight,
        'height': height,
        'goal': goal,
        'dietType': dietType,
      };
}
