import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourist/Entrepreneurs/EntrepreneurProjectSubmission.dart';

import 'EntrepreneurLogin.dart';
import 'ProjectStatus.dart';


void main() {
  runApp(MaterialApp(
    home: EntrepreneurHome(),
  ));
}

class EntrepreneurHome extends StatefulWidget {
  @override
  State<EntrepreneurHome> createState() => _EntrepreneurHomeState();
}

class _EntrepreneurHomeState extends State<EntrepreneurHome> {
  int _selectedIndex = 0;
  bool isLogoutLoading = false;

  final List<Widget> _pages = [
    HomePage(),
    EntrepreneurProjectSubmission(),
    EntrepreneurProjectStatus(),
    /*EntrepreneurMyProjects(),
    EntrepreneurGuidelines(),
    EntrepreneurProfilePage(),*/
  ];

  final List<String> _pageTitles = [
    'Entrepreneur Home',
    'Submit Business Project',
    'Project Status',
 //   'My Projects',
    'Guidelines',
    'Profile',
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
            child: Text('Cancel', style: TextStyle(color: Color(0xFF2D936C))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2D936C),
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
      MaterialPageRoute(builder: (context) => EntrepreneurLogin()),
    );

    setState(() {
      isLogoutLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A5F7A),
        centerTitle: true,
        title: Text(
          _pageTitles[_selectedIndex],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: logout,
              icon: isLogoutLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.exit_to_app, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A5F7A),
                Color(0xFF2D936C),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.business_center_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ?? 'Entrepreneur',
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
                        color: Colors.white.withOpacity(0.8),
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
                        color: Color(0xFF2D936C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Verified User',
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

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 20),
                  children: [
                    _buildDrawerItem(
                      index: 0,
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                    ),
                    _buildDrawerItem(
                      index: 1,
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Submit Project',
                    ),
                    _buildDrawerItem(
                      index: 2,
                      icon: Icons.track_changes_rounded,
                      title: 'Project Status',
                    ),
                   /* _buildDrawerItem(
                      index: 3,
                      icon: Icons.folder_copy_rounded,
                      title: 'My Projects',
                    ),*/
  /*                  _buildDrawerItem(
                      index: 4,
                      icon: Icons.rule_rounded,
                      title: 'Guidelines',
                    ),
                    _buildDrawerItem(
                      index: 5,
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                    ),*/
                  ],
                ),
              ),

              // Footer
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security_rounded, size: 14, color: Colors.white.withOpacity(0.7)),
                        SizedBox(width: 5),
                        Text(
                          'Blockchain Secured',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        onTap: logout,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          selectedItemColor: Color(0xFF2D936C),
          unselectedItemColor: Color(0xFF5D6D7E),
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              label: 'Submit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_rounded),
              label: 'Status',
            ),
           /* BottomNavigationBarItem(
              icon: Icon(Icons.folder_copy_rounded),
              label: 'Projects',
            ),*/
          /*  BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required int index, required IconData icon, required String title}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: _selectedIndex == index
            ? Colors.white.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: _selectedIndex == index
            ? Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        )
            : null,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
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
      'title': 'Submit Project Proposals',
      'description': 'Submit innovative project ideas with all required documentation',
      'color': Color(0xFF2D936C),
      'icon': Icons.lightbulb_outline_rounded,
    },
    {
      'title': 'Blockchain Security',
      'description': 'All documents stored immutably on Ethereum blockchain',
      'color': Color(0xFF1A5F7A),
      'icon': Icons.security_rounded,
    },
    {
      'title': 'Transparent Tracking',
      'description': 'Track approval status with complete visibility',
      'color': Color(0xFF2C3E50),
      'icon': Icons.visibility_rounded,
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Submit New Project',
      'icon': Icons.add_circle_outline_rounded,
      'color': Color(0xFF2D936C),
      'index': 1,
    },
    {
      'title': 'Project Status',
      'icon': Icons.track_changes_rounded,
      'color': Color(0xFF1A5F7A),
      'index': 2,
    },
    {
      'title': 'My Projects',
      'icon': Icons.folder_copy_rounded,
      'color': Color(0xFF3498DB),
      'index': 3,
    },
    {
      'title': 'Guidelines',
      'icon': Icons.rule_rounded,
      'color': Color(0xFF9B59B6),
      'index': 4,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 4), () {
      if (_pageController.hasClients) {
        if (_currentPage < _carouselItems.length - 1) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 600),
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
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Header
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D936C),
                    Color(0xFF1A5F7A),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.business_center_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Entrepreneur Portal',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Decentralized Government Approvals',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Blockchain-secured project submissions & transparent approval tracking',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Features',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Immutable & transparent project approval system',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5D6D7E),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _carouselItems.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _carouselItems[index]['color'].withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _carouselItems[index]['color'],
                                    _carouselItems[index]['color'].withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _carouselItems[index]['icon'],
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      _carouselItems[index]['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      _carouselItems[index]['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
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
                        width: _currentPage == index ? 30 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? Color(0xFF2D936C)
                              : Colors.grey[300],
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
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
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _quickActions.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            (context.findAncestorStateOfType<_EntrepreneurHomeState>()!)
                                .setState(() {
                              (context.findAncestorStateOfType<_EntrepreneurHomeState>()!)
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
                                  _quickActions[index]['color'].withOpacity(0.1),
                                  _quickActions[index]['color'].withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: _quickActions[index]['color'].withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _quickActions[index]['color'].withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _quickActions[index]['icon'],
                                    size: 30,
                                    color: _quickActions[index]['color'],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    _quickActions[index]['title'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
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

            // Blockchain Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C3E50),
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
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.link_rounded, color: Colors.white, size: 24),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Blockchain Powered',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Immutable & transparent records',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'All documents stored on Ethereum blockchain ensuring data integrity',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Complete audit trail with smart contract automation',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.security_rounded, color: Color(0xFF2D936C), size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Secure',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5D6D7E),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Blockchain',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.visibility_rounded, color: Color(0xFF1A5F7A), size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Transparent',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5D6D7E),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Tracking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.speed_rounded, color: Color(0xFF3498DB), size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Fast',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5D6D7E),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Approvals',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}