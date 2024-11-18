/// A placeholder class that represents an entity or model.
class UserEntity {
  UserEntity({
    this.userId = 0,
    this.userName = '',
    this.avatarUrl = '',
    this.gender = '',
    this.birthday = '',
    DateTime? createDate,
  }) : createDate = createDate ?? DateTime.now();

  final int userId;
  final String userName;
  final String avatarUrl;
  final String? gender;
  final String? birthday;
  final DateTime createDate;

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['userId'],
      userName: json['userName'],
      avatarUrl: json['avatarUrl'],
      gender: json['gender'],
      birthday: json['birthday'],
      createDate: DateTime.parse(json['createDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'gender':gender,
      'birthday': birthday,
      'createDate': createDate.toIso8601String(),
    };
  }
}

class MessageEntity {
  MessageEntity({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.mediaUrl,
    DateTime? createDate,
  }) : createDate = createDate ?? DateTime.now();

  final int messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final String mediaUrl;
  final DateTime createDate;

  // fromJson 构造函数
  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      messageId: json['messageId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      createDate: DateTime.parse(json['createDate']),
    );
  }

  // toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'mediaUrl': mediaUrl,
      'createDate': createDate.toIso8601String(),
    };
  }
}
