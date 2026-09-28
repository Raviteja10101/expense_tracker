import 'package:transaction_sms_parser/transaction_sms_parser.dart';

class ParsedTransaction {
  final String amount;
  final bool isDebit;
  final bool isCredit;
  final bool isUpi;
  final String availableBalance;
  final String merchant;
  final String referenceNo;
  final String bankName;

  const ParsedTransaction({
    required this.amount,
    required this.isDebit,
    required this.isCredit,
    required this.isUpi,
    required this.availableBalance,
    required this.merchant,
    required this.referenceNo,
    required this.bankName,
  });
}

class SmsParser {
  static ParsedTransaction parse(String message) {

    final info =
        TransactionEngine.getTransactionInfo(
      message,
    );

    return ParsedTransaction(
      amount:
          info.transaction.amount ?? '--',

      isDebit:
          info.transaction.type ==
              TransactionType.debit,

      isCredit:
          info.transaction.type ==
              TransactionType.credit,

      isUpi:
          info.account.type ==
              AccountType.upi,

      availableBalance:
          info.balance?.available ?? '',

      merchant:
          info.transaction.merchant ?? '',

      referenceNo:
          info.transaction.referenceNo ?? '',

      bankName:
          info.account.bankName ?? '',
    );
  }
}