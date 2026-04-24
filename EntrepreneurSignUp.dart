import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'EntrepreneurLogin.dart';



class EntrepreneurSignUp extends StatefulWidget { // Changed class name
  @override
  _EntrepreneurSignUpState createState() => _EntrepreneurSignUpState(); // Changed class name
}

class _EntrepreneurSignUpState extends State<EntrepreneurSignUp> { // Changed class name
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  bool isLoader = false;
  bool _obscurePassword = true;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoader = true);
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        User? user = userCredential.user;
        if (user != null) {
          await _database.child('Entrepreneurs').child(user.uid).set({ // Changed database path
            'name': nameController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'mobile': mobileController.text,

            'address': addressController.text,
            'ekey': user.uid,
            'registrationDate': DateTime.now().toIso8601String(),
            'status': 'pending_verification',
            'userType': 'entrepreneur',
            'businessVerified': false,
          });
          await sendVerificationEmail();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              onContinue: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EntrepreneurLogin()), // Changed navigation
                );
              },
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('FirebaseAuthException:', ''),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      setState(() => isLoader = false);
    }
  }

  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A5F7A).withOpacity(0.05),
                    Color(0xFF2D936C).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // Background decorative elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
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

          Positioned(
            bottom: -50,
            left: -50,
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

          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Color(0xFF2D936C).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.business_center_rounded,
                              color: Color(0xFF2D936C),
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entrepreneur Registration',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A5F7A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Register your business for government opportunities',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5D6D7E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Registration Form Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Personal Information Section
                              _buildSectionHeader(
                                'Personal Information',
                                icon: Icons.person_outline_rounded,
                                color: Color(0xFF1A5F7A),
                              ),
                              SizedBox(height: 15),

                              _buildTextField(
                                controller: nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline_rounded,
                                hint: 'Enter your full name',
                                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                              ),

                              SizedBox(height: 15),

                              _buildTextField(
                                controller: emailController,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                hint: 'yourentrepreneur@example.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value!.isEmpty ? 'Please enter your Email' : null,
                              ),

                              SizedBox(height: 15),

                              _buildPasswordField(
                                controller: passwordController,
                                label: 'Password',
                                hint: 'Create a strong password',
                              ),



                              SizedBox(height: 15),

                              // Contact Details Section
                              _buildSectionHeader(
                                'Contact Details',
                                icon: Icons.contacts_outlined,
                                color: Color(0xFF1A5F7A),
                              ),
                              SizedBox(height: 15),

                              _buildTextField(
                                controller: mobileController,
                                label: 'Mobile Number',
                                icon: Icons.phone_android_outlined,
                                hint: 'Enter 10-digit mobile number',
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value!.isEmpty) return 'Please enter mobile number';
                                  if (value.length != 10) return 'Enter valid 10-digit number';
                                  return null;
                                },
                              ),

                              SizedBox(height: 15),

                              _buildTextField(
                                controller: addressController,
                                label: 'Entrepreneur Address',
                                icon: Icons.location_on_outlined,
                                hint: 'Full entrepreneur address',
                                maxLines: 2,
                              ),

                              SizedBox(height: 35),

                              // Register Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2D936C),
                                      Color(0xFF1A5F7A),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF2D936C).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: isLoader ? null : _submitForm,
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: Colors.white.withOpacity(0.2),
                                    child: Center(
                                      child: isLoader
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
                                          Icon(Icons.business_rounded, size: 22, color: Colors.white),
                                          SizedBox(width: 12),
                                          Text(
                                            'REGISTER AS ENTREPRENEUR',
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

                              // Login Link
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: Color(0xFF5D6D7E),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => EntrepreneurLogin()),
                                        ),
                                        child: Text(
                                          'Login Here',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2D936C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),


                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D6D7E),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Container(
                  margin: EdgeInsets.only(right: 15, left: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D936C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    icon,
                    color: Color(0xFF2D936C),
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2D936C), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D6D7E),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value!.isEmpty) return 'Please enter password';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Container(
                  margin: EdgeInsets.only(right: 15, left: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D936C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF2D936C),
                    size: 20,
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
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: Color(0xFF5D6D7E),
                      size: 20,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2D936C), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const SuccessDialog({Key? key, required this.onContinue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2D936C),
                    Color(0xFF1A5F7A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2D936C).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 30),

            // Title
            Text(
              'Registered!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A5F7A),
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: 20),

            // Message
            Text(
              'Your business registration has been submitted successfully. A verification email has been sent to your inbox. Please verify your email.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF5D6D7E),
                height: 1.6,
              ),
            ),



            SizedBox(height: 40),

            // Continue Button
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
                borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onContinue,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 12),
                        Text(
                          'CONTINUE TO LOGIN',
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
          ],
        ),
      ),
    );
  }
}