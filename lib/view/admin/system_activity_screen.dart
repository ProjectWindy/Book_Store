import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SystemActivityScreen extends StatefulWidget {
  const SystemActivityScreen({super.key});

  @override
  State<SystemActivityScreen> createState() => _SystemActivityScreenState();
}

class _SystemActivityScreenState extends State<SystemActivityScreen> {
  String _selectedMetric = 'orders';
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _percentFormat = NumberFormat.percentPattern();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildMetricSelector(),
          Expanded(
            child: _buildSellerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMetricChip('Orders', 'orders'),
            _buildMetricChip('Revenue', 'revenue'),
            _buildMetricChip('Rating', 'rating'),
            _buildMetricChip('Growth', 'growth'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String metric) {
    final isSelected = _selectedMetric == metric;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedMetric = metric;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[700],
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.blue[700] : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSellerList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildSellerQuery(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final sellers = snapshot.data?.docs ?? [];
        if (sellers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No sellers found',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: sellers.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final seller = sellers[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: InkWell(
                onTap: () => _showSellerDetails(seller),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              (seller['name'] ?? 'S')[0].toUpperCase(),
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  seller['name'] ?? 'Unknown Seller',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Member since ${_formatDate(seller['joinedAt'])}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildMetricValue(seller),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPerformanceIndicators(seller),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricValue(Map<String, dynamic> seller) {
    switch (_selectedMetric) {
      case 'orders':
        return _buildStatChip(
          '${seller['totalOrders'] ?? 0}',
          Icons.shopping_cart,
          Colors.blue,
        );
      case 'revenue':
        return _buildStatChip(
          _currencyFormat.format(seller['totalRevenue'] ?? 0),
          Icons.attach_money,
          Colors.green,
        );
      case 'rating':
        return _buildStatChip(
          '${(seller['rating'] ?? 0.0).toStringAsFixed(1)} ★',
          Icons.star,
          Colors.amber,
        );
      case 'growth':
        final growth = seller['monthlyGrowth'] ?? 0.0;
        return _buildStatChip(
          _percentFormat.format(growth),
          growth >= 0 ? Icons.trending_up : Icons.trending_down,
          growth >= 0 ? Colors.green : Colors.red,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatChip(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicators(Map<String, dynamic> seller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPerformanceIndicator(
          'Orders',
          seller['totalOrders'] ?? 0,
          seller['orderTarget'] ?? 100,
          Colors.blue,
        ),
        _buildPerformanceIndicator(
          'Revenue',
          seller['totalRevenue'] ?? 0,
          seller['revenueTarget'] ?? 10000,
          Colors.green,
        ),
        _buildPerformanceIndicator(
          'Rating',
          (seller['rating'] ?? 0) * 20, // Convert 5-star to percentage
          90, // Target: 4.5 stars
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicator(
      String label, double value, double target, Color color) {
    final progress = (value / target).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 8,
              ),
              Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showSellerDetails(Map<String, dynamic> seller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                seller['name'] ?? 'Unknown Seller',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailSection('Performance Metrics', [
                _buildDetailRow(
                    'Total Orders', '${seller['totalOrders'] ?? 0}'),
                _buildDetailRow('Total Revenue',
                    _currencyFormat.format(seller['totalRevenue'] ?? 0)),
                _buildDetailRow('Average Order Value',
                    _currencyFormat.format(seller['averageOrderValue'] ?? 0)),
                _buildDetailRow('Rating', '${seller['rating'] ?? 0.0} / 5.0'),
                _buildDetailRow('Monthly Growth',
                    _percentFormat.format(seller['monthlyGrowth'] ?? 0)),
              ]),
              const SizedBox(height: 20),
              _buildDetailSection('Customer Satisfaction', [
                _buildDetailRow('On-time Delivery Rate',
                    _percentFormat.format(seller['onTimeDeliveryRate'] ?? 0)),
                _buildDetailRow('Return Rate',
                    _percentFormat.format(seller['returnRate'] ?? 0)),
                _buildDetailRow('Customer Satisfaction',
                    _percentFormat.format(seller['satisfaction'] ?? 0)),
              ]),
              const SizedBox(height: 20),
              _buildDetailSection('Account Status', [
                _buildDetailRow(
                    'Member Since', _formatDate(seller['joinedAt'])),
                _buildDetailRow(
                    'Last Active', _formatDate(seller['lastActive'])),
                _buildDetailRow(
                    'Account Status', seller['status'] ?? 'Unknown'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildSellerQuery() {
    var query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'seller');

    switch (_selectedMetric) {
      case 'orders':
        query = query.orderBy('totalOrders', descending: true);
        break;
      case 'revenue':
        query = query.orderBy('totalRevenue', descending: true);
        break;
      case 'rating':
        query = query.orderBy('rating', descending: true);
        break;
      case 'growth':
        query = query.orderBy('monthlyGrowth', descending: true);
        break;
    }

    return query.snapshots();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      return DateFormat('MMM d, yyyy').format(timestamp.toDate());
    }
    return 'Invalid date';
  }
}
