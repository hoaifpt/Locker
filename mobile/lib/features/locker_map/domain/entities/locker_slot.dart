/// Trạng thái của một ô tủ trên sơ đồ
enum LockerStatus {
  mine, // TỦ CỦA BẠN — đang thuê
  available, // TRỐNG — có thể đặt
  occupied, // ĐÃ ĐẶT — người khác đang dùng
}

/// Kích thước vật lý của tủ (ảnh hưởng số cột chiếm trên grid)
enum LockerSize { normal, large }

/// Pure domain entity — một ô tủ hiển thị trên bản đồ
class LockerSlot {
  final String id;
  final String code; // VD: "A01", "C01"
  final LockerStatus status;
  final LockerSize size;
  final String? locationName;
  final String? locationAddress;

  const LockerSlot({
    required this.id,
    required this.code,
    required this.status,
    this.size = LockerSize.normal,
    this.locationName,
    this.locationAddress,
  });
}
