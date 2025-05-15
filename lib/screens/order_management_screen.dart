import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/order_model.dart' as models;

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedStatus = 'pending';
  final List<String> _statusOptions = const [
    'pending',
    'paid',
    'delivered',
    'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _statusOptions.contains(_selectedStatus)
                  ? _selectedStatus
                  : _statusOptions[0],
              decoration: const InputDecoration(
                labelText: 'Trạng thái đơn hàng',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status == 'pending'
                            ? 'Chờ xử lý'
                            : status == 'paid'
                                ? 'Đã thanh toán'
                                : status == 'delivered'
                                    ? 'Đã giao hàng'
                                    : 'Đã hủy'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<models.Order>>(
              stream: _paymentService.getOrdersByStatus(_selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final orders = snapshot.data!;

                if (orders.isEmpty) {
                  return const Center(
                    child: Text('Không có đơn hàng nào'),
                  );
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text('Đơn hàng #${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Tổng tiền: ${order.totalAmount.toStringAsFixed(0)}đ'),
                            Text(
                                'Phương thức thanh toán: ${order.paymentMethod}'),
                            Text('Địa chỉ giao hàng: ${order.shippingAddress}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'update_status':
                                await _updateOrderStatus(order);
                                break;
                              case 'view_details':
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'update_status',
                              child: Text('Cập nhật trạng thái'),
                            ),
                            const PopupMenuItem(
                              value: 'view_details',
                              child: Text('Xem chi tiết'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(models.Order order) async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật trạng thái'),
        content: DropdownButtonFormField<String>(
          value: _statusOptions.contains(order.status)
              ? order.status
              : _statusOptions[0],
          items: _statusOptions
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status == 'pending'
                        ? 'Chờ xử lý'
                        : status == 'paid'
                            ? 'Đã thanh toán'
                            : status == 'delivered'
                                ? 'Đã giao hàng'
                                : 'Đã hủy'),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              Navigator.of(context).pop(value);
            }
          },
        ),
      ),
    );

    if (status != null) {
      try {
        await _paymentService.updatePaymentStatus(order.id, status);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}
