class NotificationModel {
  String type;

  NotificationModel(this.type);

  factory NotificationModel.fromJson(Map<String, dynamic> data) {
    return NotificationModel(
      data["type"]
    );
  }
}