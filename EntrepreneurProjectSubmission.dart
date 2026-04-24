import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart' as web3;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:web_socket_channel/io.dart';
import 'package:crypto/crypto.dart';

class EntrepreneurProjectSubmission extends StatefulWidget {
  @override
  _EntrepreneurProjectSubmissionState createState() => _EntrepreneurProjectSubmissionState();
}

class _EntrepreneurProjectSubmissionState extends State<EntrepreneurProjectSubmission> {
  // Blockchain Configuration
  final String _rpcURL = "http://10.74.77.184:7545";
  final String _wsURL = "ws://10.74.77.184:7545/";
  final String _privateKey = "0x2243273209b328c0623b8928a08b2a251807fb9b4757445b405c4097697416a0";

  late web3.Web3Client _client;
  late String _abiCode;
  late web3.EthereumAddress _contractAddress;
  late web3.Credentials _credentials;
  late web3.DeployedContract _contract;
  late web3.ContractFunction _setNameFunction;

  int _transactionCount = 0;
  bool _isSubmitting = false;
  String _lastTransactionHash = '';
  String _connectionStatus = 'Connecting...';
  String _blockchainError = '';

  // File Upload
  File? _selectedFile;
  String? _fileName;
  String? _fileSize;
  bool _isUploadingFile = false;

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Form Controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ideaController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  // User Data
  String _userName = '';
  String _userEmail = '';
  String _userMobile = '';
  String _userAddress = '';
  String _userId = '';

  // Departments
  List<String> _approvalDepartments = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initialSetup();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        _userId = user.uid;

        // Fetch user data from Entrepreneurs database
        DatabaseReference userRef = _database.child('Entrepreneurs').child(_userId);
        DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

          setState(() {
            _userName = userData['name']?.toString() ?? '';
            _userEmail = userData['email']?.toString() ?? '';
            _userMobile = userData['mobile']?.toString() ?? '';
            _userAddress = userData['address']?.toString() ?? '';

            // Pre-fill form fields
            _businessNameController.text = userData['company']?.toString() ?? '';
            _locationController.text = _userAddress;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _initialSetup() async {
    try {
      setState(() {
        _connectionStatus = 'Connecting to blockchain...';
      });

      _client = web3.Web3Client(_rpcURL, http.Client(),
          socketConnector: () => IOWebSocketChannel.connect(_wsURL).cast<String>());

      final clientVersion = await _client.getClientVersion();
      print("Connected to: $clientVersion");

      await _getAbi();
      await _getCredentials();
      await _getDeployedContract();
      await _getTransactionCount();

      setState(() {
        _connectionStatus = 'Connected to Blockchain';
      });

    } catch (e) {
      print("Error initializing Ethereum client: $e");
      setState(() {
        _connectionStatus = 'Connection failed';
        _blockchainError = e.toString();
      });
    }
  }

  Future<void> _getAbi() async {
    try {
      String abiStringFile = await rootBundle.loadString("src/artifacts/HelloWorld.json");
      var jsonAbi = jsonDecode(abiStringFile);
      _abiCode = jsonEncode(jsonAbi["abi"]);
      _contractAddress = web3.EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
      print("Contract address: $_contractAddress");
    } catch (e) {
      print("Error loading ABI: $e");
      throw Exception("ABI loading failed: $e");
    }
  }

  Future<void> _getDeployedContract() async {
    try {
      _contract = web3.DeployedContract(
          web3.ContractAbi.fromJson(_abiCode, "HelloWorld"), _contractAddress);
      _setNameFunction = _contract.function("setName");
      print("Contract deployed successfully");
    } catch (e) {
      print("Error deploying contract: $e");
      throw Exception("Contract deployment failed: $e");
    }
  }

  Future<void> _getCredentials() async {
    try {
      _credentials = web3.EthPrivateKey.fromHex(_privateKey);
      final address = await _credentials.extractAddress();
      print("Using account: $address");

      final balance = await _client.getBalance(address);
      print("Account balance: ${balance.getValueInUnit(web3.EtherUnit.ether)} ETH");

    } catch (e) {
      print("Error loading private key: $e");
      throw Exception("Credentials failed: $e");
    }
  }

  Future<void> _getTransactionCount() async {
    try {
      final address = await _credentials.extractAddress();
      final count = await _client.getTransactionCount(address);
      print("Current transaction count: $count");
      setState(() {
        _transactionCount = count;
      });
    } catch (e) {
      print("Error getting transaction count: $e");
      setState(() {
        _blockchainError = "Tx count error: $e";
      });
    }
  }

  Future<void> _executeBlockchainTransaction(String data) async {
    try {
      print("Calling setName with: $data");

      final transaction = web3.Transaction.callContract(
        contract: _contract,
        function: _setNameFunction,
        parameters: [data],
        maxGas: 100000,
      );

      print("Sending transaction...");

      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: 1337,
      );

      print("Transaction sent successfully: $txHash");
      setState(() {
        _lastTransactionHash = txHash;
        _blockchainError = '';
      });

      await Future.delayed(Duration(seconds: 2));

      await _getTransactionCount();

    } catch (e) {
      print("Error executing blockchain transaction: $e");
      setState(() {
        _blockchainError = "Transaction failed: $e";
      });
      throw e;
    }
  }

  String _generateBlindSignature(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _encryptData(String data) {
    final keyString = 'your32lengthsupersecretnooneknows1';
    final key = encrypt.Key.fromUtf8(keyString.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.encrypt(data, iv: iv).base64;
  }

  Future<String?> _uploadFile(String dataKey) async {
    if (_selectedFile == null) return null;

    try {
      setState(() {
        _isUploadingFile = true;
      });

      String fileExtension = _selectedFile!.path.split('.').last.toLowerCase();
      String fileName = "project_plan_${DateTime.now().millisecondsSinceEpoch}.$fileExtension";

      Reference storageReference = _storage.ref().child('business_plans/$dataKey/$fileName');

      UploadTask uploadTask = storageReference.putFile(_selectedFile!);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("File uploaded successfully: $downloadUrl");

      setState(() {
        _isUploadingFile = false;
      });

      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      setState(() {
        _isUploadingFile = false;
      });
      throw Exception("File upload failed: $e");
    }
  }

  void _addDepartment() {
    String dept = _departmentController.text.trim();

    if (dept.isNotEmpty && !_approvalDepartments.contains(dept)) {
      setState(() {
        _approvalDepartments.add(dept);
        _departmentController.clear();
      });

      print("ADDED DEPARTMENT: $dept");
      print("CURRENT LIST: $_approvalDepartments");
    }
  }


  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        double fileSizeInKB = result.files.single.size / 1024;

        setState(() {
          _selectedFile = file;
          _fileName = fileName;
          _fileSize = fileSizeInKB < 1024
              ? '${fileSizeInKB.toStringAsFixed(1)} KB'
              : '${(fileSizeInKB / 1024).toStringAsFixed(1)} MB';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: $fileName'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    // 🔥 FORCE ADD (VERY IMPORTANT)
    if (_departmentController.text.trim().isNotEmpty) {
      _approvalDepartments.add(_departmentController.text.trim());
      _departmentController.clear(); // clear after adding
    }

    print("FINAL DEPARTMENTS LIST: $_approvalDepartments");

    if (_approvalDepartments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please add at least one department"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _blockchainError = '';
    });

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Prepare data for blockchain
      String combinedData = '${_userName},${_userEmail},${_businessNameController.text},${_ideaController.text}';
      String encryptedData = _encryptData(combinedData);
      String blindSignature = _generateBlindSignature(encryptedData);

      // Execute blockchain transaction
      print("Starting blockchain transaction...");
      await _executeBlockchainTransaction(combinedData);
      print("Blockchain transaction completed");

      // Upload file if selected
      String? fileUrl;
      if (_selectedFile != null) {
        fileUrl = await _uploadFile(_lastTransactionHash);
      }

      // Prepare department status
      Map<String, String> departmentStatus = {};
      for (String dept in _approvalDepartments) {
        departmentStatus[dept] = "pending";
      }

      // Save to Firebase
      String dataKey = _database.child('business_ideas').push().key ?? '';
      print("DEPARTMENTS: $_approvalDepartments");

      Map<String, dynamic> ideaData = {
        "name": _userName,
        "mobile": _userMobile,
        "email": _userEmail,
        "location": _locationController.text,
        "business_name": _businessNameController.text,
        "district": _districtController.text,
        "idea": _ideaController.text,
        "approval_departments": _approvalDepartments.isNotEmpty ? _approvalDepartments : [],

        "department_status": departmentStatus,
        "status": 'submitted',
        "ekey": _userId,
        "date": formattedDate,
        "timestamp": currentTimestamp,
        "file_url": fileUrl ?? "",
        "blockchain_tx_hash": _lastTransactionHash,
        "blind_signature": blindSignature,
      };

      await _database.child('business_ideas').child(dataKey).set(ideaData);

      // Save to blockchaininfo
      Map<String, dynamic> secretData = {
        'combinedData': combinedData,
        'encryptedData': encryptedData,
        'signature': blindSignature,
        'timestamp': currentTimestamp,
        'status1': 'pending',
        'status2': 'pending',
        'date': formattedDate,
        'ekey': _userId,
        'blockchain_tx_hash': _lastTransactionHash,
        'transaction_count': _transactionCount,
      };

      await _database.child('blockchaininfo').child(dataKey).set(secretData);

      // Clear form
      _formKey.currentState!.reset();
      setState(() {
        _selectedFile = null;
        _fileName = null;
        _fileSize = null;
        _approvalDepartments.clear();
      });

      _showSuccessDialog();

    } catch (e) {
      print("Error submitting project: $e");
      setState(() {
        _blockchainError = e.toString();
      });
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _testBlockchainConnection() async {
    try {
      setState(() {
        _connectionStatus = 'Testing connection...';
        _blockchainError = '';
      });

      final clientVersion = await _client.getClientVersion();
      final address = await _credentials.extractAddress();
      final balance = await _client.getBalance(address);
      final count = await _client.getTransactionCount(address);

      setState(() {
        _connectionStatus = 'Connected to: $clientVersion';
        _transactionCount = count;
        _blockchainError = 'Balance: ${balance.getValueInUnit(web3.EtherUnit.ether)} ETH';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection successful! Balance: ${balance.getValueInUnit(web3.EtherUnit.ether)} ETH'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed';
        _blockchainError = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                Color(0xFFF8F9FA),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
                width: 80,
                height: 80,
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
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 25),

              // Title
              Text(
                'Project Submitted!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A5F7A),
                ),
              ),

              SizedBox(height: 15),

              // Message
              Text(
                'Your business project has been submitted successfully to the blockchain network.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5D6D7E),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 20),

              // Transaction Hash Card
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFF1A5F7A).withOpacity(0.1),
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
                        Icon(Icons.link_rounded, color: Color(0xFF1A5F7A), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Transaction Hash',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A5F7A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _lastTransactionHash));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Transaction hash copied to clipboard'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _lastTransactionHash,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Monospace',
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.copy, size: 16, color: Color(0xFF5D6D7E)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF2D936C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Color(0xFF2D936C).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: Color(0xFF2D936C),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Awaiting Government Approval',
                      style: TextStyle(
                        color: Color(0xFF2D936C),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Close Button
              Container(
                width: double.infinity,
                height: 50,
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
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: Text(
                        'CONTINUE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 10),
            Text(
              "Submission Failed!",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          error.length > 200 ? error.substring(0, 200) + "..." : error,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _connectionStatus.contains('Connected')
              ? [
            Color(0xFF2D936C).withOpacity(0.1),
            Color(0xFF1A5F7A).withOpacity(0.1),
          ]
              : [
            Colors.red.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _connectionStatus.contains('Connected')
              ? Color(0xFF2D936C).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _connectionStatus.contains('Connected')
                  ? Color(0xFF2D936C)
                  : Colors.red,
            ),
            child: Icon(
              _connectionStatus.contains('Connected') ? Icons.link : Icons.link_off,
              color: Colors.white,
              size: 14,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _connectionStatus.contains('Connected')
                      ? 'Blockchain Connected'
                      : 'Blockchain Disconnected',
                  style: TextStyle(
                    color: _connectionStatus.contains('Connected')
                        ? Color(0xFF2D936C)
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (_blockchainError.isNotEmpty)
                  Text(
                    _blockchainError,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    maxLines: 2,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 20),
            onPressed: _testBlockchainConnection,
            color: Color(0xFF1A5F7A),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCounter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A5F7A).withOpacity(0.1),
            Color(0xFF2D936C).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(0xFF1A5F7A).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blockchain Transactions',
                    style: TextStyle(
                      color: Color(0xFF1A5F7A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Total successful transactions',
                    style: TextStyle(
                      color: Color(0xFF5D6D7E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF1A5F7A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_transactionCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          if (_lastTransactionHash.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Color(0xFF2D936C), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Transaction',
                          style: TextStyle(
                            color: Color(0xFF5D6D7E),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${_lastTransactionHash.substring(0, 16)}...',
                          style: TextStyle(
                            color: Color(0xFF1A5F7A),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D936C).withOpacity(0.1),
            Color(0xFF1A5F7A).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(0xFF2D936C).withOpacity(0.2),
          width: 1,
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
                  color: Color(0xFF2D936C).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Color(0xFF2D936C), size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName.isNotEmpty ? _userName : 'Loading...',
                      style: TextStyle(
                        color: Color(0xFF1A5F7A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        color: Color(0xFF5D6D7E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(Icons.phone, _userMobile),
              SizedBox(width: 15),
              _buildInfoItem(Icons.location_on, _userAddress),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Color(0xFF2D936C)),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Color(0xFF5D6D7E),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isMultiLine = false,
    bool isRequired = true,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF5D6D7E),
              fontWeight: FontWeight.w500,
              fontSize: 13,
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
              maxLines: isMultiLine ? 4 : 1,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter ${label.toLowerCase()}',
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
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              validator: isRequired
                  ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentField() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approval Departments',
            style: TextStyle(
              color: Color(0xFF5D6D7E),
              fontWeight: FontWeight.w500,
              fontSize: 13,
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
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _departmentController,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add department (e.g., Finance, Environment)',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Container(
                        margin: EdgeInsets.only(right: 15, left: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFF2D936C).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.business,
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
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _addDepartment();
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 50,
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
                        color: Color(0xFF2D936C).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        _addDepartment();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_approvalDepartments.isNotEmpty) ...[
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _approvalDepartments.map((dept) => Chip(
                label: Text(dept),
                deleteIcon: Icon(Icons.close, size: 14),
                onDeleted: () {
                  setState(() {
                    _approvalDepartments.remove(dept);
                  });
                },
                backgroundColor: Color(0xFF2D936C).withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Color(0xFF1A5F7A),
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Color(0xFF2D936C).withOpacity(0.3)),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Plan Document',
            style: TextStyle(
              color: Color(0xFF5D6D7E),
              fontWeight: FontWeight.w500,
              fontSize: 13,
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
            child: GestureDetector(
              onTap: _isSubmitting || _isUploadingFile ? null : _pickFile,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile != null ? Color(0xFF2D936C) : Colors.grey.shade200,
                    width: _selectedFile != null ? 2 : 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    if (_selectedFile != null)
                      Column(
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
                                  _getFileIcon(),
                                  color: Color(0xFF2D936C),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _fileName ?? 'Selected File',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _fileSize ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF5D6D7E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: _isSubmitting || _isUploadingFile
                                    ? null
                                    : () {
                                  setState(() {
                                    _selectedFile = null;
                                    _fileName = null;
                                    _fileSize = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_isUploadingFile) ...[
                            SizedBox(height: 12),
                            LinearProgressIndicator(
                              backgroundColor: Color(0xFF2D936C).withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D936C)),
                            ),
                          ],
                        ],
                      )
                    else
                      Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            color: Color(0xFF2D936C),
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Upload Business Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A5F7A),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'PDF, DOC, PPT files (Max 10MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5D6D7E),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    if (_fileName == null) return Icons.insert_drive_file;

    String extension = _fileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: _connectionStatus.contains('Connected') && !_isSubmitting
              ? [Color(0xFF2D936C), Color(0xFF1A5F7A)]
              : [Colors.grey.shade400, Colors.grey.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: _connectionStatus.contains('Connected') && !_isSubmitting
                ? Color(0xFF2D936C).withOpacity(0.4)
                : Colors.grey.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: (_isSubmitting || !_connectionStatus.contains('Connected'))
              ? null
              : () {
            if (_formKey.currentState!.validate()) {
              _submitForm();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting || _isUploadingFile)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    _connectionStatus.contains('Connected')
                        ? Icons.cloud_upload
                        : Icons.cloud_off,
                    color: Colors.white,
                  ),
                SizedBox(width: 12),
                Text(
                  _isSubmitting || _isUploadingFile
                      ? 'Processing...'
                      : (_connectionStatus.contains('Connected')
                      ? 'SUBMIT TO BLOCKCHAIN'
                      : 'CONNECT TO BLOCKCHAIN'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status
              _buildConnectionStatus(),
              SizedBox(height: 16),

              // Transaction Counter
              _buildTransactionCounter(),
              SizedBox(height: 20),

              // User Info Card
              _buildUserInfoCard(),
              SizedBox(height: 24),

              // Form
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5F7A),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Fill in your business project details',
                        style: TextStyle(
                          color: Color(0xFF5D6D7E),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 20),

                      _buildTextField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        icon: Icons.business,
                      ),

                      _buildTextField(
                        controller: _ideaController,
                        label: 'Project Description',
                        icon: Icons.lightbulb_outline,
                        isMultiLine: true,
                      ),

                      _buildTextField(
                        controller: _locationController,
                        label: 'Project Location',
                        icon: Icons.location_on,
                      ),

                      _buildTextField(
                        controller: _districtController,
                        label: 'District',
                        icon: Icons.map,
                      ),

                      _buildDepartmentField(),

                      _buildFileUploadSection(),

                      SizedBox(height: 10),

                      // Blockchain Info
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A5F7A).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF1A5F7A).withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.security_rounded, color: Color(0xFF1A5F7A), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'All data will be encrypted and stored on Ethereum blockchain',
                                style: TextStyle(
                                  color: Color(0xFF5D6D7E),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 25),

                      // Submit Button
                      _buildSubmitButton(),
                    ],
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

  @override
  void dispose() {
    _ideaController.dispose();
    _businessNameController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _districtController.dispose();
    super.dispose();
  }
}