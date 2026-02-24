class BleMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;

  BleMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
  });
}