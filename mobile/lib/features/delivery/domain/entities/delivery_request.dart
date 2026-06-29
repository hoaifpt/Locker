class SendDeliveryRequest {
  final String packageSizeId;
  final String packageSize;
  final String senderName;
  final String receiverPhone;
  final String lockerId;
  final int slotIndex;

  const SendDeliveryRequest({
    required this.packageSizeId,
    required this.packageSize,
    required this.senderName,
    required this.receiverPhone,
    required this.lockerId,
    required this.slotIndex,
  });
}
