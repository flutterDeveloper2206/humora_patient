class NotificationDeviceRequest {
  final String deviceToken;
  final String platform;

  const NotificationDeviceRequest({
    required this.deviceToken,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
        'deviceToken': deviceToken,
        'platform': platform,
      };
}
