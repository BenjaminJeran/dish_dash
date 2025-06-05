import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String recipeId;
  final String commentText;
  final String? userName; 

  const Comment({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.recipeId,
    required this.commentText,
    this.userName,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'],
      recipeId: map['recipe_id'],
      commentText: map['comment_text'],
      userName: (map['users'] as Map<String, dynamic>?)?['name'],
    );
  }

  @override
  List<Object?> get props => [id, createdAt, userId, recipeId, commentText, userName];
}