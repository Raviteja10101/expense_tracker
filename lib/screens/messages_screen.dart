import 'package:flutter/material.dart';

import '../services/sms_service.dart';
import 'bank_messages_screen.dart';
import '../widgets/app_drawer.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  

  @override
  State<MessagesScreen> createState() =>
      _MessagesScreenState();
}

class _MessagesScreenState
    extends State<MessagesScreen> {
      

  final SmsService smsService = SmsService();

  bool loading = true;
  bool darkMode = false;
  

  Map<String, List<Map<String, dynamic>>> bankMessages =
      {};

  List<Map<String, dynamic>> allMessages = [];

  int totalMessages = 0;
  int messagesLast90Days = 0;

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    await loadBanks();

    final lastRefresh =
        await smsService.getLastRefreshTime();

    if (lastRefresh == 0) {
      await refreshMessages();
      return;
    }

    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(
        lastRefresh,
      ),
    );

    if (diff.inHours >= 12) {
      await refreshMessages();
    }
  }

  Future<void> loadBanks() async {
    final messages =
        await smsService.loadMessages();

    allMessages = messages;

    totalMessages = messages.length;

    final ninetyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30));

    messagesLast90Days = messages.where((sms) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(
        sms['date'],
      );

      return date.isAfter(ninetyDaysAgo);
    }).length;

    final Map<String,
        List<Map<String, dynamic>>> grouped = {};

    for (final sms in messages) {
      final sender =
          sms['sender'] as String;

      final bank =
          smsService.getBankName(sender);

      if (bank == null) continue;

      grouped.putIfAbsent(bank, () => []);

      grouped[bank]!.add(sms);
    }

    setState(() {
      bankMessages = grouped;
      loading = false;
    });
  }

  Future<void> refreshMessages() async {
    setState(() {
      loading = true;
    });

    await smsService.syncMessages();

    await smsService.saveRefreshTime();

    await loadBanks();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        
        body: Center(
          child: CircularProgressIndicator(),
        ),


      );
    }

    final banks =
        bankMessages.keys.toList()..sort();

    return Scaffold(
  drawer: AppDrawer(
    darkMode: darkMode,
    onThemeChanged: (value) {
      setState(() {
        darkMode = value;
      });
    },
  ),

  appBar: AppBar(
    title: const Text('Bank Accounts'),
  ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: refreshMessages,
        child: const Icon(Icons.refresh),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Bank Accounts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...banks.map((bank) {
            return ListTile(
              title: Text(bank),
              trailing:
                  const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BankMessagesScreen(
                      bankName: bank,
                      messages:
                          bankMessages[bank]!,
                    ),
                  ),
                );
              },
            );
            
          }),
          

          const Divider(height: 32),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Messages In Inbox: $totalMessages',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Messages In Last 90 Days: $messagesLast90Days',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Text(
              'All Extracted Messages (${allMessages.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          ...allMessages.map((sms) {
            final date =
                DateTime.fromMillisecondsSinceEpoch(
              sms['date'],
            );

            return ListTile(
              dense: true,
              title: Text(
                sms['body'] ?? '',
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${date.day}/${date.month}/${date.year}',
              ),
            );
          }),
        ],
      ),
    );
  }
}