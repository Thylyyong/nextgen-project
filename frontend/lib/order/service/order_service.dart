import 'package:nextgen/core/network/api_client.dart';
import 'package:nextgen/order/model/order_model.dart';

class OrderService {
  const OrderService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// Creates a new order.
  Future<Order> createOrder(double totalAmount) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/orders',
      data: {'total_amount': totalAmount},
    );
    return Order.fromJson(response.data!);
  }

  /// Fetches orders for the current user.
  Future<OrderListResponse> getMyOrders() async {
    final response = await _api.get<Map<String, dynamic>>('/orders');
    return OrderListResponse.fromJson(response.data!);
  }

  /// Fetches a single order by ID.
  Future<Order> getOrderById(int id) async {
    final response = await _api.get<Map<String, dynamic>>('/orders/$id');
    return Order.fromJson(response.data!);
  }

  /// Updates the status of an order.
  Future<void> updateOrderStatus(int id, String status) async {
    await _api.put<dynamic>(
      '/orders/$id/status',
      data: {'status': status},
    );
  }
}
