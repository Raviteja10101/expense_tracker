import 'package:flutter/material.dart';
import '../parsers/sms_parser.dart';
import 'package:transaction_sms_parser/transaction_sms_parser.dart';

class BankMessagesScreen extends StatefulWidget {
  final String bankName;
  final List<Map<String, dynamic>> messages;

  const BankMessagesScreen({
    super.key,
    required this.bankName,
    required this.messages,
  });

  @override
  State<BankMessagesScreen> createState() =>
      _BankMessagesScreenState();
}

class _BankMessagesScreenState
    extends State<BankMessagesScreen> {
  int selectedFilter = 1;

  String selectedMonth = 'All';
  String selectedYear = 'All';

  final List<String> months = const [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

//   Map<String, dynamic> parseTransaction(String body) {
//   final text = body.toLowerCase();

//   // Transaction Amount
//   String amount = '₹--';

//   final amountPatterns = [

//     RegExp(
//       r'debited(?:\s+for)?\s+rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
//       caseSensitive: false,
//     ),

//     RegExp(
//       r'credited(?:\s+for|\s+with)?\s+rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
//       caseSensitive: false,
//     ),

//     RegExp(
//       r'rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?).{0,35}?debited',
//       caseSensitive: false,
//     ),

//     RegExp(
//       r'rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?).{0,35}?credited',
//       caseSensitive: false,
//     ),
//   ];

//   for (final p in amountPatterns) {
//     final m = p.firstMatch(body);
//     if (m != null) {
//       amount = '₹${m.group(1)!}';
//       break;
//     }
//   }

//   // Available Balance
//   String availableBalance = '';

//   final balanceMatch = RegExp(
//     r'avl\s+bal\s+rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
//     caseSensitive: false,
//   ).firstMatch(body);

//   if (balanceMatch != null) {
//     availableBalance = '₹${balanceMatch.group(1)!}';
//   }

//   // Debit / Credit
//   final isDebit = text.contains('debited');
//   final isCredit = text.contains('credited');

//   // UPI detection
//   final isUpi =
//       text.contains('upi') ||
//       text.contains('utr') ||
//       text.contains('vpa') ||
//       text.contains('mob bk') ||
//       text.contains('mobile banking');

//   return {
//     'amount': amount,
//     'availableBalance': availableBalance,
//     'isDebit': isDebit,
//     'isCredit': isCredit,
//     'isUpi': isUpi,
//   };
// }

//   String extractAmount(String body) {
//   final text = body.toLowerCase();

//   final patterns = [

//     // Debited Rs.500
// // Debited Rs.500 or Debited Rs:500
// RegExp(
//   r'debited(?:\s+for)?\s+rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
//   caseSensitive: false,
// ),

// // Rs.500 debited or Rs:500 debited
// RegExp(
//   r'rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?).{0,30}?debited',
//   caseSensitive: false,
// ),

// // Credited Rs.500 or Credited Rs:500
// RegExp(
//   r'credited(?:\s+with|\s+for)?\s+rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
//   caseSensitive: false,
// ),

// // Rs.500 credited or Rs:500 credited
// RegExp(
//   r'rs(?:\.|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?).{0,30}?credited',
//   caseSensitive: false,
// ),
//   ];

//   for (final pattern in patterns) {
//     final match = pattern.firstMatch(text);

//     if (match != null) {
//       return '₹${match.group(1)}';
//     }
//   }

//   return '₹--';
// }



  List<String> get years {
    final list = widget.messages
        .map((sms) => DateTime.fromMillisecondsSinceEpoch(
              sms['date'],
            ).year.toString())
        .toSet()
        .toList();

    list.sort((a, b) => b.compareTo(a));

    return ['All', ...list];
  }

  List<Map<String, dynamic>> get filteredMessages {
    List<Map<String, dynamic>> list =
        List.from(widget.messages);

    // Out filter
    if (selectedFilter == 1) {
      list = list.where((sms) {
        final body =
            (sms['body'] ?? '')
                .toString()
                .toLowerCase();

        return body.contains('debited');
      }).toList();
    }

    // Month filter
    if (selectedMonth != 'All') {
      list = list.where((sms) {
        final date =
            DateTime.fromMillisecondsSinceEpoch(
          sms['date'],
        );

        return months[date.month] ==
            selectedMonth;
      }).toList();
    }

    // Year filter
    if (selectedYear != 'All') {
      list = list.where((sms) {
        final date =
            DateTime.fromMillisecondsSinceEpoch(
          sms['date'],
        );

        return date.year.toString() ==
            selectedYear;
      }).toList();
    }

    list.sort(
      (a, b) =>
          (b['date'] as int)
              .compareTo(a['date'] as int),
    );

    return list;
  }

  Map<String, List<Map<String, dynamic>>>
      get groupedMessages {
    final Map<String,
            List<Map<String, dynamic>>>
        grouped = {};

    for (final sms in filteredMessages) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(
        sms['date'],
      );

      final heading =
          '${months[date.month]} ${date.year}';

      grouped.putIfAbsent(
          heading, () => []);

      grouped[heading]!.add(sms);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupedMessages.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bankName),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child:
                      DropdownButtonFormField<
                          String>(
                    value: selectedMonth,
                    decoration:
                        const InputDecoration(
                      labelText: 'Month',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: months
                        .map(
                          (m) =>
                              DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth =
                            value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      DropdownButtonFormField<
                          String>(
                    value: selectedYear,
                    decoration:
                        const InputDecoration(
                      labelText: 'Year',
                      border:
                          OutlineInputBorder(),
                    ),
                    items: years
                        .map(
                          (y) =>
                              DropdownMenuItem(
                            value: y,
                            child: Text(y),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear =
                            value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFilter = 0;
                      });
                    },
                    child:
                        const Text('All'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedFilter = 1;
                      });
                    },
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.red,
                    ),
                    label:
                        const Text('Out'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder:
                  (context, groupIndex) {
                final group =
                    groups[groupIndex];

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: Colors.grey
                          .shade300,
                      child: Text(
                        group.key,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),

                    ...group.value.map(
                      (sms) {
                        final date =
                            DateTime.fromMillisecondsSinceEpoch(
                          sms['date'],
                        );




final transaction =
    SmsParser.parse(
      sms['body'] ?? '',
    );


return Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 18,
    ),
    child: Row(
  children: [

    Expanded(
      flex: 3,
      child: Text(
        '₹${transaction.amount ?? '--'}',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    
if (transaction.isUpi == AccountType.upi)

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(12),
          color: Colors.grey.shade300,
        ),
        child: const Text(
          'UPI',
        ),
      ),

    const Spacer(),

    Text(
      '${date.day}/${date.month}/${date.year}',
    ),
  ],
)
  
  
  ),
);
                  
                  
                  },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}