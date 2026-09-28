import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/manual_transaction.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../widgets/app_drawer.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState
    extends State<HomeDashboardScreen> {
  Box get transactionBox =>
      Hive.box('manualTransactions');

      bool darkMode = false;


  List<ManualTransaction> get transactions {
    return transactionBox.values
        .map(
          (e) => ManualTransaction.fromMap(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList()
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );
  }

  Future<void> showAddTransactionSheet() async {
    final amountController =
        TextEditingController();

    final noteController =
        TextEditingController();

    String type = 'outgoing';
    String category = 'Food';

    DateTime selectedDate =
        DateTime.now();

        final categories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Entertainment',
  'Health',
  'Clothes',
  'Salary',
  'Other',
];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    MediaQuery.of(context)
                            .viewInsets
                            .bottom +
                        16,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'incoming',
                        label:
                            Text('Incoming'),
                      ),
                      ButtonSegment<String>(
                        value: 'outgoing',
                        label:
                            Text('Outgoing'),
                      ),
                      ButtonSegment<String>(
                        value: 'payable',
                        label:
                            Text('To Pay'),
                      ),

                    ],
                    selected: {type},
                    onSelectionChanged:
                        (selection) {
                      modalSetState(() {
                        type =
                            selection.first;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller:
                        amountController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText: 'Amount',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
  value: category,
  decoration: const InputDecoration(
    labelText: 'Category',
    border: OutlineInputBorder(),
  ),
  items: categories.map((c) {
    return DropdownMenuItem(
      value: c,
      child: Text(c),
    );
  }).toList(),
  onChanged: (value) {
    if (value == null) return;

    modalSetState(() {
      category = value;
    });
  },
),

const SizedBox(height: 12),

                  TextField(
                    controller:
                        noteController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Info / Note',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    title: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    trailing:
                        const Icon(
                      Icons.calendar_month,
                    ),
                    onTap: () async {
                      final picked =
                          await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime(2020),
                        lastDate:
                            DateTime(2100),
                        initialDate:
                            selectedDate,
                      );

                      if (picked != null) {
                        modalSetState(() {
                          selectedDate =
                              picked;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (amountController
                            .text
                            .trim()
                            .isEmpty) {
                          return;
                        }

final transaction =
    ManualTransaction(
  id: DateTime.now()
      .millisecondsSinceEpoch
      .toString(),
  type: type,
  category: category,
  amount:
      double.tryParse(
            amountController.text,
          ) ??
          0,
  note: noteController.text,
  date: selectedDate
      .millisecondsSinceEpoch,
);
                        await transactionBox.put(
                          transaction.id,
                          transaction.toMap(),
                        );

                        if (mounted) {
                          Navigator.pop(
                              context);

                          setState(() {});
                        }
                      },
                      child:
                          const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final txns = transactions;

    final todayTransactions =
      txns.where(
        (t) => t.type != 'payable',
      ).toList();

  final payableTransactions =
      txns.where(
        (t) => t.type == 'payable',
      ).toList();

    

    return Scaffold(
      appBar: AppBar(
  title: const Text('Home'),
),
        drawer: AppDrawer(
  darkMode: darkMode,
  onThemeChanged: (value) {
    setState(() {
      darkMode = value;
    });
  },
),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            showAddTransactionSheet,
        icon: const Icon(Icons.add),
        label:
            const Text('Add Transaction'),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (txns.isEmpty)
            const Card(
              child: ListTile(
                title:
                    Text('No transactions'),
              ),
            ),

          ...todayTransactions.map((txn) {
            final date =
                DateTime.fromMillisecondsSinceEpoch(
              txn.date,
            );

            return Card(
              child: ListTile(
                leading: Icon(
                  txn.type ==
                          'incoming'
                      ? Icons
                          .arrow_downward
                      : Icons.arrow_upward,
                ),
                title: Text(
                  '₹${txn.amount.toStringAsFixed(0)}',
                ),
                subtitle: Column(
  crossAxisAlignment:
      CrossAxisAlignment.start,
  children: [
    Text(txn.category),
    if (txn.note.isNotEmpty)
      Text(txn.note),
  ],
),
                trailing: Text(
                  '${date.day}/${date.month}/${date.year}',
                ),
              ),
            );
          }),

const SizedBox(height: 24),

const Text(
  'To Pay',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

if (payableTransactions.isEmpty)
  const Card(
    child: ListTile(
      title: Text('Nothing to pay'),
    ),
  ),

...payableTransactions.map((txn) {

  final date =
      DateTime.fromMillisecondsSinceEpoch(
    txn.date,
  );

return Slidable(
  key: ValueKey(txn.id),

  endActionPane: ActionPane(
    motion: const DrawerMotion(),

    children: [

      SlidableAction(
        onPressed: (_) {
          // Edit later
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: Icons.edit,
        label: 'Edit',
      ),

      SlidableAction(
        onPressed: (_) async {

          await transactionBox.delete(
            txn.id,
          );

          setState(() {});

        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),

      SlidableAction(
        onPressed: (_) async {

          final updated =
              ManualTransaction(
            id: DateTime.now()
                .millisecondsSinceEpoch
                .toString(),
            type: 'outgoing',
            category: txn.category,
            amount: txn.amount,
            note: txn.note,
            date: DateTime.now()
                .millisecondsSinceEpoch,
          );

          await transactionBox.delete(
            txn.id,
          );

          await transactionBox.put(
            updated.id,
            updated.toMap(),
          );

          setState(() {});
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: Icons.check,
        label: 'Paid',
      ),
    ],
  ),

  child: Card(
    child: ListTile(
      leading: const Icon(
        Icons.pending_actions,
      ),
      title: Text(
        '₹${txn.amount.toStringAsFixed(0)}',
      ),
      subtitle: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(txn.category),
          if (txn.note.isNotEmpty)
            Text(txn.note),
        ],
      ),
      trailing: Text(
        '${date.day}/${date.month}/${date.year}',
      ),
    ),
  ),
);

}),

        ],
      ),
    );
  }
}