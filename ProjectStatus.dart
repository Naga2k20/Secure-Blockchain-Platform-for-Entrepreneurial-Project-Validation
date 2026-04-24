import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';


class EntrepreneurProjectStatus extends StatefulWidget {
  @override
  _EntrepreneurProjectStatusState createState() => _EntrepreneurProjectStatusState();
}

class _EntrepreneurProjectStatusState extends State<EntrepreneurProjectStatus> {
  Map<String, dynamic> _departmentStatus = {};
  Map<String, dynamic>? _projectData;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _hasData = false;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        await _fetchUserData();
        _listenToProjectStatus(); // instead of _fetchProjectStatus()
      } else {
        setState(() {
          _isLoading = false;
          _hasData = false;
        });
      }
    } catch (e) {
      print("Error initializing: $e");
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('Entrepreneurs').child(_userId);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        setState(() {
          _userData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

 /* Future<void> _fetchProjectStatus() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('business_ideas');

      final snapshot = await ref.orderByChild('ekey').equalTo(_userId).once();

      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map;

        // Get the first project (assuming one project per entrepreneur for now)
        final projectKey = data.keys.first;
        final project = Map<String, dynamic>.from(data[projectKey] as Map);

        setState(() {
          _projectData = project;
          _departmentStatus = Map<String, dynamic>.from(project['department_status'] ?? {});
          _hasData = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasData = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching project status: $e");
      setState(() {
        _hasData = false;
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }*/
  Future<void> _fetchProjectStatus() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('business_ideas');

      final event = await ref.orderByChild('ekey').equalTo(_userId).once();

      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);


        // Sort by timestamp (latest project)
        final sortedKeys = data.keys.toList()
          ..sort((a, b) {
            final aTime = data[a]['timestamp'] ?? 0;
            final bTime = data[b]['timestamp'] ?? 0;
            return bTime.compareTo(aTime);
          });

        final latestProject = Map<String, dynamic>.from(data[sortedKeys.first]);

        Map<String, dynamic> departmentStatus = {};

        // 🔥 HANDLE NEW STRUCTURE
        if (latestProject.containsKey('department_status')) {
          departmentStatus =
          Map<String, dynamic>.from(latestProject['department_status']);
        } else {
          // 🔥 CREATE DEFAULT DEPARTMENTS BASED ON STATUS
          String mainStatus = latestProject['status'] ?? 'pending';

          departmentStatus = {
            "Municipality": mainStatus,
            "Pollution Control": mainStatus,
            "Fire Safety": mainStatus,
            "Revenue Department": mainStatus,
          };
        }

        setState(() {
          _projectData = latestProject;
          _departmentStatus = departmentStatus;
          _hasData = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasData = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _hasData = false;
        _isLoading = false;
      });
    }
  }
  void _listenToProjectStatus() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('business_ideas');

    ref.orderByChild('ekey').equalTo(_userId).onValue.listen((event) {
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        final sortedKeys = data.keys.toList()
          ..sort((a, b) {
            final aTime = data[a]['timestamp'] ?? 0;
            final bTime = data[b]['timestamp'] ?? 0;
            return bTime.compareTo(aTime);
          });

        final latestProject =
        Map<String, dynamic>.from(data[sortedKeys.first]);

        Map<String, dynamic> departmentStatus = {};

        if (latestProject.containsKey('department_status')) {
          departmentStatus =
          Map<String, dynamic>.from(latestProject['department_status']);
        }

        setState(() {
          _projectData = latestProject;
          _departmentStatus = departmentStatus;
          _hasData = true;
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D936C), Color(0xFF1A5F7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading Project Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A5F7A),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please wait while we fetch your data',
            style: TextStyle(
              color: Color(0xFF5D6D7E),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 60,
              color: Color(0xFFB0BEC5),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'No Projects Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You haven\'t submitted any projects yet. Start by submitting your first business project.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF5D6D7E),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 30),
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D936C), Color(0xFF1A5F7A)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2D936C).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  // Navigate to project submission page
                },
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.white.withOpacity(0.2),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Submit First Project',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    if (_userData == null) return SizedBox();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D936C),
            Color(0xFF1A5F7A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.business_center_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData!['name']?.toString() ?? 'Entrepreneur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _userData!['email']?.toString() ?? 'No Email',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Entrepreneur',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              _buildUserDetailItem(
                icon: Icons.phone_rounded,
                label: 'Mobile',
                value: _userData!['mobile']?.toString() ?? 'N/A',
              ),
              SizedBox(width: 15),
              _buildUserDetailItem(
                icon: Icons.location_on_rounded,
                label: 'Address',
                value: _userData!['address']?.toString() ?? 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
                SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    if (_projectData == null) return SizedBox();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2D936C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: Color(0xFF2D936C),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Project Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_projectData!['status']?.toString() ?? 'pending'),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(_projectData!['status']?.toString() ?? 'pending'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildProjectDetailRow(
            label: 'Business Name',
            value: _projectData!['business_name']?.toString() ?? 'N/A',
          ),
          _buildProjectDetailRow(
            label: 'Project Location',
            value: _projectData!['location']?.toString() ?? 'N/A',
          ),
          _buildProjectDetailRow(
            label: 'District',
            value: _projectData!['district']?.toString() ?? 'N/A',
          ),
          _buildProjectDetailRow(
            label: 'Submitted On',
            value: _formatDate(_projectData!['date']?.toString()),
          ),
          if (_projectData!['blockchain_tx_hash'] != null)
            _buildProjectDetailRow(
              label: 'Blockchain TX',
              value: '${_projectData!['blockchain_tx_hash']?.toString().substring(0, 16)}...',
              isHash: true,
            ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailRow({
    required String label,
    required String value,
    bool isHash = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF5D6D7E),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isHash ? Color(0xFF3498DB) : Color(0xFF2C3E50),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String department, String status) {
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);
    String statusText = _getStatusText(status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                statusColor.withOpacity(0.05),
                statusColor.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (status == 'accepted')
                            Icon(Icons.verified_rounded, color: Color(0xFF2D936C), size: 16),
                          if (status == 'rejected')
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStatusSummary() {
    int acceptedCount = _departmentStatus.values.where((s) => s == 'accepted').length;
    int pendingCount = _departmentStatus.values.where((s) => s == 'pending').length;
    int rejectedCount = _departmentStatus.values.where((s) => s == 'rejected').length;
    int totalCount = _departmentStatus.length;
    double progress = totalCount > 0 ? acceptedCount / totalCount : 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FA),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A5F7A),
            ),
          ),
          SizedBox(height: 15),

          // Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: progress == 1
                            ? [Color(0xFF2D936C), Color(0xFF27AE60)]
                            : [Color(0xFF3498DB), Color(0xFF2980B9)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 15),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                count: acceptedCount,
                label: 'Approved',
                color: Color(0xFF2D936C),
              ),
              _buildStatCard(
                count: pendingCount,
                label: 'Pending',
                color: Color(0xFFF39C12),
              ),
              _buildStatCard(
                count: rejectedCount,
                label: 'Rejected',
                color: Color(0xFFE74C3C),
              ),
            ],
          ),
          SizedBox(height: 15),

          // Percentage
          Center(
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}% Complete',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: progress == 1 ? Color(0xFF2D936C) : Color(0xFF3498DB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF5D6D7E),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockchainInfo() {
    if (_projectData == null || _projectData!['blockchain_tx_hash'] == null) return SizedBox();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1A5F7A).withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(0xFF1A5F7A).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF1A5F7A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: Color(0xFF1A5F7A),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Blockchain Verification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A5F7A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Your project data is securely stored on the Ethereum blockchain with complete transparency and immutability.',
            style: TextStyle(
              color: Color(0xFF5D6D7E),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: Color(0xFF3498DB), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'TX: ${_projectData!['blockchain_tx_hash']?.toString().substring(0, 24)}...',
                    style: TextStyle(
                      color: Color(0xFF3498DB),
                      fontSize: 12,
                      fontFamily: 'Monospace',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Copy to clipboard
                  },
                  child: Icon(Icons.copy_rounded, color: Color(0xFF5D6D7E), size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Color(0xFF2D936C);
      case 'rejected':
        return Color(0xFFE74C3C);
      case 'submitted':
        return Color(0xFF8E44AD); // NEW COLOR
      case 'pending':
      default:
        return Color(0xFFF39C12);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
      default:
        return Icons.access_time_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'APPROVED ✅';
      case 'rejected':
        return 'REJECTED ❌';
      case 'pending':
      default:
        return 'PENDING ⏳';
    }
  }


  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFECF0F1),
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingScreen()
            : !_hasData
            ? _buildNoDataScreen()
            : SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              _buildUserInfoCard(),
              SizedBox(height: 20),

              // Project Info
              _buildProjectInfoCard(),
              SizedBox(height: 20),

              // Overall Status
              _buildOverallStatusSummary(),
              SizedBox(height: 25),

              // Department Status Title
              Text(
                'Department Approvals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A5F7A),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Track the approval status across different government departments',
                style: TextStyle(
                  color: Color(0xFF5D6D7E),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 15),

              _departmentStatus.isEmpty
                  ? Text(
                "No department data available",
                style: TextStyle(color: Colors.grey),
              )
                  : Column(
                children: _departmentStatus.entries.map((entry) {
                  return _buildStatusCard(entry.key, entry.value.toString());
                }).toList(),
              ),

              SizedBox(height: 25),

              // Blockchain Info
              _buildBlockchainInfo(),
              SizedBox(height: 30),

              // Refresh Button
              Center(
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF2D936C),
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                        });
                        _fetchProjectStatus();
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Color(0xFF2D936C).withOpacity(0.1),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, color: Color(0xFF2D936C), size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Refresh Status',
                              style: TextStyle(
                                color: Color(0xFF2D936C),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}