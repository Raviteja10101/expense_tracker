import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';



class SmsService {


  static const Set<String> allowedCodes = {
  // Private Banks
  'HDFCBK',
  'HDFCTX',
  'HDFCCN',
  'ICICIB',
  'ICICIT',
  'ICICIP',
  'AXISBK',
  'AXISTX',
  'AXISMD',
  'KOTAKB',
  'KOTAKT',
  'YESBNK',
  'YESTXN',
  'IDFCFB',
  'IDFCFT',
  'FIRSTB',
  'INDUSI',
  'ILBANK',
  'INDUST',
  'FEDBNK',
  'FEDTXN',
  'FEDFED',

  // Public Banks
  'SBIBNK',
  'SBIINB',
  'SBIPSG',
  'SBISMP',
  'BOBTXN',
  'BOBUPD',
  'BOBBNK',
  'BARODA',
  'PNBSMS',
  'PNBBNK',
  'PNBINF',
  'UNIONB',
  'UBISMS',
  'UBOTXP',
  'CNRBNK',
  'CANARA',
  'CNRTXN',
  'BOITXN',
  'BOISMS',
  'BOIBNK',
  'IDNBNK',
  'INDTXT',
  'ALBANK',
  'CBISMS',
  'CENTIN',
  'CBIBNK',

  // Payment Banks
  'PYTMBK',
  'PAYTM',
  'PYTMTX',
  'APBLTX',
  'AIRTEL',
  'APBLBK',
  'JIOPBL',
  'JIOPAY',
};

String? extractBankCode(String sender) {
  sender = sender.toUpperCase();

  for (final code in allowedCodes) {
    if (sender.contains(code)) {
      return code;
    }
  }

  return null;
}

bool isFinancialSender(String sender) {
  final regex =
      RegExp(r'^[A-Z]{2}-([A-Z0-9]{5,7})-([ST])$');

  final match = regex.firstMatch(
    sender.toUpperCase(),
  );

  if (match == null) {
    return false;
  }

  final middleCode = match.group(1)!;

  return allowedCodes.contains(middleCode);
}



  final SmsQuery query = SmsQuery();

  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

Future<void> syncMessages() async {
  final box = Hive.box('smsBox');

  // TEMPORARY FOR DEBUGGING
  // Removes all old filtered data
  await box.clear();

  final granted = await requestPermission();

  if (!granted) return;

final messages = await query.querySms(
  kinds: [SmsQueryKind.inbox],
  count: 5000,
);

final cutoffDate = DateTime.now()
    .subtract(const Duration(days: 90));



  print("========== SMS DEBUG ==========");
  print("TOTAL SMS FROM PHONE: ${messages.length}");

  // final last90Days = DateTime.now()
  //     .subtract(const Duration(days: 90));

final recentMessages = messages.where((sms) {
  final date = sms.date;

  return date != null &&
         date.isAfter(cutoffDate);
}).toList();

  print(
    "SMS FOUND IN LAST 90 DAYS: ${recentMessages.length}",
  );

  if (messages.isNotEmpty) {
    final sorted = List<SmsMessage>.from(messages);

    sorted.sort(
      (a, b) =>
          (a.date?.millisecondsSinceEpoch ?? 0)
              .compareTo(
        b.date?.millisecondsSinceEpoch ?? 0,
      ),
    );

    print("OLDEST SMS: ${sorted.first.date}");
    print("NEWEST SMS: ${sorted.last.date}");
  }

  print("========== END DEBUG ==========");

  int newestDate = 0;

  for (final sms in recentMessages) {
    final smsDate =
        sms.date?.millisecondsSinceEpoch ?? 0;

    final sender =
        sms.address ?? 'Unknown';

    final key = '${smsDate}_$sender';

    box.put(key, {
      'sender': sender,
      'body': sms.body ?? '',
      'date': smsDate,
    });

    if (smsDate > newestDate) {
      newestDate = smsDate;
    }
  }

  box.put('lastSync', newestDate);
}

  Future<List<Map<String, dynamic>>> loadMessages() async {
    final box = Hive.box('smsBox');

    final messages = <Map<String, dynamic>>[];

    for (final key in box.keys) {
      if (key == 'lastSync') continue;
      if (key == 'lastRefresh') continue;

      final data = box.get(key);

      if (data is Map) {
        messages.add(
          Map<String, dynamic>.from(data),
        );
      }
    }

    messages.sort(
      (a, b) => (b['date'] as int)
          .compareTo(a['date'] as int),
    );

    return messages;
  }

  Future<void> saveRefreshTime() async {
    final box = Hive.box('smsBox');

    box.put(
      'lastRefresh',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<int> getLastRefreshTime() async {
    final box = Hive.box('smsBox');

    return box.get(
          'lastRefresh',
          defaultValue: 0,
        ) as int;
  }

  Map<String, String> get codeToBank => {
  // Private Banks
  'HDFCBK': 'HDFC Bank',
  'HDFCTX': 'HDFC Bank',
  'HDFCCN': 'HDFC Bank',

  'ICICIB': 'ICICI Bank',
  'ICICIT': 'ICICI Bank',
  'ICICIP': 'ICICI Bank',

  'AXISBK': 'Axis Bank',
  'AXISTX': 'Axis Bank',
  'AXISMD': 'Axis Bank',

  'KOTAKB': 'Kotak Mahindra Bank',
  'KOTAKT': 'Kotak Mahindra Bank',

  'YESBNK': 'Yes Bank',
  'YESTXN': 'Yes Bank',

  'IDFCFB': 'IDFC First Bank',
  'IDFCFT': 'IDFC First Bank',
  'FIRSTB': 'IDFC First Bank',

  'INDUSI': 'IndusInd Bank',
  'ILBANK': 'IndusInd Bank',
  'INDUST': 'IndusInd Bank',

  'FEDBNK': 'Federal Bank',
  'FEDTXN': 'Federal Bank',
  'FEDFED': 'Federal Bank',

  // Public Banks
  'SBIBNK': 'State Bank of India',
  'SBIINB': 'State Bank of India',
  'SBIPSG': 'State Bank of India',
  'SBISMP': 'State Bank of India',

  'BOBTXN': 'Bank of Baroda',
  'BOBUPD': 'Bank of Baroda',
  'BOBBNK': 'Bank of Baroda',
  'BARODA': 'Bank of Baroda',

  'PNBSMS': 'Punjab National Bank',
  'PNBBNK': 'Punjab National Bank',
  'PNBINF': 'Punjab National Bank',

  'UNIONB': 'Union Bank of India',
  'UBISMS': 'Union Bank of India',
  'UBOTXP': 'Union Bank of India',

  'CNRBNK': 'Canara Bank',
  'CANARA': 'Canara Bank',
  'CNRTXN': 'Canara Bank',

  'BOITXN': 'Bank of India',
  'BOISMS': 'Bank of India',
  'BOIBNK': 'Bank of India',

  'IDNBNK': 'Indian Bank',
  'INDTXT': 'Indian Bank',
  'ALBANK': 'Indian Bank',

  'CBISMS': 'Central Bank of India',
  'CENTIN': 'Central Bank of India',
  'CBIBNK': 'Central Bank of India',

  // Payment Banks
  'PYTMBK': 'Paytm Payments Bank',
  'PAYTM': 'Paytm Payments Bank',
  'PYTMTX': 'Paytm Payments Bank',

  'APBLTX': 'Airtel Payments Bank',
  'AIRTEL': 'Airtel Payments Bank',
  'APBLBK': 'Airtel Payments Bank',

  'JIOPBL': 'Jio Payments Bank',
  'JIOPAY': 'Jio Payments Bank',
};

String? getBankName(String sender) {
  sender = sender.toUpperCase();

  for (final code in codeToBank.keys) {
    if (sender.contains(code)) {
      return codeToBank[code];
    }
  }

  return null;
}

}