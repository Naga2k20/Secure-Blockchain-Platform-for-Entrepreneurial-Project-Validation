import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';


class ViewDocumentsPage extends StatefulWidget {
  final String ukey;

  const ViewDocumentsPage({Key? key, required this.ukey}) : super(key: key);

  @override
  State<ViewDocumentsPage> createState() => _ViewDocumentsPageState();
}

class _ViewDocumentsPageState extends State<ViewDocumentsPage> {
  Map<String, dynamic>? businessData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBusinessData();
  }

  void _fetchBusinessData() async {
    try {
      final dbRef = FirebaseDatabase.instance.ref().child('business_ideas');
      final snapshot = await dbRef.orderByChild('ekey').equalTo(widget.ukey).once();

      if (snapshot.snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        // Find the matching business idea
        final entry = data.entries.firstWhere(
              (entry) => entry.value['ekey'] == widget.ukey,
          orElse: () => MapEntry('', {}),
        );

        if (entry.key.isNotEmpty) {
          setState(() {
            businessData = Map<String, dynamic>.from(entry.value);
            isLoading = false;
          });
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
    } catch (e) {
      print('Error fetching business data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openPdf(String url) async {
    try {
      final Uri pdfUri = Uri.parse(url);
      if (await canLaunchUrl(pdfUri)) {
        await launchUrl(
          pdfUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorSnackBar('Could not open PDF');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening PDF: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Project Documents',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        elevation: 0,

      ),
      body: isLoading
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
              'Loading Project Details...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : businessData == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.blue.shade300,
            ),
            SizedBox(height: 20),
            Text(
              'Project Not Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Unable to find project details for this submission.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _fetchBusinessData();
              },
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [

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
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.description,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    businessData!['business_name'] ??
                        'Project Documents',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Submitted by ${businessData!['name'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Project Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blue.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business Idea
                        _buildDetailSection(
                          icon: Icons.lightbulb_outline,
                          title: 'Business Idea',
                          value: businessData!['idea'] ??
                              'No description provided',
                        ),
                        SizedBox(height: 25),

                        // Location Details
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailSection(
                                icon: Icons.location_on,
                                title: 'Location',
                                value: businessData!['location'] ??
                                    'Not specified',
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: _buildDetailSection(
                                icon: Icons.location_city,
                                title: 'City',
                                value: businessData!['district'] ??
                                    'Not specified',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),

                        // Contact Information
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.contact_page,
                                      color: Colors.blue.shade800,
                                      size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'Contact Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              _buildContactDetail(
                                icon: Icons.email,
                                label: 'Email',
                                value: businessData!['email'] ??
                                    'No email',
                              ),
                              SizedBox(height: 12),
                              _buildContactDetail(
                                icon: Icons.phone,
                                label: 'Mobile',
                                value: businessData!['mobile'] ??
                                    'No phone',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),

                        // Submission Details
                        _buildDetailSection(
                          icon: Icons.calendar_today,
                          title: 'Submitted Date',
                          value: businessData!['date'] ?? 'Unknown',
                        ),
                        SizedBox(height: 25),

                        // Blockchain Information
                        if (businessData!['blockchain_tx_hash'] !=
                            null)
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.green.shade100,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.link,
                                        color: Colors.green.shade800,
                                        size: 22),
                                    SizedBox(width: 10),
                                    Text(
                                      'Blockchain Verified',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Transaction Hash:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  businessData!['blockchain_tx_hash'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade900,
                                    fontFamily: 'Monospace',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Blind Signature:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  businessData!['blind_signature'] ??
                                      'N/A',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade900,
                                    fontFamily: 'Monospace',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // PDF Document Section
            if (businessData!['file_url'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade900,
                        Colors.blue.shade700,
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
                      Icon(
                        Icons.picture_as_pdf,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Project Plan Document',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Detailed business plan submitted by the entrepreneur',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 25),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _openPdf(businessData!['file_url']),
                        icon: Icon(Icons.visibility, size: 22),
                        label: Text(
                          'VIEW PROJECT PLAN PDF',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red.shade600,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: Colors.red.shade600
                              .withOpacity(0.4),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'The document will open in your default PDF viewer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 30),

            // Status Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 40,
                        color: Colors.blue.shade800,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Project Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: businessData!['status'] ==
                              'submitted'
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: businessData!['status'] ==
                                'submitted'
                                ? Colors.orange.shade200
                                : Colors.green.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          (businessData!['status'] ?? 'Submitted')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: businessData!['status'] ==
                                'submitted'
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: Colors.blue.shade700),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 34),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.blue.shade900,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}