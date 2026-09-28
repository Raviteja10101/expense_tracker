import 'package:flutter/material.dart';

import '../parsers/sms_parser.dart';
import '../services/sms_service.dart';

class ParserTestScreen extends StatefulWidget {
  const ParserTestScreen({super.key});

  @override
  State<ParserTestScreen> createState() => _ParserTestScreenState();
}

class _ParserTestScreenState extends State<ParserTestScreen> {
  final SmsService smsService = SmsService();
  bool loading = true;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final data = await smsService.loadMessages();
    if (!mounted) return;
    setState(() { messages = data; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Parser Test')),
      body: messages.isEmpty
          ? const Center(child: Text('No stored bank messages.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final sms = messages[index];
                final body = sms['body']?.toString() ?? '';
                final transaction = SmsParser.parse(body);
                final date = DateTime.fromMillisecondsSinceEpoch(
                  sms['date'] as int,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sms['bank']?.toString() ??
                              smsService.getBankName(sms['sender'].toString()) ??
                              'Unknown Bank',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${date.day}/${date.month}/${date.year}'),
                        const Divider(height: 24),
                        Text(
                          'Parsed Amount: ₹${transaction.amount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Type: ${transaction.isDebit ? 'Debit' : transaction.isCredit ? 'Credit' : 'Unknown'}',
                        ),
                        Text(
                          'UPI: ${transaction.isUpi ? 'Yes' : 'No'}',
                        ),
                        if (transaction.availableBalance.isNotEmpty)
                          Text('Balance: ₹${transaction.availableBalance}'),
                        if (transaction.merchant.isNotEmpty)
                          Text('Merchant: ${transaction.merchant}'),
                        if (transaction.referenceNo.isNotEmpty)
                          Text('Reference: ${transaction.referenceNo}'),
                        const SizedBox(height: 12),
                        const Text(
                          'Original SMS:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(body),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}