import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class MyReports extends StatefulWidget {
  final String? name;
  final String? email;
  final String? mobile;
  final String? address;
  final String? district;
  final String? ukey;

  const MyReports({
    Key? key,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.district,
    this.ukey,
  }) : super(key: key);

  @override
  _ViewHelpsState createState() => _ViewHelpsState();
}

class _ViewHelpsState extends State<MyReports> {
  final DatabaseReference _eventsRef = FirebaseDatabase.instance.ref('final_reports');

  Widget _buildEventListView() {
    return StreamBuilder<DatabaseEvent>(
      stream: _eventsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          Map<String, dynamic> data = Map<String, dynamic>.from(
            (snapshot.data!.snapshot.value as Map).map(
                  (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
            ),
          );

          List filteredEvents = data.values.where((event) {
            return event['district']?.toString().toLowerCase().trim() == widget.district?.toLowerCase().trim() &&
                event['ukey']?.toString().toLowerCase().trim() == widget.ukey?.toLowerCase().trim();
          }).toList();

          if (filteredEvents.isEmpty) {
            return const Center(
              child: Text(
                'No complaints available for your district',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 4),
                      Text('Mobile: ${event['mobile'] ?? 'Unknown'}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      const Divider(),

                      // Display all key-value pairs dynamically
                      ...event.entries.map((entry) {
                        String key = entry.key.toString();
                        String value = entry.value?.toString() ?? 'N/A';
                        return _infoTile(Icons.info, '$key: $value');
                      }).toList(),

                      const SizedBox(height: 12),

                      if (event['latitude'] != null && event['longitude'] != null)
                        _mapButton(event['latitude'], event['longitude']),

                      if (event['reportFileUrl'] != null)
                        TextButton(
                          onPressed: () async {
                            final url = event['reportFileUrl'].toString();
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open the report file')),
                              );
                            }
                          },
                          child: const Text(
                            'View Report (PDF)',
                            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                          ),
                        ),

                      /*Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApprovalPage(
                                  name: event['name']?.toString() ?? '',
                                  location: event['location']?.toString() ?? '',
                                  designation: event['designation']?.toString() ?? '',
                                  district: event['district']?.toString() ?? '',
                                  mobile: event['mobile']?.toString() ?? '',
                                  okey: event['okey']?.toString() ?? '',
                                  complaint: event['complaint']?.toString() ?? '',
                                  uname: event['uname']?.toString() ?? '',
                                  umobile: event['umobile']?.toString() ?? '',
                                  uaddress: event['uaddress']?.toString() ?? '',
                                  ukey: event['ukey']?.toString() ?? '',
                                  reportFileUrl: event['report_file_url']?.toString() ?? '',
                                  findings: event['findings']?.toString() ?? '',
                                  status: event['status']?.toString() ?? '',
                                  email: widget.email?.toString() ?? '',
                                  collectorName: widget.name?.toString() ?? '',
                                  ckey: widget.ckey?.toString() ?? '',
                                  latitude: double.tryParse(event['latitude']?.toString() ?? '0.0'),
                                  longitude: double.tryParse(event['longitude']?.toString() ?? '0.0'),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          child: const Text('Approve'),
                        ),
                      ),*/
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton(dynamic lat, dynamic lng) {
    return TextButton.icon(
      onPressed: () async {
        double? latitude = double.tryParse(lat.toString());
        double? longitude = double.tryParse(lng.toString());

        if (latitude != null && longitude != null) {
          final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open Google Maps')),
            );
          }
        }
      },
      icon: const Icon(Icons.map, color: Colors.blue),
      label: const Text('View on Map', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent[50],
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _buildEventListView(),
    );
  }
}
