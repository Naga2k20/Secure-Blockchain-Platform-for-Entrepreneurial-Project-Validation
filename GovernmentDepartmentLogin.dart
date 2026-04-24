import 'package:flutter/material.dart';

import '../main.dart';
import '../services/auth_services_governmentdepartment.dart';
import 'GovernmentDepartmentRegister.dart';

class GovernmentDepartmentLoginPage extends StatefulWidget {
  const GovernmentDepartmentLoginPage({super.key});

  @override
  State<GovernmentDepartmentLoginPage> createState() => _DepartmentLoginPageState();
}

class _DepartmentLoginPageState extends State<GovernmentDepartmentLoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;
  var authService = AuthServiceGovernmentDepartment();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  Future<void> _submitForm() async {
    setState(() => isLoading = true);
    var data = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    await authService.governmentDepartmentLogin(data, context);
    setState(() => isLoading = false);
  }

  Future<bool> _onWillPop() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ComplaintManagementHome()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xFFF0F4F8),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Professional gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2C3E50),
                        Color(0xFF3498DB),
                      ],
                    ),
                  ),
                ),

                // Abstract decorative elements
                Positioned(
                  top: -100,
                  right: -50,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -80,
                  left: -40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),

                              // Logo Section
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.admin_panel_settings_rounded,
                                            size: 60,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'ADMIN PORTAL',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Department Administration',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.8),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 40),

                              // Login Card
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 30,
                                          offset: Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Card Header with Status Bar
                                        Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF2C3E50),
                                                Color(0xFF3498DB),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(24),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.lock_outline_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'SECURE LOGIN',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white.withOpacity(0.8),
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Department Access',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.fiber_manual_record_rounded,
                                                      color: Colors.white,
                                                      size: 8,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'LIVE',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Form Fields
                                        Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Email Field with Label
                                              Text(
                                                'OFFICIAL EMAIL',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF64748B),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF8FAFC),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Color(0xFFE2E8F0),
                                                  ),
                                                ),
                                                child: TextFormField(
                                                  controller: _emailController,
                                                  decoration: InputDecoration(
                                                    hintText: 'department@domain.com',
                                                    hintStyle: TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontSize: 14,
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons.email_outlined,
                                                      color: Color(0xFF2C3E50),
                                                      size: 20,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 20),

                                              // Password Field with Label
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'PASSWORD',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF64748B),
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      // Forgot password functionality
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(50, 30),
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    child: Text(
                                                      'Forgot?',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF3498DB),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF8FAFC),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Color(0xFFE2E8F0),
                                                  ),
                                                ),
                                                child: TextFormField(
                                                  controller: _passwordController,
                                                  obscureText: _obscurePassword,
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter your password',
                                                    hintStyle: TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontSize: 14,
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons.lock_outline_rounded,
                                                      color: Color(0xFF2C3E50),
                                                      size: 20,
                                                    ),
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _obscurePassword = !_obscurePassword;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        _obscurePassword
                                                            ? Icons.visibility_off_outlined
                                                            : Icons.visibility_outlined,
                                                        color: Color(0xFF64748B),
                                                        size: 20,
                                                      ),
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 24),

                                              // 2FA Option
                                              Container(
                                                margin: EdgeInsets.only(bottom: 16),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFF8FAFC),
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(
                                                          color: Color(0xFFCBD5E1),
                                                        ),
                                                      ),
                                                      child: Checkbox(
                                                        value: false,
                                                        onChanged: (value) {},
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        visualDensity: VisualDensity.compact,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        'Use two-factor authentication',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFF475569),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Login Button
                                              Container(
                                                width: double.infinity,
                                                height: 54,
                                                child: ElevatedButton(
                                                  onPressed: isLoading ? null : _submitForm,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(0xFF2C3E50),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: isLoading
                                                      ? SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                                    ),
                                                  )
                                                      : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.login_rounded, size: 20),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'ACCESS PORTAL',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w700,
                                                          letterSpacing: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 20),

                                              // Security Badge
                                              Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Color(0xFFE2E8F0),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.shield_rounded,
                                                      color: Color(0xFF2C3E50),
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Secure Authentication',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF1E293B),
                                                            ),
                                                          ),
                                                          Text(
                                                            '256-bit encrypted connection',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(0xFF64748B),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.verified_rounded,
                                                            color: Colors.green,
                                                            size: 12,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'SECURE',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.green,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 20),

                                              // Divider
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Divider(
                                                      color: Color(0xFFE2E8F0),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                                    child: Text(
                                                      'New Department?',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Divider(
                                                      color: Color(0xFFE2E8F0),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 16),

                                              // Register Button
                                              Container(
                                                width: double.infinity,
                                                height: 50,
                                                child: OutlinedButton(
                                                  onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => GovernmentDepartmentSignUp()),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Color(0xFF2C3E50),
                                                    side: BorderSide(
                                                      color: Color(0xFF2C3E50),
                                                      width: 1.5,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'CREATE DEPARTMENT ACCOUNT',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
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
                              ),

                              SizedBox(height: 20),

                              // Footer
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.copyright_rounded,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '2024 Admin Portal. All rights reserved.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}