enum AlertType { info, warning, critical, success }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertType type;
  bool isRead;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}
