import 'package:flutter/material.dart';
import '../services/auth_services_entrepreneurs.dart';
import '../utils/appvalidator.dart';
import 'EntrepreneurHome.dart';
import 'EntrepreneurSignUp.dart';

class EntrepreneurLogin extends StatefulWidget {
  @override
  _EntrepreneurLoginState createState() => _EntrepreneurLoginState();
}

class _EntrepreneurLoginState extends State<EntrepreneurLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  final authService = AuthServiceEntrepreneurs();
  final appValidator = AppValidator();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    var credentials = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      await authService.entrepreneursLogin(credentials, context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EntrepreneurHome()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2D936C).withOpacity(0.08),
                    Color(0xFF1A5F7A).withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),

          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF2D936C).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF1A5F7A).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF2D936C),
                          Color(0xFF1A5F7A),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo/Brand Section
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
                              Icons.business_center_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Welcome Back,',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Entrepreneur',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Apply for business approvals in our centralized platform',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Login Form Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Login Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title
                                  Text(
                                    'Entrepreneur Login',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A5F7A),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Email Field
                                  Container(
                                    margin: EdgeInsets.only(bottom: 15),
                                    child: TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Entrepreneur Email',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF5D6D7E),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        hintText: 'your.entrepreneur@example.com',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                        ),
                                        prefixIcon: Container(
                                          margin: EdgeInsets.only(right: 15),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2D936C).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.email_rounded,
                                            color: Color(0xFF2D936C),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2D936C),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF2C3E50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      validator: appValidator.validateEmail,
                                    ),
                                  ),

                                  // Password Field
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: TextFormField(
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF5D6D7E),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        hintText: 'Enter your password',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                        ),
                                        prefixIcon: Container(
                                          margin: EdgeInsets.only(right: 15),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2D936C).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.lock_rounded,
                                            color: Color(0xFF2D936C),
                                          ),
                                        ),
                                        suffixIcon: Container(
                                          margin: EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade100,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Color(0xFF5D6D7E),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: Color(0xFF2D936C),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF2C3E50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      validator: appValidator.validatepassword,
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Login Button
                                  Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF2D936C),
                                          Color(0xFF1A5F7A),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF2D936C).withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      child: InkWell(
                                        onTap: isLoading ? null : _login,
                                        borderRadius: BorderRadius.circular(15),
                                        splashColor: Colors.white.withOpacity(0.2),
                                        child: Center(
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
                                              Icon(Icons.login_rounded,
                                                  size: 22, color: Colors.white),
                                              SizedBox(width: 12),
                                              Text(
                                                'LOGIN TO HOME',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Text(
                                          'New to platform?',
                                          style: TextStyle(
                                            color: Color(0xFF5D6D7E),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20),

                                  // Register Button
                                  Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Color(0xFF2D936C),
                                        width: 2,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      child: InkWell(
                                        onTap: () => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EntrepreneurSignUp()),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        splashColor: Color(0xFF2D936C).withOpacity(0.1),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.person_add_alt_1_rounded,
                                                  size: 22, color: Color(0xFF2D936C)),
                                              SizedBox(width: 12),
                                              Text(
                                                'REGISTER AS ENTREPRENEUR',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  color: Color(0xFF2D936C),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Extra spacing for safety
                                  SizedBox(height: 10),
                                ],
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
        ],
      ),
    );
  }
}