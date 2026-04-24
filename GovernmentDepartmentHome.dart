import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourist/Government/viewreports.dart';
import 'GovernmentDepartmentLogin.dart';
import 'homepage.dart';

class GovernmentDepartmentHome extends StatefulWidget {
  @override
  State<GovernmentDepartmentHome> createState() => _DepartmentHomeState();
}

class _DepartmentHomeState extends State<GovernmentDepartmentHome> {
  int _selectedIndex = 0;
  bool isLogoutLoading = false;

  final List<Widget> _pages = [
    HomePage(),
    DepartmentViewProposals(),
 /* DepartmentViewComplaints(),
    DepartmentViewAllotTenders(),
    DepartmentCompletedComplaints(),
    DepartmentProfilePage(),*/
    ProfilePage(),
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'Project Proposals',
  /*  'Review Applications',
    'Approval Queue',
    'Approved Projects',*/
    'Profile'
  ];

  Future<void> logout() async {
    bool? shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.blue.shade800)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() {
      isLogoutLoading = true;
    });

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GovernmentDepartmentLoginPage()),
    );

    setState(() {
      isLogoutLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        title: Text(
          _pageTitles[_selectedIndex],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: isLogoutLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.exit_to_app, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(Icons.badge, size: 50, color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Government Official',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? 'No Email',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Verified Official',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.description,
                    title: 'Project Proposals',
                    index: 1,
                  ),
                  /*_buildDrawerItem(
                    icon: Icons.verified_user,
                    title: 'Review Applications',
                    index: 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.pending_actions,
                    title: 'Approval Queue',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.check_circle,
                    title: 'Approved Projects',
                    index: 4,
                  ),*/
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Profile',
                    index: 5,
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.red.shade700),
                    title: Text('Logout', style: TextStyle(color: Colors.red.shade700)),
                    onTap: logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                ),
                child: Icon(Icons.dashboard, size: 22),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                ),
                child: Icon(Icons.description, size: 22),
              ),
              label: 'Proposals',
            ),
           /* BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 2 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                ),
                child: Icon(Icons.verified_user, size: 22),
              ),
              label: 'Review',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 3 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                ),
                child: Icon(Icons.pending_actions, size: 22),
              ),
              label: 'Queue',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 4 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                ),
                child: Icon(Icons.check_circle, size: 22),
              ),
              label: 'Approved',
            ),*/
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 5 ? Colors.white.withOpacity(0.2) : Colors.transparent,
                ),
                child: Icon(Icons.person, size: 22),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required int index}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue.shade800, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _selectedIndex == index ? Colors.blue.shade800 : Colors.grey.shade800,
        ),
      ),
      trailing: _selectedIndex == index
          ? Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          shape: BoxShape.circle,
        ),
      )
          : null,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Project Proposals',
      'description': 'Review and validate entrepreneurial project ideas',
      'color': Colors.blue.shade700,
      'icon': Icons.description,
    },
    {
      'title': 'Document Verification',
      'description': 'Validate required documentation on blockchain',
      'color': Colors.blue.shade800,
      'icon': Icons.verified_user,
    },
    {
      'title': 'Smart Contract Approvals',
      'description': 'Execute automated approval workflows',
      'color': Colors.blue.shade900,
      'icon': Icons.smart_button,
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'New Proposals',
      'icon': Icons.add_circle,
      'index': 1,
      'description': 'Review pending submissions',
      'color': Colors.blue.shade600,
    },
    {
      'title': 'Verification Queue',
      'icon': Icons.pending_actions,
      'index': 2,
      'description': 'Documents validation',
      'color': Colors.blue.shade700,
    },
    {
      'title': 'Approval Decisions',
      'icon': Icons.approval,
      'index': 3,
      'description': 'Make approval decisions',
      'color': Colors.blue.shade800,
    },
    {
      'title': 'Approved Projects',
      'icon': Icons.check_circle,
      'index': 4,
      'description': 'View approved initiatives',
      'color': Colors.blue.shade900,
    },
  ];


  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        if (_currentPage < _carouselItems.length - 1) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(0);
        }
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome Header
          Container(
            padding: EdgeInsets.all(30),
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
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.badge,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Department Portal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.security, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Blockchain Secured • Immutable Records',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          SizedBox(height: 25),

          // Features Carousel
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade800, Colors.blue.shade600],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Platform Features',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _carouselItems.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _carouselItems[index]['color']!,
                                Colors.blue.shade800!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    _carouselItems[index]['icon'],
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  _carouselItems[index]['title'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _carouselItems[index]['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _carouselItems.length,
                        (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.blue.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Quick Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade800, Colors.blue.shade600],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemCount: _quickActions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          (context.findAncestorStateOfType<_DepartmentHomeState>()!)
                              .setState(() {
                            (context.findAncestorStateOfType<_DepartmentHomeState>()!)
                                ._selectedIndex = _quickActions[index]['index'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _quickActions[index]['color']!.withOpacity(0.1),
                                Colors.white,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _quickActions[index]['color']!.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _quickActions[index]['icon'],
                                    size: 28,
                                    color: _quickActions[index]['color'],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _quickActions[index]['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  _quickActions[index]['description'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Blockchain Information
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade800,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link, size: 30, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Blockchain Technology',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Ensuring data immutability, tamper-proof recordkeeping, and traceability '
                        'through Ethereum blockchain and smart contracts.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeaturePill('Immutable Records', Icons.security),
                      _buildFeaturePill('Smart Contracts', Icons.smart_button),
                      _buildFeaturePill('Transparent', Icons.visibility),
                      _buildFeaturePill('Accountable', Icons.account_balance),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),

          // System Overview
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.blue.shade100,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.account_balance,
                  size: 40,
                  color: Colors.blue.shade800,
                ),
                SizedBox(height: 15),
                Text(
                  'Decentralized  Approval System',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'This platform eliminates centralized data manipulation by storing '
                      'all project proposals and approvals on the Ethereum blockchain. '
                      'Smart contracts automate validation workflows, reducing manual '
                      'intervention while ensuring accountability through on-chain '
                      'recordkeeping of all official actions.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    (context.findAncestorStateOfType<_DepartmentHomeState>()!)
                        .setState(() {
                      (context.findAncestorStateOfType<_DepartmentHomeState>()!)
                          ._selectedIndex = 1;
                    });
                  },
                  icon: Icon(Icons.description),
                  label: Text('Review Project Proposals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2, // ✅ equal vertical balance
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}