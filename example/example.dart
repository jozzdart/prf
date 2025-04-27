import 'package:flutter/material.dart';
import 'package:prf/prf.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Define variables (globally if you like)
  final username = Prf<String>('username');
  final highScore = Prf<int>('high_score', defaultValue: 0);

  final currentUser = PrfJson<User>(
    'current_user',
    fromJson: (json) => User.fromJson(json),
    toJson: (user) => user.toJson(),
  );

  // Example usage
  await username.set('Alice');
  await highScore.set(1200);
  await currentUser.set(User(id: 1, name: 'Alice', email: 'alice@example.com'));

  //final savedName = await username.getOrFallback('Guest');
  //final score = await highScore.getOrFallback(0);
  //final user = await currentUser.get();
}

// Simple model for PrfJson demo
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
