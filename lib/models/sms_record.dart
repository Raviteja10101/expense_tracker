class SmsRecord {
  final String sender;
  final String body;
  final int date;

  SmsRecord({
    required this.sender,
    required this.body,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'body': body,
      'date': date,
    };
  }

  factory SmsRecord.fromMap(Map map) {
    return SmsRecord(
      sender: map['sender'],
      body: map['body'],
      date: map['date'],
    );
  }
}