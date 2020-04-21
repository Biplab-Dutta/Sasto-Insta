import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String bio;
  final String displayName;
  final String email;
  final String photoUrl;
  final String username;

  User({
    this.id,
    this.bio,
    this.displayName,
    this.email,
    this.photoUrl,
    this.username,
  });

  factory User.fromDocument(DocumentSnapshot userId) {
    return User(
      id: userId['id'],
      bio: userId['bio'],
      displayName: userId['displayName'],
      email: userId['email'],
      photoUrl: userId['photoUrl'],
      username: userId['username'],
    );
  }
}
