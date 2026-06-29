enum DeliveryStatus { pending, deliveredToLocker, completed, cancelled }

extension DeliveryStatusExtension on DeliveryStatus {
  static DeliveryStatus fromString(String status) {
    switch (status) {
      case 'Pending':
        return DeliveryStatus.pending;
      case 'DeliveredToLocker':
        return DeliveryStatus.deliveredToLocker;
      case 'Completed':
        return DeliveryStatus.completed;
      case 'Cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }

  String toBackendString() {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.deliveredToLocker:
        return 'DeliveredToLocker';
      case DeliveryStatus.completed:
        return 'Completed';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }
}
