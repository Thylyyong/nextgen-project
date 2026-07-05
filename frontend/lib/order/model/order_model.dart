import 'package:equatable/equatable.dart';
import 'package:nextgen/auth/model/auth_model.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.userId,
    this.user,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final UserModel? user;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        totalAmount: (json['total_amount'] as num).toDouble(),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        if (user != null) 'user': user!.toJson(),
        'total_amount': totalAmount,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, userId, user, totalAmount, status, createdAt];
}

class OrderListResponse {
  const OrderListResponse({required this.data, required this.total});

  final List<Order> data;
  final int total;

  factory OrderListResponse.fromJson(Map<String, dynamic> json) =>
      OrderListResponse(
        data: (json['data'] as List<dynamic>)
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
      );
}
