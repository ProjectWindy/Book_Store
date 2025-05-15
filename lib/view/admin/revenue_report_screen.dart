import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  String _selectedPeriod = 'week';
  final _currencyFormat =
      NumberFormat.currency(symbol: '₫', locale: 'vi_VN', decimalDigits: 0);
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Add tab controller
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Add cached data
  Map<String, dynamic> _cachedData = {};
  bool _isInitialLoad = true;

  // Add methods to load data for each tab separately
  Future<void> _loadOverviewData() async {
    if (_cachedData['overview'] != null && !_isInitialLoad) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _cachedData['overview'] = snapshot;
    } catch (e) {
      print('Error loading overview data: $e');
    }
  }

  Future<void> _loadChartData() async {
    if (_cachedData['chart'] != null && !_isInitialLoad) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _cachedData['chart'] = snapshot;
    } catch (e) {
      print('Error loading chart data: $e');
    }
  }

  Future<void> _loadTopSellersData() async {
    if (_cachedData['topSellers'] != null && !_isInitialLoad) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('orders').limit(50).get();

      _cachedData['topSellers'] = snapshot;
    } catch (e) {
      print('Error loading top sellers data: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load only data for the current tab to start
      switch (_currentTabIndex) {
        case 0:
          await _loadOverviewData();
          break;
        case 1:
          await _loadChartData();
          break;
        case 2:
          await _loadTopSellersData();
          break;
      }

      _isInitialLoad = false;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Load data when tab changes
  void _onTabChanged() {
    // Load data for the current tab if not already loaded
    switch (_currentTabIndex) {
      case 0:
        _loadOverviewData();
        break;
      case 1:
        _loadChartData();
        break;
      case 2:
        _loadTopSellersData();
        break;
    }

    // Giải phóng bộ nhớ của tab không sử dụng
    switch (_currentTabIndex) {
      case 0:
        if (_cachedData.containsKey('chart')) {
          // Giữ lại bộ nhớ đệm cho tab hiện tại và tab kế tiếp
          if (_cachedData.containsKey('topSellers')) {
            _cachedData.remove('topSellers');
          }
        }
        break;
      case 1:
        if (_cachedData.containsKey('topSellers')) {
          if (_cachedData.containsKey('overview')) {
            _cachedData.remove('overview');
          }
        }
        break;
      case 2:
        if (_cachedData.containsKey('overview')) {
          if (_cachedData.containsKey('chart')) {
            _cachedData.remove('chart');
          }
        }
        break;
    }
  }

  @override
  bool get wantKeepAlive =>
      false; // Không giữ lại trạng thái khi không hiển thị

  @override
  void initState() {
    super.initState();

    // Theo dõi trạng thái ứng dụng để giải phóng bộ nhớ khi cần
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
          _onTabChanged();
        });
      }
    });

    // Thiết lập cache size hợp lý cho ứng dụng
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 30 << 20; // 30 MB

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _animationController.forward();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Xóa cache khi ứng dụng vào nền
    if (state == AppLifecycleState.paused) {
      _cachedData.clear();
      PaintingBinding.instance.imageCache.clear();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();

    // Clear image cache khi rời khỏi màn hình
    if (!mounted) {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Cần thiết cho AutomaticKeepAliveClientMixin

    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;
    final bodyPadding = isSmallScreen ? 0.0 : 8.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 80,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: Colors.white,
              elevation: innerBoxIsScrolled ? 2 : 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Báo Cáo Doanh Thu',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade800,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blueGrey),
                  onPressed: _loadData,
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blueGrey.shade800,
                  unselectedLabelColor: Colors.blueGrey.shade400,
                  indicatorColor: Colors.blueGrey.shade700,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: "Tổng Quan", icon: Icon(Icons.dashboard)),
                    Tab(text: "Biểu Đồ", icon: Icon(Icons.bar_chart)),
                    Tab(text: "Sách Bán Chạy", icon: Icon(Icons.book)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                ),
              )
            : Column(
                children: [
                  _buildSimpleFilters(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Ngăn chặn scroll ngang để cải thiện hiệu suất
                      children: [
                        // Tab 1: Overview
                        _buildTabContent(
                          child: _buildRevenueOverview(),
                          padding: EdgeInsets.all(bodyPadding + 8.0),
                        ),
                        // Tab 2: Chart
                        _buildTabContent(
                          child: _buildRevenueChart(),
                          padding: EdgeInsets.all(bodyPadding + 8.0),
                        ),
                        // Tab 3: Top sellers
                        _buildTabContent(
                          child: _buildTopSellers(),
                          padding: EdgeInsets.all(bodyPadding + 8.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Helper method to consistently style tab content
  Widget _buildTabContent(
      {required Widget child, required EdgeInsets padding}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      child: child,
    );
  }

  Widget _buildSimpleFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.blueGrey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(
                    start: _startDate,
                    end: _endDate,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.blueGrey.shade700,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.blueGrey.shade800,
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked.start;
                    _endDate = picked.end;
                    _selectedPeriod = 'custom';
                    // Clear cached data to reload with new date range
                    _cachedData.clear();
                    _loadData();
                  });
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.blueGrey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(_endDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blueGrey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildSimplePeriodFilter('Tuần', 'week'),
          const SizedBox(width: 8),
          _buildSimplePeriodFilter('Tháng', 'month'),
        ],
      ),
    );
  }

  Widget _buildSimplePeriodFilter(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          // Update date range based on period
          _endDate = DateTime.now();
          if (period == 'week') {
            _startDate = _endDate.subtract(const Duration(days: 7));
          } else if (period == 'month') {
            _startDate =
                DateTime(_endDate.year, _endDate.month - 1, _endDate.day);
          }
          // Clear cached data to reload with new date range
          _cachedData.clear();
          _loadData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.blueGrey.shade700 : Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.blueGrey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueOverview() {
    return FutureBuilder<void>(
      future: _loadOverviewData(),
      builder: (context, _) {
        if (_cachedData['overview'] == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            ),
          );
        }

        final ordersSnapshot = _cachedData['overview'] as QuerySnapshot;
        final orders = ordersSnapshot.docs;
        final totalRevenue = orders.fold<double>(
          0,
          (sum, order) => sum + ((order.data() as Map)['totalAmount'] ?? 0),
        );
        final totalOrders = orders.length;
        final averageOrderValue =
            totalOrders > 0 ? totalRevenue / totalOrders : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Tổng Quan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            Row(
              children: [
                _buildStatCard(
                  'Tổng Doanh Thu',
                  _currencyFormat.format(totalRevenue),
                  Icons.attach_money,
                  const Color(0xFF66BB6A),
                  const Color(0xFFE8F5E9),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Tổng Đơn Hàng',
                  totalOrders.toString(),
                  Icons.shopping_cart,
                  const Color(0xFF5C6BC0),
                  const Color(0xFFE8EAF6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Trung Bình/Đơn',
                  _currencyFormat.format(averageOrderValue),
                  Icons.analytics,
                  const Color(0xFFFF7043),
                  const Color(0xFFFBE9E7),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  'Tỉ lệ mua hàng',
                  '${((orders.length / 100) * 3.7).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  const Color(0xFF7E57C2),
                  const Color(0xFFEDE7F6),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blueGrey.shade50,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return FutureBuilder<void>(
      future: _loadChartData(),
      builder: (context, _) {
        // Kiểm tra dữ liệu đã được tải chưa
        if (_cachedData['chart'] == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            ),
          );
        }

        final ordersSnapshot = _cachedData['chart'] as QuerySnapshot;
        final orders = ordersSnapshot.docs;
        if (orders.isEmpty) {
          return _buildEmptyDataView(
              'Không có dữ liệu cho khoảng thời gian này');
        }

        final revenueData = _processRevenueData(orders);
        if (revenueData.length < 2) {
          return _buildEmptyDataView('Không đủ dữ liệu để vẽ biểu đồ');
        }

        // Tính toán các thống kê cần thiết
        final double totalRevenue =
            revenueData.fold(0.0, (sum, point) => sum + point.revenue);
        final double maxRevenue = revenueData.fold(
            0.0, (max, point) => point.revenue > max ? point.revenue : max);
        final double minRevenue = revenueData.fold(double.infinity,
            (min, point) => point.revenue < min ? point.revenue : min);
        final double averageRevenue = totalRevenue / revenueData.length;

        // Chuẩn bị dữ liệu spot cho biểu đồ
        final List<FlSpot> spots = revenueData
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.revenue))
            .toList();

        // Màu sắc chủ đạo
        final primaryColor = const Color.fromARGB(221, 202, 159, 159);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và tổng doanh thu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doanh Thu ',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Từ ${DateFormat('dd/MM').format(_startDate)} đến ${DateFormat('dd/MM').format(_endDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey.shade500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _currencyFormat.format(totalRevenue),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Thẻ thống kê
              Row(
                children: [
                  _buildStatItem(
                    title: 'Cao nhất',
                    value: _currencyFormat.format(maxRevenue),
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  _buildStatItem(
                    title: 'Trung bình',
                    value: _currencyFormat.format(averageRevenue),
                    icon: Icons.timeline,
                    color: Colors.amber.shade700,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Biểu đồ
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey.shade800,
                        tooltipRoundedRadius: 10,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = revenueData[spot.x.toInt()].date;
                            return LineTooltipItem(
                              DateFormat('dd/MM (E)').format(date),
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '\n${_currencyFormat.format(spot.y)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxRevenue / 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: revenueData.length > 10 ? 2 : 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < revenueData.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  DateFormat('dd/MM')
                                      .format(revenueData[value.toInt()].date),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 46,
                          interval: maxRevenue / 5,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                _formatChartValue(value),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                        left: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    minX: 0,
                    maxX: revenueData.length - 1.0,
                    minY: 0,
                    maxY: maxRevenue * 1.2,
                    lineBarsData: [
                      // Đường trung bình
                      LineChartBarData(
                        spots: List.generate(
                          revenueData.length,
                          (i) => FlSpot(i.toDouble(), averageRevenue),
                        ),
                        isCurved: false,
                        color: Colors.orange.withOpacity(0.5),
                        barWidth: 1,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        dashArray: const [5, 5],
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Đường chính
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        preventCurveOverShooting: true,
                        color: primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            if (spot.y == maxRevenue) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.green,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            }
                            if (spot.y == minRevenue && spot.y > 0) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.orange,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: 3.5,
                              color: primaryColor,
                              strokeWidth: 1.5,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.4),
                              primaryColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Ghi chú
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: Colors.blueGrey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đường nét đứt thể hiện doanh thu trung bình trong khoảng thời gian',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị khi không có dữ liệu
  Widget _buildEmptyDataView(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 70,
            color: Colors.blueGrey.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.blueGrey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng chọn khoảng thời gian khác',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.blueGrey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị các thống kê
  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blueGrey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChartValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}Tr ₫';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return '${value.toInt()} ₫';
  }

  Widget _buildTopSellers() {
    return FutureBuilder<void>(
      future: _loadTopSellersData(),
      builder: (context, _) {
        if (_cachedData['topSellers'] == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            ),
          );
        }

        final ordersSnapshot = _cachedData['topSellers'] as QuerySnapshot;
        final orders = ordersSnapshot.docs;

        // Create map to count sales for each book - optimized version
        Map<String, BookSaleInfo> bookSales = {};

        // Limit the number of orders processed
        final ordersToProcess = orders.take(50).toList();

        // Process limited number of orders
        for (var doc in ordersToProcess) {
          var orderData = doc.data() as Map<String, dynamic>;
          var items = orderData['items'] as List<dynamic>;

          // Limit items per order to process
          final itemsToProcess = items.take(10).toList();

          // Process each item in order
          for (var item in itemsToProcess) {
            var bookId = item['bookId'] as String;
            var quantity = item['quantity'] as int;
            var price = (item['price'] as num).toDouble();
            var title = item['title'] as String;

            // Xử lý trường hợp hình ảnh
            var cover = '';
            if (item.containsKey('cover')) {
              cover = item['cover'] as String;
            } else if (item.containsKey('showImage')) {
              cover = item['showImage'] as String;
            } else if (item.containsKey('image')) {
              cover = item['image'] as String;
            }

            var author = item['author'] as String;

            if (bookSales.containsKey(bookId)) {
              bookSales[bookId]!.totalQuantity += quantity;
              bookSales[bookId]!.totalRevenue += (quantity * price);
              bookSales[bookId]!.orderCount += 1;
            } else {
              bookSales[bookId] = BookSaleInfo(
                bookId: bookId,
                title: title,
                author: author,
                cover: cover,
                totalQuantity: quantity,
                totalRevenue: quantity * price,
                orderCount: 1,
              );
            }
          }
        }

        // Convert map to list and sort by revenue
        var sortedBooks = bookSales.values.toList()
          ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

        // Get top 5 best selling books
        var topBooks = sortedBooks.take(5).toList();

        if (topBooks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'No sales data available',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sách Bán Chạy Nhất',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Top ${topBooks.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...topBooks.asMap().entries.map((entry) {
                int index = entry.key;
                var book = entry.value;
                return _buildTopSellerItem(book, index);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSellerItem(BookSaleInfo book, int index) {
    final badgeColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      Colors.blueGrey.shade300, // Other ranks
      Colors.blueGrey.shade300,
    ];

    final badgeColor = index < badgeColors.length
        ? badgeColors[index]
        : Colors.blueGrey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blueGrey.shade50,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with placeholder
          SizedBox(
            width: 80,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildBookImage(book.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        color: index == 0 ? Colors.black87 : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Title
                Text(
                  book.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Author
                Text(
                  'by ${book.author}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.blueGrey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSimpleMetric(
                      'Doanh Thu',
                      _formatCompactValue(book.totalRevenue),
                      Colors.green.shade700,
                    ),
                    _buildSimpleMetric(
                      'Đã Bán',
                      '${book.totalQuantity}',
                      Colors.blue.shade700,
                    ),
                    _buildSimpleMetric(
                      'Đơn Hàng',
                      '${book.orderCount}',
                      Colors.orange.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.blueGrey.shade400,
          ),
        ),
      ],
    );
  }

  String _formatCompactValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  List<RevenuePoint> _processRevenueData(List<QueryDocumentSnapshot> orders) {
    // Limit the data points to improve performance
    final int maxDataPoints = 14; // Show at most 2 weeks of data
    final Map<DateTime, double> dailyRevenue = {};

    // Calculate the day range based on the actual data or limit to maxDataPoints
    int daysBetween = _endDate.difference(_startDate).inDays + 1;
    daysBetween = daysBetween > maxDataPoints ? maxDataPoints : daysBetween;

    // Adjust startDate if needed
    final actualStartDate = daysBetween < maxDataPoints
        ? _startDate
        : _endDate.subtract(Duration(days: maxDataPoints - 1));

    // Create a map with dates in range (limited to maxDataPoints)
    for (int i = 0; i < daysBetween; i++) {
      final date = DateTime(
          actualStartDate.year, actualStartDate.month, actualStartDate.day + i);
      dailyRevenue[date] = 0;
    }

    // Process only orders within the date range we're displaying
    for (var order in orders) {
      final data = order.data() as Map<String, dynamic>;
      final date = (data['createdAt'] as Timestamp).toDate();
      final dateKey = DateTime(date.year, date.month, date.day);

      // Only process if the date is within our filtered range
      if (dailyRevenue.containsKey(dateKey)) {
        dailyRevenue[dateKey] =
            (dailyRevenue[dateKey] ?? 0) + (data['totalAmount'] ?? 0);
      }
    }

    final sortedDates = dailyRevenue.keys.toList()..sort();
    return sortedDates
        .map((date) => RevenuePoint(date, dailyRevenue[date]!))
        .toList();
  }

  // Thêm phương thức mới để xử lý nhiều loại hình ảnh
  Widget _buildBookImage(String imagePath) {
    // Kiểm tra nếu là đường dẫn assets
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 80,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.blueGrey.shade50,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.blueGrey.shade200,
            ),
          );
        },
      );
    }
    // Kiểm tra nếu là đường dẫn hợp lệ
    else if (imagePath.isNotEmpty) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        cacheWidth: 160,
        cacheHeight: 240,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.blueGrey.shade50,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.blueGrey.shade50,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.blueGrey.shade200,
            ),
          );
        },
      );
    }
    // Trường hợp không có hình ảnh
    else {
      return Container(
        color: Colors.blueGrey.shade50,
        child: Icon(
          Icons.book,
          color: Colors.blueGrey.shade200,
        ),
      );
    }
  }
}

class RevenuePoint {
  final DateTime date;
  final double revenue;

  RevenuePoint(this.date, this.revenue);
}

// Class để lưu thông tin bán hàng của mỗi cuốn sách
class BookSaleInfo {
  final String bookId;
  final String title;
  final String author;
  final String cover;
  int totalQuantity;
  double totalRevenue;
  int orderCount;

  BookSaleInfo({
    required this.bookId,
    required this.title,
    required this.author,
    required this.cover,
    this.totalQuantity = 0,
    this.totalRevenue = 0,
    this.orderCount = 0,
  });

  // Add factory constructor to limit data processing
  factory BookSaleInfo.fromOrder(
      String bookId, Map<String, dynamic> orderItem, int quantity) {
    final price = orderItem['price'] != null
        ? (orderItem['price'] as num).toDouble()
        : 0.0;

    // Xử lý trường hợp hình ảnh
    String cover = '';
    if (orderItem.containsKey('cover')) {
      cover = orderItem['cover'] as String;
    } else if (orderItem.containsKey('showImage')) {
      cover = orderItem['showImage'] as String;
    } else if (orderItem.containsKey('image')) {
      cover = orderItem['image'] as String;
    }

    return BookSaleInfo(
      bookId: bookId,
      title: orderItem['title'] ?? '',
      author: orderItem['author'] ?? '',
      cover: cover,
      totalQuantity: quantity,
      totalRevenue: quantity * price,
      orderCount: 1,
    );
  }
}

// Add this class at the end of the file
class SellerInfo {
  final String id;
  final String name;
  final String email;
  final double totalRevenue;
  final int totalOrders;

  SellerInfo({
    required this.id,
    required this.name,
    this.email = '',
    this.totalRevenue = 0,
    this.totalOrders = 0,
  });
}

// Add SliverAppBarDelegate for tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
