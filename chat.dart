import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientChatPage extends StatefulWidget {
  final String? ukey; // Key of the user
  final String? dockey; // Key of the doctor or farmer you are chatting with

  const PatientChatPage({Key? key, this.ukey, this.dockey}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<PatientChatPage> {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('messages');
  final TextEditingController _messageController = TextEditingController();
  late Stream<DatabaseEvent> _messagesStream;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the messages
    _messagesStream = _messagesRef.onValue;
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      // Push a new message to the database
      _messagesRef.push().set({
        'userKey': widget.ukey,
        'doctorKey': widget.dockey,
        'text': messageText,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _messageController.clear(); // Clear input field
    }
  }

  Future<bool> _onWillPop() async {
    // Show a confirmation dialog when the user tries to go back
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to leave this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Do not pop
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Pop
            child: Text('Yes'),
          ),
        ],
      ),
    );

    return shouldPop ?? false; // Return the user's choice
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
                    final messages = data?.entries.map((entry) {
                      final message = entry.value;
                      return ListTile(
                        title: Text(message['text']),
                        subtitle: Text(message['userKey'] == widget.ukey ? 'You' : 'Farmer'),
                        leading: CircleAvatar(
                          child: Text(message['userKey'] == widget.ukey ? 'U' : 'F'),
                        ),
                      );
                    }).toList() ?? [];

                    return ListView(children: messages);
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
