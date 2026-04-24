import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'GovernmentDepartmentLogin.dart';

class GovernmentDepartmentSignUp extends StatefulWidget {
  GovernmentDepartmentSignUp({Key? key}) : super(key: key);

  @override
  _DepartmentSignUpState createState() => _DepartmentSignUpState();
}

class _DepartmentSignUpState extends State<GovernmentDepartmentSignUp>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController departmentNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController departmentCodeController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        String? userId = userCredential.user?.uid;
        Map<String, dynamic> departmentData = {
          'departmentName': departmentNameController.text.trim(),
          'email': emailController.text.trim(),
          'contactNumber': contactNumberController.text.trim(),
          'departmentCode': departmentCodeController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pinCode': pinCodeController.text.trim(),
          'ukey': userId,
          'registrationDate': DateTime.now().toIso8601String(),
          'departmentType': 'government',
          'status': 'pending_verification',
          'userType': 'government_department',
        };

        await _database.child('GovernmentDepartments').child(userId!).set(departmentData);
        await sendVerificationEmail();

        _showSuccessDialog();
      } catch (e) {
        _showErrorDialog(e.toString());
      }
      setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(30),
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
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade800.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 45,
                ),
              ),

              SizedBox(height: 25),

              // Title
              Text(
                'Department Registered!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade800,
                  letterSpacing: 0.5,
                ),
              ),

              SizedBox(height: 15),

              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Your  department registered successfully. The account will be activated after email verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D6D7E),
                    height: 1.6,
                  ),
                  maxLines: 4,
                ),
              ),


              SizedBox(height: 30),

              // Continue Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade800.withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GovernmentDepartmentLoginPage()),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'CONTINUE TO LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Colors.white,
                              ),
                              maxLines: 1,
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
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Registration Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 15),
            Text(
              error.replaceAll('FirebaseAuthException:', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF5D6D7E),
                fontSize: 14,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 25),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade800,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Center(
                    child: Text(
                      'RETRY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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

  Future<void> sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Color(0xFFF0F4F8),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Background decorative elements
                  Positioned(
                    top: -80,
                    right: -80,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.shade800.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -60,
                    left: -60,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.shade600.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Header Section
                                    Container(
                                      padding: EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.blue.shade800,
                                            Colors.blue.shade600,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                            child: Icon(
                                              Icons.account_balance_rounded,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'Admin Department\nRegistration',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              'Register your department to manage  tender approvals',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.9),
                                                height: 1.5,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 25),

                                    // Registration Form Container
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Container(
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Department Information Section
                                                  _buildSectionHeader(
                                                    'Department Information',
                                                    icon: Icons.account_balance_rounded,
                                                    color: Colors.blue.shade800,
                                                  ),
                                                  SizedBox(height: 15),

                                                  _buildTextField(
                                                    controller: departmentNameController,
                                                    label: 'Department Name',
                                                    icon: Icons.account_balance_outlined,
                                                    hint: 'e.g., Public Works Department',
                                                    validator: (value) => value!.isEmpty ? 'Enter department name' : null,
                                                  ),

                                                  SizedBox(height: 12),

                                                  _buildTextField(
                                                    controller: departmentCodeController,
                                                    label: 'Department Code',
                                                    icon: Icons.numbers_rounded,
                                                    hint: 'Official department code',
                                                  ),

                                                  SizedBox(height: 12),

                                                  _buildTextField(
                                                    controller: emailController,
                                                    label: 'Official Email',
                                                    icon: Icons.email_rounded,
                                                    hint: 'department@government.gov',
                                                    keyboardType: TextInputType.emailAddress,
                                                    validator: (value) => value!.isEmpty ? 'Enter official email' : null,
                                                  ),

                                                  SizedBox(height: 12),

                                                  _buildPasswordField(
                                                    controller: passwordController,
                                                    label: 'Secure Password',
                                                    hint: 'Create a strong password',
                                                  ),

                                                  SizedBox(height: 20),

                                                  // Contact Information Section
                                                  _buildSectionHeader(
                                                    'Contact Details',
                                                    icon: Icons.contacts_rounded,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                  SizedBox(height: 15),

                                                  _buildTextField(
                                                    controller: contactNumberController,
                                                    label: 'Contact Number',
                                                    icon: Icons.phone_rounded,
                                                    hint: '10-digit official contact',
                                                    keyboardType: TextInputType.phone,
                                                    validator: (value) {
                                                      if (value!.isEmpty) return 'Enter contact number';
                                                      if (value.length != 10) return 'Enter valid 10-digit number';
                                                      return null;
                                                    },
                                                  ),

                                                  SizedBox(height: 12),

                                                  _buildTextField(
                                                    controller: addressController,
                                                    label: 'Office Address',
                                                    icon: Icons.location_on_rounded,
                                                    hint: 'Complete office address',
                                                    maxLines: 2,
                                                  ),

                                                  SizedBox(height: 12),

                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: _buildTextField(
                                                          controller: cityController,
                                                          label: 'City',
                                                          icon: Icons.location_city_rounded,
                                                          hint: 'City name',
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: _buildTextField(
                                                          controller: stateController,
                                                          label: 'State',
                                                          icon: Icons.map_rounded,
                                                          hint: 'State name',
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: 12),

                                                  _buildTextField(
                                                    controller: pinCodeController,
                                                    label: 'PIN Code',
                                                    icon: Icons.pin_rounded,
                                                    hint: '6-digit PIN code',
                                                    keyboardType: TextInputType.number,
                                                  ),

                                                  SizedBox(height: 25),

                                                  // Register Button
                                                  Container(
                                                    width: double.infinity,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.blue.shade800,
                                                          Colors.blue.shade600,
                                                        ],
                                                        begin: Alignment.centerLeft,
                                                        end: Alignment.centerRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.blue.shade800.withOpacity(0.3),
                                                          blurRadius: 15,
                                                          offset: Offset(0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: InkWell(
                                                        onTap: isLoading ? null : _submitForm,
                                                        borderRadius: BorderRadius.circular(12),
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
                                                              Icon(Icons.how_to_reg_rounded, size: 22, color: Colors.white),
                                                              SizedBox(width: 10),
                                                              Flexible(
                                                                child: Text(
                                                                  'REGISTER DEPARTMENT',
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w700,
                                                                    letterSpacing: 0.8,
                                                                    color: Colors.white,
                                                                  ),
                                                                  maxLines: 1,
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
                                                  Container(
                                                    padding: EdgeInsets.all(15),
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
                                                          'Already registered? ',
                                                          style: TextStyle(
                                                            color: Color(0xFF5D6D7E),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => GovernmentDepartmentLoginPage()),
                                                          ),
                                                          child: Text(
                                                            'Login Here',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.blue.shade800,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),


                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
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
        );
      },
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
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
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
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade800,
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
                  borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                if (value!.isEmpty) return 'Enter password';
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
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.lock_rounded,
                    color: Colors.blue.shade800,
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
                  borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}