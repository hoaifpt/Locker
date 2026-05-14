class SendDeliveryRequest {
  final String packageSizeId;
  final String? trackingCode;

  const SendDeliveryRequest({
    required this.packageSizeId,
    this.trackingCode,
  });
}
