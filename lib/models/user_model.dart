class UserModel {
  final String uid;
  final String displayName;
  final String username;
  final String profileImageUrl;
  final String bio;
  final int followersCount;
  final int followingCount; // <--- Ajoute chan sa a

  UserModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.profileImageUrl,
    required this.bio,
    required this.followersCount,
    required this.followingCount, // <--- Ajoute nan constructor
  });

  // Konvèti done Firestore an object UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      bio: map['bio'] ?? '',
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0, // <--- Li nan map la
    );
  }

  // Metòd pou voye done yo nan Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }
}