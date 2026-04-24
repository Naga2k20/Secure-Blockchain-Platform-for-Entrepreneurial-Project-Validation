import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tourist/Government/viewdocs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DepartmentViewProposals extends StatefulWidget {
  @override
  State<DepartmentViewProposals> createState() => _DepartmentViewProposalsState();
}

class _DepartmentViewProposalsState extends State<DepartmentViewProposals> {
  List<Map<String, dynamic>> businessIdeas = [];
  List<Map<String, dynamic>> filteredBusinessIdeas = [];
  List<String> businessKeys = [];
  bool isLoading = true;
  late String _userId;
  String? _userCity;
  String? _departmentName;

  // Search variables
  final TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _fetchUserDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;

      // Fetch department details from GovernmentDepartments
      final dbRef = FirebaseDatabase.instance.ref().child('GovernmentDepartments').child(_userId);
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _userCity = data['city'];
          _departmentName = data['departmentName'];
        });

        // Now fetch business ideas
        _fetchBusinessIdeas();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
/*

  void _fetchBusinessIdeas() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('business_ideas');
    final DataSnapshot snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      List<Map<String, dynamic>> tempIdeas = [];
      List<String> tempKeys = [];

      data.forEach((key, value) {
        final entry = Map<String, dynamic>.from(value);

        // Check if business idea city matches department city
        final businessCity = entry['district'];
        final approvalDepartments = List<String>.from(entry['approval_departments'] ?? []);

        // Check two conditions:
        // 1. City matches (district in business_ideas == city in GovernmentDepartments)
        // 2. Department is in the approval_departments list
        if (businessCity == _userCity && approvalDepartments.contains(_departmentName)) {
          tempIdeas.add(entry);
          tempKeys.add(key);
        }
      });

      await Future.delayed(500.ms);

      setState(() {
        businessIdeas = tempIdeas;
        filteredBusinessIdeas = tempIdeas;
        businessKeys = tempKeys;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
*/
  void _fetchBusinessIdeas() async {
    try {
      final dbRef = FirebaseDatabase.instance.ref().child('business_ideas');
      final snapshot = await dbRef.get();

      if (!snapshot.exists) {
        setState(() => isLoading = false);
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      List<Map<String, dynamic>> tempIdeas = [];
      List<String> tempKeys = [];

      data.forEach((key, value) {
        final entry = Map<String, dynamic>.from(value);

        final businessCity = entry['district']?.toString().toLowerCase().trim();
        final userCity = _userCity?.toLowerCase().trim();

        final approvalDepartments =
        List<String>.from(entry['approval_departments'] ?? []);

        if (businessCity == userCity &&
            approvalDepartments.contains(_departmentName)) {

          tempIdeas.add(entry);
          tempKeys.add(key);
        }

      });

      setState(() {
        businessIdeas = tempIdeas;
        filteredBusinessIdeas = tempIdeas;
        businessKeys = tempKeys;
        isLoading = false;
      });
    } catch (e) {
      print("FETCH ERROR: $e");
      setState(() => isLoading = false);
    }
  }


  // Search function
  void _performSearch(String query) {
    final q = query.toLowerCase().trim();

    setState(() {
      _searchQuery = q;

      if (q.isEmpty) {
        filteredBusinessIdeas = List.from(businessIdeas);
        return;
      }

      filteredBusinessIdeas = businessIdeas.where((idea) {
        return [
          idea['business_name'],
          idea['name'],
          idea['idea'],
          idea['location'],
          idea['email'],
        ].any((field) =>
        field != null &&
            field.toString().toLowerCase().contains(q));
      }).toList();
    });
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
      filteredBusinessIdeas = List.from(businessIdeas);
      _isSearching = false;
    });
  }


 /* void _updateStatus(String key, String newStatus) async {
    try {
      final dbRef = FirebaseDatabase.instance
          .ref()
          .child('Entrepreneurs/$key/department_status/$_departmentName');

      await dbRef.set(newStatus);

      setState(() {
        final index = businessKeys.indexOf(key);

        if (index != -1) {
          businessIdeas[index]['department_status'] ??= {};
          businessIdeas[index]['department_status'][_departmentName] = newStatus;
        }

        filteredBusinessIdeas = List.from(filteredBusinessIdeas);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated to ${newStatus.toUpperCase()}'),
          backgroundColor:
          newStatus == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print(e);
    }
  }*/
  void _updateStatus(String key, Map<String, dynamic> data, String newStatus) async {
    try {
      if (key.isEmpty || _departmentName == null) return;

      final ideaRef = FirebaseDatabase.instance
          .ref()
          .child('business_ideas')
          .child(key); // ✅ CORRECT NODE

      print("Updating KEY: $key");
      print("Department: $_departmentName");

      // ✅ Update ONLY department field
      await ideaRef
          .child('department_status')
          .child(_departmentName!)
          .set(newStatus);

      // ✅ Get updated data
      final snapshot = await ideaRef.get();

      if (snapshot.exists) {
        final ideaData = Map<String, dynamic>.from(snapshot.value as Map);

        final deptStatus =
        Map<String, dynamic>.from(ideaData['department_status'] ?? {});

        bool allApproved =
        deptStatus.values.every((s) => s == 'accepted');

        bool anyRejected =
        deptStatus.values.any((s) => s == 'rejected');

        String finalStatus = 'pending';

        if (allApproved) {
          finalStatus = 'accepted';
        } else if (anyRejected) {
          finalStatus = 'rejected';
        }

        // ✅ Update main status (correct place)
        await ideaRef.update({
          'status': finalStatus,
        });

        // ✅ Update UI
        setState(() {
          data['department_status'] ??= {};
          data['department_status'][_departmentName] = newStatus;
          data['status'] = finalStatus;
        });
      }
    } catch (e) {
      print("Update Error: $e");
    }
  }


  void _navigateToViewDocuments(Map<String, dynamic> data) {
    final String ukey = data['ekey'] ?? data['ukey'] ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewDocumentsPage(ukey: ukey),
      ),
    );
  }

 /* Color _getStatusColor(String? status, String? departmentName) {
    if (departmentName == _departmentName && status != null) {
      switch (status.toLowerCase()) {
        case 'accepted':
          return Colors.green.shade600;
        case 'rejected':
          return Colors.red.shade600;
        case 'pending':
          return Colors.orange.shade600;
      }
    }
    return Colors.grey.shade600;
  }*/
  String _getStatusText(String? status) {
    if (status == null) return 'PENDING';
    return status.toUpperCase();
  }


  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }



  // Search bar widget
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _performSearch,
              onTap: () {
                setState(() {
                  _isSearching = true;
                });
              },
              onSubmitted: (_) {
                _searchFocusNode.unfocus();
                setState(() {
                  _isSearching = false;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search projects by name, entrepreneur, description...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade600),
                  onPressed: _clearSearch,
                )
                    : null,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(
                fontSize: 15,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          if (_isSearching || _searchQuery.isNotEmpty)
            TextButton(
              onPressed: _clearSearch,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Search results indicator
  Widget _buildSearchInfo() {
    if (_searchQuery.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Search Results (${filteredBusinessIdeas.length})',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 14, color: Colors.blue.shade700),
                SizedBox(width: 6),
                Text(
                  '"$_searchQuery"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
              ),
              SizedBox(height: 20),
              Text(
                "Loading Project Proposals...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : businessIdeas.isNotEmpty
            ? Column(
          children: [
            // Header with city and department info
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_city,
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
                              '$_departmentName',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'City: $_userCity',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.filter_alt,
                                size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'City & Dept Filter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Proposals: ${businessIdeas.length}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              'Showing: ${filteredBusinessIdeas.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.dashboard,
                                size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Search Bar
            _buildSearchBar(),

            // Search Results Info
            _buildSearchInfo(),

            // Proposals List
            filteredBusinessIdeas.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredBusinessIdeas.length,
                itemBuilder: (context, index) {
                  final data = filteredBusinessIdeas[index];
                  // Find the original key for this filtered item
                  final originalIndex = businessIdeas.indexOf(data);
                  final key = originalIndex != -1
                      ? businessKeys[originalIndex]
                      : '';
                  final departmentStatus = data['department_status'] != null
                      ? data['department_status'][_departmentName]
                      : null;

                  return _buildProposalCard(
                      data, key, departmentStatus);
                },
              ),
            )
                : Expanded(
              child: _buildNoSearchResults(),
            ),
          ],
        )
            : Center(
          child: _buildNoProposalsScreen(),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade100, width: 2),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Colors.blue.shade300,
            ),
          ),
          SizedBox(height: 25),
          Text(
            "No Matching Projects Found",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  "No projects found for your search:",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 16, color: Colors.blue.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Search: "$_searchQuery"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Try searching with different keywords",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _clearSearch,
                      icon: Icon(Icons.clear_all, size: 18),
                      label: Text('Clear Search'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _searchFocusNode.requestFocus();
                      },
                      icon: Icon(Icons.search, size: 18),
                      label: Text('New Search'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        side: BorderSide(color: Colors.blue.shade700),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildNoProposalsScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.business_center,
            size: 60,
            color: Colors.blue.shade300,
          ),
        ),
        SizedBox(height: 25),
        Text(
          "No Project Proposals Found",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                "No matching proposals found for:",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_city,
                            size: 16, color: Colors.blue.shade700),
                        SizedBox(width: 8),
                        Text(
                          'City: $_userCity',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.badge, size: 16, color: Colors.blue.shade700),
                        SizedBox(width: 8),
                        Text(
                          'Department: $_departmentName',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "No business ideas found matching both your city and department.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              isLoading = true;
            });
            _fetchBusinessIdeas();
          },
          icon: Icon(Icons.refresh),
          label: Text('Refresh'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade700,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProposalCard(
      Map<String, dynamic> data, String key, String? departmentStatus) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              _getStatusColor(departmentStatus)
                  .withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['business_name'] ?? 'Unnamed Project',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Submitted by ${data['name'] ?? 'Anonymous'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:_getStatusColor(departmentStatus)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(departmentStatus)
                            .withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                        _getStatusText(departmentStatus),
                      style: TextStyle(
                        color:
                        _getStatusColor(departmentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey.shade300, height: 1),
              SizedBox(height: 20),

              // Project Details
              _buildDetailRow(
                icon: Icons.description,
                label: 'Business Idea',
                value: data['idea'] ?? 'No description provided',
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: data['location'] ?? 'Not specified',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildDetailRow(
                      icon: Icons.location_city,
                      label: 'City (District)',
                      value: data['district'] ?? 'Not specified',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Submitted Date',
                value: data['date'] ?? 'Unknown',
              ),
              SizedBox(height: 16),

              // Department Requirements
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Approvals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (data['approval_departments'] as List<dynamic>?)
                          ?.map((dept) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: dept == _departmentName
                              ? Colors.blue.shade800
                              : Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dept.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: dept == _departmentName
                                ? Colors.white
                                : Colors.blue.shade900,
                            fontWeight: dept == _departmentName
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ))
                          .toList() ??
                          [],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Contact Information
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.email,
                            size: 18, color: Colors.blue.shade700),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data['email'] ?? 'No email',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone,
                            size: 18, color: Colors.blue.shade700),
                        SizedBox(width: 10),
                        Text(
                          data['mobile'] ?? 'No phone',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [

                  if (data['file_url'] != null) SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.description,
                      label: 'View Documents',
                      color: Colors.blue.shade600,
                      onPressed: () => _navigateToViewDocuments(data),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Approval Buttons
              if (departmentStatus != 'accepted' && departmentStatus != 'rejected')
                Row(
                  children: [
                    Expanded(
                      child: _buildApprovalButton(
                        icon: Icons.check_circle,
                        label: 'Approve',
                        color: Colors.green.shade600,
                        onPressed: () => _updateStatus(key, data, 'accepted'),


                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildApprovalButton(
                        icon: Icons.cancel,
                        label: 'Reject',
                        color: Colors.red.shade600,
                        onPressed: () => _updateStatus(key, data, 'rejected'),


                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * filteredBusinessIdeas.indexOf(data)).ms).slideY(
      begin: 0.1,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade700),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildApprovalButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        shadowColor: color.withOpacity(0.4),
      ),
    );
  }
}