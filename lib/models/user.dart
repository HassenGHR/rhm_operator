class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  factory User.fromFirebase(dynamic user) {
    return User(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
    );
  }
}
