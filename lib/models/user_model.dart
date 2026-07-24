class UserModel {
  final String uid;
  final String displayName;
  final String username;
  final String profileImageUrl;
  final String bio;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.profileImageUrl,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
  });

  // Konvèti done Firestore (Map) an objè UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      bio: map['bio'] ?? '',
      followersCount: (map['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (map['followingCount'] as num?)?.toInt() ?? 0,
    );
  }

  // Metòd pou konvèti objè a an Map pou voye l nan Firestore
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

  // Metòd pou modifye yon pati nan itilizatè a san kreye yon nouvo objè nan zewo
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? username,
    String? profileImageUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}