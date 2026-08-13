// ============================================================
// SEED DATA — Frontend mock data matching backend DTOs exactly
// ============================================================

// ─── ENUMS (matching backend Domain/Enums) ────────────────
export type UserRole = 'User' | 'Admin' | 'Shipper';
export type OrderStatus = 'Initiated' | 'Reserved' | 'Paid' | 'Active' | 'Completed' | 'Cancelled';
export type BookingStatus = 'Pending' | 'Active' | 'Completed' | 'Canceled' | 'Expired';
export type SlotStatus = 'Available' | 'Reserved' | 'Occupied' | 'Maintenance';
export type PaymentStatus = 'Pending' | 'Completed' | 'Failed' | 'Refunded';
export type DeliveryStatus = 'Pending' | 'DeliveredToLocker' | 'Completed' | 'Cancelled';
export type SendReceiveStatus = 'Initiated' | 'Deposited' | 'Received' | 'Cancelled';
export type PackageSize = 'S' | 'M' | 'L' | 'XL';
export type FoodOrderStatus = 'PaymentRequired' | 'Pending' | 'Preparing' | 'Delivering' | 'DeliveredToLocker' | 'Completed' | 'Cancelled';

// ─── FOOD ORDERS & RESTAURANTS ────────────────────────────
export interface SeedRestaurant {
  id: string;
  name: string;
  description: string;
  address: string;
  imageUrl: string;
  rating: number;
  distanceKm: number;
}

export interface SeedMenuItem {
  id: string;
  restaurantId: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  category: string;
  isAvailable: boolean;
}

export interface SeedFoodOrder {
  id: string;
  userId: string;
  restaurantId: string;
  lockerId: string;
  slotIndex: number;
  items: { menuItemId: string; name: string; quantity: number; unitPrice: number; notes?: string }[];
  totalAmount: number;
  status: FoodOrderStatus;
  deliveryNotes?: string;
  createdAt: string;
}

export const SEED_RESTAURANTS: SeedRestaurant[] = [
  { id: 'res-001', name: 'Phở Thìn Lò Đúc', description: 'Phở bò gia truyền hương vị đậm đà, chuẩn vị Hà Nội.', address: '13 Lò Đúc, Quận 1, TP.HCM', imageUrl: 'https://www.themealdb.com/images/media/meals/z0ageb1583189517.jpg', rating: 4.8, distanceKm: 1.2 },
  { id: 'res-002', name: 'Bún Chả Hương Liên', description: 'Bún chả Obama nức tiếng, chả nướng than hoa thơm lừng.', address: '24 Lê Văn Hưu, Quận 1, TP.HCM', imageUrl: 'https://www.themealdb.com/images/media/meals/sytuqu1511553755.jpg', rating: 4.7, distanceKm: 0.8 },
  { id: 'res-003', name: 'Highlands Coffee', description: 'Cà phê rang xay đậm vị Việt Nam và các loại bánh ngọt.', address: 'Tầng 1 Vincom Center, Quận 1, TP.HCM', imageUrl: 'https://www.thecocktaildb.com/images/media/drink/vqpwyv1478963050.jpg', rating: 4.5, distanceKm: 2.5 },
  { id: 'res-004', name: 'Pizza 4P\'s', description: 'Pizza nướng củi chuẩn vị Ý, kết hợp nguyên liệu tươi từ Đà Lạt.', address: 'Hai Bà Trưng, Quận 1, TP.HCM', imageUrl: 'https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg', rating: 4.9, distanceKm: 3.1 },
  { id: 'res-005', name: 'Phúc Long Tea & Coffee', description: 'Trà ô long sữa, trà đào cam sả đặc sản đậm vị trà.', address: 'Estella Place, Quận 2, TP.HCM', imageUrl: 'https://www.thecocktaildb.com/images/media/drink/xxsqpv1468875108.jpg', rating: 4.6, distanceKm: 5.4 },
  { id: 'res-006', name: 'Cơm Tấm Ba Ghiền', description: 'Cơm tấm sườn bì chả truyền thống khổng lồ ngon khó cưỡng.', address: 'Đặng Văn Ngữ, Phú Nhuận, TP.HCM', imageUrl: 'https://www.themealdb.com/images/media/meals/1529446327.jpg', rating: 4.4, distanceKm: 1.5 },
];

export const SEED_MENU_ITEMS: SeedMenuItem[] = [
  // Phở Thìn
  { id: 'mi-001', restaurantId: 'res-001', name: 'Phở Tái Lăn', description: 'Phở bò xào lăn với hành phi, nước dùng béo ngậy.', price: 75000, imageUrl: 'https://www.themealdb.com/images/media/meals/z0ageb1583189517.jpg', category: 'Món chính', isAvailable: true },
  { id: 'mi-002', restaurantId: 'res-001', name: 'Phở Nạm Gầu', description: 'Phở nạm gầu giòn sừn sựt.', price: 65000, imageUrl: 'https://www.themealdb.com/images/media/meals/z0ageb1583189517.jpg', category: 'Món chính', isAvailable: true },
  { id: 'mi-003', restaurantId: 'res-001', name: 'Quẩy giòn', description: 'Quẩy ăn kèm phở', price: 10000, imageUrl: 'https://www.themealdb.com/images/media/meals/rwuyqx1511383174.jpg', category: 'Ăn kèm', isAvailable: true },
  { id: 'mi-004', restaurantId: 'res-001', name: 'Trà đá', description: 'Trà đá giải nhiệt', price: 5000, imageUrl: 'https://www.thecocktaildb.com/images/media/drink/vrwquq1441552834.jpg', category: 'Đồ uống', isAvailable: true },
  // Bún Chả
  { id: 'mi-005', restaurantId: 'res-002', name: 'Suất Bún Chả Đặc Biệt', description: 'Bún, chả nướng, nem cua bể.', price: 80000, imageUrl: 'https://www.themealdb.com/images/media/meals/sytuqu1511553755.jpg', category: 'Món chính', isAvailable: true },
  { id: 'mi-006', restaurantId: 'res-002', name: 'Nem Cua Bể', description: 'Nem cua bể chiên giòn, nhân tôm cua thịt.', price: 25000, imageUrl: 'https://www.themealdb.com/images/media/meals/rwuyqx1511383174.jpg', category: 'Ăn kèm', isAvailable: true },
  // Highlands
  { id: 'mi-007', restaurantId: 'res-003', name: 'Phin Sữa Đá', description: 'Cà phê phin sữa đặc truyền thống.', price: 35000, imageUrl: 'https://www.thecocktaildb.com/images/media/drink/vqpwyv1478963050.jpg', category: 'Cà Phê', isAvailable: true },
  { id: 'mi-008', restaurantId: 'res-003', name: 'Trà Sen Vàng', description: 'Trà sen thanh mát kèm thạch.', price: 45000, imageUrl: 'https://www.thecocktaildb.com/images/media/drink/xxsqpv1468875108.jpg', category: 'Trà', isAvailable: true },
  { id: 'mi-009', restaurantId: 'res-003', name: 'Bánh Chuối Trái Cây', description: 'Bánh chuối ngọt nhẹ, mềm xốp.', price: 29000, imageUrl: 'https://www.themealdb.com/images/media/meals/rwuyqx1511383174.jpg', category: 'Bánh', isAvailable: true },
  // Pizza 4P's
  { id: 'mi-010', restaurantId: 'res-004', name: 'Pizza Margherita', description: 'Sốt cà chua, phô mai Mozzarella tự làm.', price: 150000, imageUrl: 'https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg', category: 'Pizza', isAvailable: true },
  { id: 'mi-011', restaurantId: 'res-004', name: 'Pizza Half & Half', description: 'Chọn 2 nửa tuỳ ý.', price: 200000, imageUrl: 'https://www.themealdb.com/images/media/meals/x0lk931587671540.jpg', category: 'Pizza', isAvailable: true },
  { id: 'mi-012', restaurantId: 'res-004', name: 'Salad Rau Mầm', description: 'Salad rau mầm với sốt mù tạt mật ong.', price: 80000, imageUrl: 'https://www.themealdb.com/images/media/meals/uwxqpt1487339281.jpg', category: 'Salad', isAvailable: true },
  // Phúc Long
  { id: 'mi-013', restaurantId: 'res-005', name: 'Trà Sữa Phúc Long', description: 'Trà sữa đậm vị.', price: 55000, imageUrl: 'https://www.thecocktaildb.com/images/media/drink/xxsqpv1468875108.jpg', category: 'Trà Sữa', isAvailable: true },
  { id: 'mi-014', restaurantId: 'res-005', name: 'Trà Đào Cam Sả', description: 'Trà đào thanh mát.', price: 50000, imageUrl: 'https://www.thecocktaildb.com/images/media/drink/vrwquq1441552834.jpg', category: 'Trà Trái Cây', isAvailable: true },
  // Cơm Tấm
  { id: 'mi-015', restaurantId: 'res-006', name: 'Cơm Tấm Sườn Bì Chả', description: 'Sườn nướng than hoa siêu to.', price: 70000, imageUrl: 'https://www.themealdb.com/images/media/meals/1529446327.jpg', category: 'Món chính', isAvailable: true },
  { id: 'mi-016', restaurantId: 'res-006', name: 'Cơm Tấm Đùi Gà', description: 'Đùi gà xối mỡ mắm tỏi.', price: 65000, imageUrl: 'https://www.themealdb.com/images/media/meals/1529446327.jpg', category: 'Món chính', isAvailable: true },
];

export const SEED_FOOD_ORDERS: SeedFoodOrder[] = [
  {
    id: 'fo-001',
    userId: 'u-001',
    restaurantId: 'res-003',
    lockerId: 'locker-01',
    slotIndex: 3,
    items: [
      { menuItemId: 'mi-007', name: 'Phin Sữa Đá', quantity: 2, unitPrice: 35000 },
      { menuItemId: 'mi-009', name: 'Bánh Chuối Trái Cây', quantity: 1, unitPrice: 29000 }
    ],
    totalAmount: 99000,
    status: 'DeliveredToLocker',
    createdAt: new Date(Date.now() - 1000 * 60 * 30).toISOString(), // 30 mins ago
  },
  {
    id: 'fo-002',
    userId: 'u-001',
    restaurantId: 'res-001',
    lockerId: 'locker-01',
    slotIndex: 0,
    items: [
      { menuItemId: 'mi-001', name: 'Phở Tái Lăn', quantity: 1, unitPrice: 75000 },
      { menuItemId: 'mi-003', name: 'Quẩy giòn', quantity: 2, unitPrice: 10000, notes: 'Để riêng' }
    ],
    totalAmount: 95000,
    status: 'Preparing',
    createdAt: new Date(Date.now() - 1000 * 60 * 5).toISOString(), // 5 mins ago
  }
];

export function getFoodOrdersByUser(userId: string) {
  return SEED_FOOD_ORDERS.filter((o) => o.userId === userId).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
}

export function getRestaurantById(id: string) {
  return SEED_RESTAURANTS.find((r) => r.id === id);
}

export function getMenuByRestaurant(restaurantId: string) {
  return SEED_MENU_ITEMS.filter((m) => m.restaurantId === restaurantId);
}

// ─── USERS ────────────────────────────────────────────────
export interface SeedUser {
  id: string;
  username: string;
  email: string;
  fullName: string;
  phoneNumber: string;
  role: UserRole;
  isActive: boolean;
  isEmailVerified: boolean;
  createdAt: string;
  _mockPassword: string;
}

export const SEED_USERS: SeedUser[] = [
  { id: 'u-001', username: 'nguyen_van_a', email: 'nguyenvana@gmail.com', fullName: 'Nguyễn Văn A', phoneNumber: '0901234567', role: 'User', isActive: true, isEmailVerified: true, createdAt: '2025-10-01T08:00:00Z', _mockPassword: 'User@123' },
  { id: 'u-002', username: 'tran_thi_b', email: 'tranthib@gmail.com', fullName: 'Trần Thị B', phoneNumber: '0912345678', role: 'User', isActive: true, isEmailVerified: true, createdAt: '2025-10-05T09:30:00Z', _mockPassword: 'User@123' },
  { id: 'u-003', username: 'le_van_c', email: 'levanc@gmail.com', fullName: 'Lê Văn C', phoneNumber: '0923456789', role: 'User', isActive: true, isEmailVerified: false, createdAt: '2025-10-10T10:15:00Z', _mockPassword: 'User@123' },
  { id: 'u-004', username: 'pham_thi_d', email: 'phamthid@gmail.com', fullName: 'Phạm Thị D', phoneNumber: '0934567890', role: 'User', isActive: true, isEmailVerified: true, createdAt: '2025-10-15T11:00:00Z', _mockPassword: 'User@123' },
  { id: 'u-005', username: 'hoang_van_e', email: 'hoangvane@gmail.com', fullName: 'Hoàng Văn E', phoneNumber: '0945678901', role: 'User', isActive: false, isEmailVerified: true, createdAt: '2025-10-20T12:30:00Z', _mockPassword: 'User@123' },
  { id: 'u-006', username: 'vo_thi_f', email: 'vothif@gmail.com', fullName: 'Võ Thị F', phoneNumber: '0956789012', role: 'User', isActive: true, isEmailVerified: true, createdAt: '2025-11-01T08:00:00Z', _mockPassword: 'User@123' },
  { id: 'u-007', username: 'dang_van_g', email: 'dangvang@gmail.com', fullName: 'Đặng Văn G', phoneNumber: '0967890123', role: 'User', isActive: true, isEmailVerified: true, createdAt: '2025-11-05T09:00:00Z', _mockPassword: 'User@123' },
  { id: 'u-008', username: 'bui_thi_h', email: 'buithih@gmail.com', fullName: 'Bùi Thị H', phoneNumber: '0978901234', role: 'User', isActive: true, isEmailVerified: false, createdAt: '2025-11-10T10:00:00Z', _mockPassword: 'User@123' },
  { id: 'u-009', username: 'do_van_i', email: 'dovani@gmail.com', fullName: 'Đỗ Văn I', phoneNumber: '0989012345', role: 'User', isActive: true, isEmailVerified: true, createdAt: '2025-11-15T11:00:00Z', _mockPassword: 'User@123' },
  { id: 'u-010', username: 'ngo_thi_k', email: 'ngothik@gmail.com', fullName: 'Ngô Thị K', phoneNumber: '0990123456', role: 'User', isActive: true, isEmailVerified: true, createdAt: '2025-11-20T12:00:00Z', _mockPassword: 'User@123' },
  // Admins
  { id: 'a-001', username: 'admin_hoai', email: 'admin.hoai@luxelock.vn', fullName: 'Hoài Admin', phoneNumber: '0901111111', role: 'Admin', isActive: true, isEmailVerified: true, createdAt: '2025-09-01T07:00:00Z', _mockPassword: 'Admin@123' },
  { id: 'a-002', username: 'admin_minh', email: 'admin.minh@luxelock.vn', fullName: 'Minh Admin', phoneNumber: '0902222222', role: 'Admin', isActive: true, isEmailVerified: true, createdAt: '2025-09-01T07:30:00Z', _mockPassword: 'Admin@123' },
  // Shippers
  { id: 's-001', username: 'shipper_nam', email: 'shipper.nam@luxelock.vn', fullName: 'Nguyễn Nam', phoneNumber: '0911111111', role: 'Shipper', isActive: true, isEmailVerified: true, createdAt: '2025-09-15T08:00:00Z', _mockPassword: 'Shipper@123' },
  { id: 's-002', username: 'shipper_hung', email: 'shipper.hung@luxelock.vn', fullName: 'Trần Hùng', phoneNumber: '0912222222', role: 'Shipper', isActive: true, isEmailVerified: true, createdAt: '2025-09-16T08:30:00Z', _mockPassword: 'Shipper@123' },
  { id: 's-003', username: 'shipper_lan', email: 'shipper.lan@luxelock.vn', fullName: 'Lê Lan', phoneNumber: '0913333333', role: 'Shipper', isActive: true, isEmailVerified: true, createdAt: '2025-09-17T09:00:00Z', _mockPassword: 'Shipper@123' },
];

// ─── PACKAGES (matching PackageDto) ───────────────────────
export interface SeedPackage {
  id: string;
  name: string;
  size: PackageSize;
  description: string;
  pricePerHour: number;
  isActive: boolean;
}

export const SEED_PACKAGES: SeedPackage[] = [
  { id: 'pkg-001', name: 'Gói Nhỏ S', size: 'S', description: 'Phù hợp cho túi xách, laptop, đồ vật nhỏ. Kích thước 30×30×40 cm.', pricePerHour: 5000, isActive: true },
  { id: 'pkg-002', name: 'Gói Vừa M', size: 'M', description: 'Lý tưởng cho ba lô, vali du lịch nhỏ. Kích thước 40×40×60 cm.', pricePerHour: 8000, isActive: true },
  { id: 'pkg-003', name: 'Gói Lớn L', size: 'L', description: 'Dành cho vali cỡ trung, thiết bị thể thao. Kích thước 50×50×80 cm.', pricePerHour: 12000, isActive: true },
  { id: 'pkg-004', name: 'Gói XL', size: 'XL', description: 'Dành cho hàng cồng kềnh, vali lớn. Kích thước 60×60×100 cm.', pricePerHour: 18000, isActive: true },
  { id: 'pkg-005', name: 'Gói Nhỏ S (Cũ)', size: 'S', description: 'Phiên bản cũ đã ngừng kinh doanh.', pricePerHour: 4000, isActive: false },
  { id: 'pkg-006', name: 'Gói Vừa M (Cao cấp)', size: 'M', description: 'Gói M với ổ cắm sạc điện thoại bên trong.', pricePerHour: 10000, isActive: true },
];

// ─── LOCKERS (matching LockerDto) ─────────────────────────
export interface LockerSlot {
  index: number;
  status: SlotStatus;
  size: PackageSize;
  sensorState: string;
  bookingId?: string;
}

export interface SeedLocker {
  id: string;
  name: string;
  location: string;
  latitude: number;
  longitude: number;
  isAutoLockEnabled: boolean;
  isIntrusionAlertEnabled: boolean;
  slots: LockerSlot[];
}

function makeSlots(count: number, overrides: Partial<Record<number, { status: SlotStatus; size?: PackageSize }>> = {}): LockerSlot[] {
  const sizes: PackageSize[] = ['S', 'M', 'L', 'XL'];
  return Array.from({ length: count }, (_, i) => ({
    index: i,
    status: overrides[i]?.status ?? 'Available',
    size: overrides[i]?.size ?? sizes[i % sizes.length],
    sensorState: 'Closed',
    bookingId: overrides[i]?.status && overrides[i]?.status !== 'Available' ? `bk-auto-${i}` : undefined,
  }));
}

export const SEED_LOCKERS: SeedLocker[] = [
  { id: 'lk-001', name: 'Tủ Khóa Vincom Đồng Khởi', location: '72 Lê Thánh Tôn, Quận 1, TP.HCM', latitude: 10.7717, longitude: 106.7033, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(12, { 2: { status: 'Occupied' }, 5: { status: 'Reserved' }, 9: { status: 'Occupied' } }) },
  { id: 'lk-002', name: 'Tủ Khóa Landmark 81', location: '772A Điện Biên Phủ, Bình Thạnh, TP.HCM', latitude: 10.7926, longitude: 106.6949, isAutoLockEnabled: true, isIntrusionAlertEnabled: false, slots: makeSlots(16, { 0: { status: 'Occupied' }, 3: { status: 'Occupied' }, 7: { status: 'Reserved' }, 14: { status: 'Occupied' } }) },
  { id: 'lk-003', name: 'Tủ Khóa Aeon Mall Tân Phú', location: '30 Bờ Bao Tân Thắng, Tân Phú, TP.HCM', latitude: 10.7806, longitude: 106.6278, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(8, { 1: { status: 'Reserved' }, 4: { status: 'Occupied' } }) },
  { id: 'lk-004', name: 'Tủ Khóa Ga Sài Gòn', location: '1 Nguyễn Thông, Quận 3, TP.HCM', latitude: 10.7843, longitude: 106.7047, isAutoLockEnabled: false, isIntrusionAlertEnabled: true, slots: makeSlots(10, { 0: { status: 'Occupied' }, 2: { status: 'Occupied' }, 6: { status: 'Occupied' }, 8: { status: 'Reserved' } }) },
  { id: 'lk-005', name: 'Tủ Khóa Sân Bay Tân Sơn Nhất T1', location: 'Nhà ga T1, Trường Chinh, Tân Bình, TP.HCM', latitude: 10.8167, longitude: 106.6567, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(20, { 1: { status: 'Occupied' }, 3: { status: 'Occupied' }, 5: { status: 'Occupied' }, 9: { status: 'Reserved' }, 12: { status: 'Occupied' } }) },
  { id: 'lk-006', name: 'Tủ Khóa Sân Bay Tân Sơn Nhất T2', location: 'Nhà ga T2, Trường Chinh, Tân Bình, TP.HCM', latitude: 10.8183, longitude: 106.6533, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(20, { 0: { status: 'Occupied' }, 4: { status: 'Occupied' }, 10: { status: 'Reserved' }, 16: { status: 'Occupied' } }) },
  { id: 'lk-007', name: 'Tủ Khóa Bến xe Miền Đông', location: '292 Đinh Bộ Lĩnh, Bình Thạnh, TP.HCM', latitude: 10.8033, longitude: 106.6717, isAutoLockEnabled: false, isIntrusionAlertEnabled: false, slots: makeSlots(8, { 2: { status: 'Occupied' }, 6: { status: 'Reserved' } }) },
  { id: 'lk-008', name: 'Tủ Khóa Parkson Hùng Vương', location: '126 Hùng Vương, Quận 5, TP.HCM', latitude: 10.7629, longitude: 106.6681, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(12, { 1: { status: 'Occupied' }, 5: { status: 'Occupied' }, 10: { status: 'Occupied' } }) },
  { id: 'lk-009', name: 'Tủ Khóa RMIT Sài Gòn', location: '702 Nguyễn Văn Linh, Quận 7, TP.HCM', latitude: 10.7548, longitude: 106.7117, isAutoLockEnabled: true, isIntrusionAlertEnabled: false, slots: makeSlots(6, { 0: { status: 'Occupied' }, 3: { status: 'Reserved' } }) },
  { id: 'lk-010', name: 'Tủ Khóa Vivo City', location: '1058A Nguyễn Văn Linh, Quận 7, TP.HCM', latitude: 10.7444, longitude: 106.7156, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(10, { 4: { status: 'Occupied' }, 7: { status: 'Occupied' } }) },
  { id: 'lk-011', name: 'Tủ Khóa Lotte Mart Quận 7', location: '469 Nguyễn Hữu Thọ, Quận 7, TP.HCM', latitude: 10.7367, longitude: 106.7256, isAutoLockEnabled: false, isIntrusionAlertEnabled: true, slots: makeSlots(8, { 2: { status: 'Reserved' }, 5: { status: 'Occupied' } }) },
  { id: 'lk-012', name: 'Tủ Khóa Big C An Lạc', location: 'QL1A, Bình Tân, TP.HCM', latitude: 10.7489, longitude: 106.6067, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(12, { 0: { status: 'Occupied' }, 6: { status: 'Reserved' } }) },
  { id: 'lk-013', name: 'Tủ Khóa Nowzone Fashion Mall', location: '235 Nguyễn Văn Cừ, Quận 1, TP.HCM', latitude: 10.7689, longitude: 106.6733, isAutoLockEnabled: true, isIntrusionAlertEnabled: false, slots: makeSlots(6) },
  { id: 'lk-014', name: 'Tủ Khóa Crescent Mall', location: '101 Tôn Dật Tiên, Quận 7, TP.HCM', latitude: 10.7472, longitude: 106.7189, isAutoLockEnabled: true, isIntrusionAlertEnabled: true, slots: makeSlots(10, { 1: { status: 'Occupied' }, 3: { status: 'Occupied' }, 8: { status: 'Occupied' } }) },
  { id: 'lk-015', name: 'Tủ Khóa SC VivoCity', location: '1058A Nguyễn Văn Linh, Quận 7, TP.HCM', latitude: 10.7444, longitude: 106.7156, isAutoLockEnabled: false, isIntrusionAlertEnabled: false, slots: makeSlots(8, { 4: { status: 'Reserved' } }) },
];

// ─── ORDERS (matching OrderDto) ───────────────────────────
export interface SeedOrder {
  id: string;
  userId: string;
  lockerId: string;
  slotIndex: number;
  packageId: string;
  status: OrderStatus;
  checkInTime: string;
  checkOutTime: string;
  durationHours: number;
  baseRate: number;
  subtotal: number;
  taxes: number;
  discount: number;
  totalAmount: number;
  paymentId?: string;
  mobileNumber: string;
  pin?: string;
  cancellationReason?: string;
  notes?: string;
  createdAt: string;
  reservedAt?: string;
  paidAt?: string;
  startedAt?: string;
  completedAt?: string;
  cancelledAt?: string;
}

export const SEED_ORDERS: SeedOrder[] = [
  {
    id: 'ord-001', userId: 'u-001', lockerId: 'lk-001', slotIndex: 2, packageId: 'pkg-002',
    status: 'Active', checkInTime: '2026-06-22T08:00:00Z', checkOutTime: '2026-06-22T14:00:00Z',
    durationHours: 6, baseRate: 8000, subtotal: 48000, taxes: 4800, discount: 0, totalAmount: 52800,
    paymentId: 'pay-ord-001', mobileNumber: '0901234567', pin: '123456',
    createdAt: '2026-06-22T07:45:00Z', reservedAt: '2026-06-22T07:46:00Z',
    paidAt: '2026-06-22T07:50:00Z', startedAt: '2026-06-22T08:00:00Z',
    notes: 'Gửi laptop và ba lô',
  },
  {
    id: 'ord-002', userId: 'u-001', lockerId: 'lk-005', slotIndex: 3, packageId: 'pkg-003',
    status: 'Completed', checkInTime: '2026-06-20T09:00:00Z', checkOutTime: '2026-06-20T17:00:00Z',
    durationHours: 8, baseRate: 12000, subtotal: 96000, taxes: 9600, discount: 5000, totalAmount: 100600,
    paymentId: 'pay-ord-002', mobileNumber: '0901234567', pin: '654321',
    createdAt: '2026-06-20T08:30:00Z', reservedAt: '2026-06-20T08:31:00Z',
    paidAt: '2026-06-20T08:40:00Z', startedAt: '2026-06-20T09:00:00Z', completedAt: '2026-06-20T17:05:00Z',
  },
  {
    id: 'ord-003', userId: 'u-002', lockerId: 'lk-002', slotIndex: 0, packageId: 'pkg-001',
    status: 'Paid', checkInTime: '2026-06-23T10:00:00Z', checkOutTime: '2026-06-23T13:00:00Z',
    durationHours: 3, baseRate: 5000, subtotal: 15000, taxes: 1500, discount: 0, totalAmount: 16500,
    paymentId: 'pay-ord-003', mobileNumber: '0912345678',
    createdAt: '2026-06-22T20:00:00Z', reservedAt: '2026-06-22T20:01:00Z', paidAt: '2026-06-22T20:05:00Z',
  },
  {
    id: 'ord-004', userId: 'u-004', lockerId: 'lk-006', slotIndex: 4, packageId: 'pkg-004',
    status: 'Active', checkInTime: '2026-06-22T04:00:00Z', checkOutTime: '2026-06-23T04:00:00Z',
    durationHours: 24, baseRate: 18000, subtotal: 432000, taxes: 43200, discount: 20000, totalAmount: 455200,
    paymentId: 'pay-ord-004', mobileNumber: '0934567890', pin: '111222',
    createdAt: '2026-06-22T03:30:00Z', reservedAt: '2026-06-22T03:31:00Z',
    paidAt: '2026-06-22T03:40:00Z', startedAt: '2026-06-22T04:00:00Z',
    notes: 'Vali lớn đi du lịch',
  },
  {
    id: 'ord-005', userId: 'u-001', lockerId: 'lk-003', slotIndex: 1, packageId: 'pkg-001',
    status: 'Cancelled', checkInTime: '2026-06-18T14:00:00Z', checkOutTime: '2026-06-18T16:00:00Z',
    durationHours: 2, baseRate: 5000, subtotal: 10000, taxes: 1000, discount: 0, totalAmount: 11000,
    mobileNumber: '0901234567', cancellationReason: 'Thay đổi kế hoạch',
    createdAt: '2026-06-18T13:30:00Z', cancelledAt: '2026-06-18T13:45:00Z',
  },
  {
    id: 'ord-006', userId: 'u-006', lockerId: 'lk-010', slotIndex: 4, packageId: 'pkg-002',
    status: 'Completed', checkInTime: '2026-06-21T10:00:00Z', checkOutTime: '2026-06-21T16:00:00Z',
    durationHours: 6, baseRate: 8000, subtotal: 48000, taxes: 4800, discount: 0, totalAmount: 52800,
    paymentId: 'pay-ord-006', mobileNumber: '0956789012', pin: '789012',
    createdAt: '2026-06-21T09:40:00Z', reservedAt: '2026-06-21T09:41:00Z',
    paidAt: '2026-06-21T09:50:00Z', startedAt: '2026-06-21T10:00:00Z', completedAt: '2026-06-21T16:10:00Z',
  },
  {
    id: 'ord-007', userId: 'u-007', lockerId: 'lk-009', slotIndex: 0, packageId: 'pkg-001',
    status: 'Active', checkInTime: '2026-06-22T06:00:00Z', checkOutTime: '2026-06-22T18:00:00Z',
    durationHours: 12, baseRate: 5000, subtotal: 60000, taxes: 6000, discount: 0, totalAmount: 66000,
    paymentId: 'pay-ord-007', mobileNumber: '0967890123', pin: '555666',
    createdAt: '2026-06-22T05:30:00Z', reservedAt: '2026-06-22T05:31:00Z',
    paidAt: '2026-06-22T05:40:00Z', startedAt: '2026-06-22T06:00:00Z',
  },
  {
    id: 'ord-008', userId: 'u-002', lockerId: 'lk-001', slotIndex: 9, packageId: 'pkg-006',
    status: 'Initiated', checkInTime: '2026-06-23T09:00:00Z', checkOutTime: '2026-06-23T15:00:00Z',
    durationHours: 6, baseRate: 10000, subtotal: 60000, taxes: 6000, discount: 0, totalAmount: 66000,
    mobileNumber: '0912345678',
    createdAt: '2026-06-22T23:00:00Z',
  },
];

// ─── BOOKINGS (matching BookingDto) ───────────────────────
export interface SeedBooking {
  id: string;
  userId: string;
  userName: string;
  lockerId: string;
  lockerName: string;
  lockerLocation: string;
  slotIndex: number;
  packageId: string;
  packageName: string;
  packageSize: PackageSize;
  mobileNumber: string;
  status: BookingStatus;
  totalAmount: number;
  paymentId?: string;
  createdAt: string;
  startedAt?: string;
  completedAt?: string;
}

export const SEED_BOOKINGS: SeedBooking[] = [
  { id: 'bk-001', userId: 'u-001', userName: 'Nguyễn Văn A', lockerId: 'lk-001', lockerName: 'Tủ Khóa Vincom Đồng Khởi', lockerLocation: '72 Lê Thánh Tôn, Quận 1, TP.HCM', slotIndex: 2, packageId: 'pkg-002', packageName: 'Gói Vừa M', packageSize: 'M', mobileNumber: '0901234567', status: 'Active', totalAmount: 24000, paymentId: 'pay-001', createdAt: '2026-02-20T08:00:00Z', startedAt: '2026-02-20T08:15:00Z' },
  { id: 'bk-002', userId: 'u-002', userName: 'Trần Thị B', lockerId: 'lk-005', lockerName: 'Tủ Khóa Sân Bay Tân Sơn Nhất T1', lockerLocation: 'Nhà ga T1, Trường Chinh, Tân Bình, TP.HCM', slotIndex: 1, packageId: 'pkg-003', packageName: 'Gói Lớn L', packageSize: 'L', mobileNumber: '0912345678', status: 'Completed', totalAmount: 84000, paymentId: 'pay-002', createdAt: '2026-02-15T06:00:00Z', startedAt: '2026-02-15T06:30:00Z', completedAt: '2026-02-15T13:30:00Z' },
  { id: 'bk-003', userId: 'u-003', userName: 'Lê Văn C', lockerId: 'lk-002', lockerName: 'Tủ Khóa Landmark 81', lockerLocation: '772A Điện Biên Phủ, Bình Thạnh, TP.HCM', slotIndex: 7, packageId: 'pkg-001', packageName: 'Gói Nhỏ S', packageSize: 'S', mobileNumber: '0923456789', status: 'Pending', totalAmount: 0, createdAt: '2026-02-27T07:00:00Z' },
  { id: 'bk-004', userId: 'u-001', userName: 'Nguyễn Văn A', lockerId: 'lk-004', lockerName: 'Tủ Khóa Ga Sài Gòn', lockerLocation: '1 Nguyễn Thông, Quận 3, TP.HCM', slotIndex: 0, packageId: 'pkg-002', packageName: 'Gói Vừa M', packageSize: 'M', mobileNumber: '0901234567', status: 'Canceled', totalAmount: 0, createdAt: '2026-02-10T11:00:00Z' },
  { id: 'bk-005', userId: 'u-004', userName: 'Phạm Thị D', lockerId: 'lk-006', lockerName: 'Tủ Khóa Sân Bay Tân Sơn Nhất T2', lockerLocation: 'Nhà ga T2, Trường Chinh, Tân Bình, TP.HCM', slotIndex: 4, packageId: 'pkg-004', packageName: 'Gói XL', packageSize: 'XL', mobileNumber: '0934567890', status: 'Active', totalAmount: 180000, paymentId: 'pay-005', createdAt: '2026-02-26T04:00:00Z', startedAt: '2026-02-26T04:30:00Z' },
];

// ─── PAYMENTS (matching PaymentDto) ───────────────────────
export interface SeedPayment {
  id: string;
  bookingId?: string;
  orderId?: string;
  userId: string;
  amount: number;
  status: PaymentStatus;
  method: string;
  transactionId?: string;
  createdAt: string;
  paidAt?: string;
}

export const SEED_PAYMENTS: SeedPayment[] = [
  { id: 'pay-001', bookingId: 'bk-001', userId: 'u-001', amount: 24000, status: 'Completed', method: 'VNPay', transactionId: 'VNP20260220081500001', createdAt: '2026-02-20T08:00:00Z', paidAt: '2026-02-20T08:15:00Z' },
  { id: 'pay-002', bookingId: 'bk-002', userId: 'u-002', amount: 84000, status: 'Completed', method: 'MoMo', transactionId: 'MOMO20260215063000002', createdAt: '2026-02-15T06:00:00Z', paidAt: '2026-02-15T06:30:00Z' },
  { id: 'pay-005', bookingId: 'bk-005', userId: 'u-004', amount: 180000, status: 'Completed', method: 'ZaloPay', transactionId: 'ZLP20260226043000005', createdAt: '2026-02-26T04:00:00Z', paidAt: '2026-02-26T04:30:00Z' },
  // Order payments
  { id: 'pay-ord-001', orderId: 'ord-001', userId: 'u-001', amount: 52800, status: 'Completed', method: 'VNPay', transactionId: 'VNP20260622075000101', createdAt: '2026-06-22T07:48:00Z', paidAt: '2026-06-22T07:50:00Z' },
  { id: 'pay-ord-002', orderId: 'ord-002', userId: 'u-001', amount: 100600, status: 'Completed', method: 'MoMo', transactionId: 'MOMO20260620084000102', createdAt: '2026-06-20T08:35:00Z', paidAt: '2026-06-20T08:40:00Z' },
  { id: 'pay-ord-003', orderId: 'ord-003', userId: 'u-002', amount: 16500, status: 'Completed', method: 'ZaloPay', transactionId: 'ZLP20260622200500103', createdAt: '2026-06-22T20:02:00Z', paidAt: '2026-06-22T20:05:00Z' },
  { id: 'pay-ord-004', orderId: 'ord-004', userId: 'u-004', amount: 455200, status: 'Completed', method: 'VNPay', transactionId: 'VNP20260622034000104', createdAt: '2026-06-22T03:35:00Z', paidAt: '2026-06-22T03:40:00Z' },
  { id: 'pay-ord-006', orderId: 'ord-006', userId: 'u-006', amount: 52800, status: 'Completed', method: 'MoMo', transactionId: 'MOMO20260621095000106', createdAt: '2026-06-21T09:45:00Z', paidAt: '2026-06-21T09:50:00Z' },
  { id: 'pay-ord-007', orderId: 'ord-007', userId: 'u-007', amount: 66000, status: 'Completed', method: 'Ví LuxeLock', transactionId: 'WALLET20260622054000107', createdAt: '2026-06-22T05:35:00Z', paidAt: '2026-06-22T05:40:00Z' },
];

// ─── DELIVERY REQUESTS (matching DeliveryRequestDto) ──────
export interface SeedDeliveryRequest {
  id: string;
  userId: string;
  senderName: string;
  receiverPhone: string;
  lockerId: string;
  slotIndex: number;
  packageSize: string;
  trackingCode: string;
  status: DeliveryStatus;
  createdAt: string;
}

export const SEED_DELIVERY_REQUESTS: SeedDeliveryRequest[] = [
  { id: 'del-001', userId: 's-001', senderName: 'Shopee Express', receiverPhone: '0901234567', lockerId: 'lk-001', slotIndex: 5, packageSize: 'Medium', trackingCode: 'LXL-2026-A1B2C3', status: 'Pending', createdAt: '2026-06-22T08:00:00Z' },
  { id: 'del-002', userId: 's-001', senderName: 'Lazada Logistics', receiverPhone: '0912345678', lockerId: 'lk-002', slotIndex: 7, packageSize: 'Small', trackingCode: 'LXL-2026-D4E5F6', status: 'DeliveredToLocker', createdAt: '2026-06-22T09:30:00Z' },
  { id: 'del-003', userId: 's-002', senderName: 'Tiki Now', receiverPhone: '0923456789', lockerId: 'lk-005', slotIndex: 9, packageSize: 'Large', trackingCode: 'LXL-2026-G7H8I9', status: 'Pending', createdAt: '2026-06-22T10:00:00Z' },
  { id: 'del-004', userId: 's-001', senderName: 'GrabExpress', receiverPhone: '0934567890', lockerId: 'lk-003', slotIndex: 4, packageSize: 'Medium', trackingCode: 'LXL-2026-J0K1L2', status: 'Completed', createdAt: '2026-06-21T14:00:00Z' },
  { id: 'del-005', userId: 's-002', senderName: 'J&T Express', receiverPhone: '0945678901', lockerId: 'lk-004', slotIndex: 6, packageSize: 'Small', trackingCode: 'LXL-2026-M3N4O5', status: 'Pending', createdAt: '2026-06-22T11:30:00Z' },
  { id: 'del-006', userId: 's-003', senderName: 'Viettel Post', receiverPhone: '0956789012', lockerId: 'lk-008', slotIndex: 1, packageSize: 'Large', trackingCode: 'LXL-2026-P6Q7R8', status: 'DeliveredToLocker', createdAt: '2026-06-22T07:00:00Z' },
];

// ─── SEND-RECEIVE ORDERS (matching SendReceiveOrderDto) ───
export interface SeedSendReceiveOrder {
  id: string;
  senderId: string;
  receiverPhone: string;
  lockerId: string;
  slotIndex: number;
  status: SendReceiveStatus;
  pinCode: string;
  notes?: string;
  createdAt: string;
}

export const SEED_SEND_RECEIVE_ORDERS: SeedSendReceiveOrder[] = [
  { id: 'sr-001', senderId: 'u-001', receiverPhone: '0912345678', lockerId: 'lk-001', slotIndex: 5, status: 'Deposited', pinCode: '4567', notes: 'Sách giáo trình cho Trần Thị B', createdAt: '2026-06-22T10:00:00Z' },
  { id: 'sr-002', senderId: 'u-002', receiverPhone: '0901234567', lockerId: 'lk-002', slotIndex: 3, status: 'Initiated', pinCode: '8901', notes: 'Áo khoác để quên', createdAt: '2026-06-22T14:00:00Z' },
  { id: 'sr-003', senderId: 'u-006', receiverPhone: '0967890123', lockerId: 'lk-010', slotIndex: 7, status: 'Received', pinCode: '2345', createdAt: '2026-06-21T09:00:00Z' },
  { id: 'sr-004', senderId: 'u-004', receiverPhone: '0956789012', lockerId: 'lk-006', slotIndex: 10, status: 'Cancelled', pinCode: '6789', notes: 'Đã hủy — người nhận không lấy', createdAt: '2026-06-20T16:00:00Z' },
];

// ─── NOTIFICATIONS (matching NotificationDto) ─────────────
export interface SeedNotification {
  id: string;
  userId: string;
  title: string;
  message: string;
  isRead: boolean;
  createdAt: string;
}

export const SEED_NOTIFICATIONS: SeedNotification[] = [
  { id: 'noti-001', userId: 'u-001', title: 'Đơn hàng đã kích hoạt', message: 'Đơn hàng ORD-001 tại Tủ Khóa Vincom Đồng Khởi đã được kích hoạt thành công.', isRead: false, createdAt: '2026-06-22T08:00:00Z' },
  { id: 'noti-002', userId: 'u-001', title: 'Thanh toán thành công', message: 'Bạn đã thanh toán 52.800đ cho đơn hàng ORD-001 qua VNPay.', isRead: true, createdAt: '2026-06-22T07:50:00Z' },
  { id: 'noti-003', userId: 'u-001', title: 'Gửi hàng thành công', message: 'Bạn đã gửi hàng cho SĐT 0912345678 tại ô tủ số 6, Vincom Đồng Khởi.', isRead: false, createdAt: '2026-06-22T10:00:00Z' },
  { id: 'noti-004', userId: 'u-002', title: 'Có hàng chờ nhận', message: 'Bạn có kiện hàng chờ nhận tại Tủ Khóa Vincom Đồng Khởi. Mã PIN: 4567', isRead: false, createdAt: '2026-06-22T10:01:00Z' },
  { id: 'noti-005', userId: 'u-001', title: 'Đơn hàng hoàn thành', message: 'Đơn hàng ORD-002 đã hoàn thành. Tổng phí: 100.600đ.', isRead: true, createdAt: '2026-06-20T17:05:00Z' },
  { id: 'noti-006', userId: 's-001', title: 'Có đơn giao mới', message: 'Bạn có 2 đơn giao hàng mới cần xử lý hôm nay.', isRead: false, createdAt: '2026-06-22T07:30:00Z' },
  { id: 'noti-007', userId: 's-001', title: 'Giao hàng thành công', message: 'Đơn DEL-002 đã được giao vào tủ Landmark 81 thành công.', isRead: true, createdAt: '2026-06-22T09:45:00Z' },
  { id: 'noti-008', userId: 'u-004', title: 'Sắp hết thời gian thuê', message: 'Đơn ORD-004 tại Sân Bay TSN T2 sẽ hết hạn lúc 04:00 ngày mai. Hãy gia hạn nếu cần.', isRead: false, createdAt: '2026-06-22T22:00:00Z' },
];

// ─── HELPERS ──────────────────────────────────────────────
export const getUserById = (id: string) => SEED_USERS.find(u => u.id === id);

export type MockLoginError = 'NOT_FOUND' | 'WRONG_PASSWORD' | 'INACTIVE' | 'EMAIL_NOT_VERIFIED';
export function mockLogin(identifier: string, password: string): { user: SeedUser } | { error: MockLoginError } {
  const user = SEED_USERS.find(u => u.username === identifier || u.email === identifier);
  if (!user) return { error: 'NOT_FOUND' };
  if (user._mockPassword !== password) return { error: 'WRONG_PASSWORD' };
  if (!user.isActive) return { error: 'INACTIVE' };
  if (!user.isEmailVerified) return { error: 'EMAIL_NOT_VERIFIED' };
  return { user };
}

export const getLockerById = (id: string) => SEED_LOCKERS.find(l => l.id === id);
export const getPackageById = (id: string) => SEED_PACKAGES.find(p => p.id === id);
export const getBookingById = (id: string) => SEED_BOOKINGS.find(b => b.id === id);
export const getPaymentById = (id: string) => SEED_PAYMENTS.find(p => p.id === id);
export const getOrderById = (id: string) => SEED_ORDERS.find(o => o.id === id);

export const getBookingsByUser = (userId: string) => SEED_BOOKINGS.filter(b => b.userId === userId);
export const getOrdersByUser = (userId: string) => SEED_ORDERS.filter(o => o.userId === userId);
export const getPaymentsByUser = (userId: string) => SEED_PAYMENTS.filter(p => p.userId === userId);
export const getDeliveryRequestsByUser = (userId: string) => SEED_DELIVERY_REQUESTS.filter(d => d.userId === userId);
export const getSendReceiveByUser = (userId: string) => SEED_SEND_RECEIVE_ORDERS.filter(s => s.senderId === userId);
export const getNotificationsByUser = (userId: string) => SEED_NOTIFICATIONS.filter(n => n.userId === userId);
export const getAvailableLockers = () => SEED_LOCKERS.filter(l => l.slots.some(s => s.status === 'Available'));
export const getBookingsByStatus = (status: BookingStatus) => SEED_BOOKINGS.filter(b => b.status === status);
export const getUsersByRole = (role: UserRole) => SEED_USERS.filter(u => u.role === role);
export const getDeliveryByTrackingCode = (code: string) => SEED_DELIVERY_REQUESTS.find(d => d.trackingCode === code);

// Dashboard mock data
export function getMockUserDashboard(userId: string) {
  const user = getUserById(userId);
  const activeOrder = SEED_ORDERS.find(o => o.userId === userId && o.status === 'Active');
  const locker = activeOrder ? getLockerById(activeOrder.lockerId) : null;

  return {
    user: {
      fullName: `Xin chào, ${user?.fullName ?? 'Người Dùng'}!`,
      location: 'Hồ Chí Minh',
      avatarUrl: '',
    },
    activeOrder: activeOrder && locker ? {
      orderCode: `Tủ ${locker.slots[activeOrder.slotIndex]?.size ?? 'M'}-${String(activeOrder.slotIndex).padStart(3, '0')}`,
      lockerName: locker.name,
      address: locker.location,
      remainingTime: getRemainingTime(activeOrder.checkOutTime),
      status: 'Đang hoạt động',
    } : null,
    suggestedLockers: SEED_LOCKERS.filter(l => l.slots.some(s => s.status === 'Available')).slice(0, 3).map(l => ({
      id: l.id,
      name: l.name,
      distance: `${(Math.random() * 2 + 0.3).toFixed(1)}km`,
      availableSlots: l.slots.filter(s => s.status === 'Available').length,
    })),
    promotionalBanners: [] as { id: string; imageUrl: string; title: string; actionUrl: string }[],
  };
}

export function getMockShipperDashboard(userId: string) {
  const todayDeliveries = SEED_DELIVERY_REQUESTS.filter(d => d.userId === userId);
  const deliveredCount = todayDeliveries.filter(d => d.status === 'DeliveredToLocker' || d.status === 'Completed').length;
  const remainingCount = todayDeliveries.filter(d => d.status === 'Pending').length;

  return {
    performance: {
      deliveredCount,
      remainingCount,
      totalKm: Math.floor(Math.random() * 30 + 10),
      updatedAt: new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }),
    },
    availableLockers: SEED_LOCKERS.filter(l => l.slots.some(s => s.status === 'Available')).slice(0, 3).map(l => ({
      id: l.id,
      name: l.name,
      address: l.location,
      availableSlots: l.slots.filter(s => s.status === 'Available').length,
      travelTime: `${Math.floor(Math.random() * 15 + 5)} phút`,
      distance: `${(Math.random() * 5 + 1).toFixed(1)}km`,
      isNearest: Math.random() > 0.5,
    })),
    ordersToProcess: todayDeliveries.filter(d => d.status === 'Pending').map(d => {
      const locker = getLockerById(d.lockerId);
      return {
        orderId: d.id,
        type: 'GIAO NGAY',
        distance: `${(Math.random() * 5 + 1).toFixed(1)}km`,
        locationName: locker?.name ?? 'Unknown',
        slotInfo: `Tủ ${d.slotIndex}`,
        code: d.trackingCode,
      };
    }),
  };
}

function getRemainingTime(checkOutTime: string): string {
  const diff = new Date(checkOutTime).getTime() - Date.now();
  if (diff <= 0) return 'Hết hạn';
  const hours = Math.floor(diff / 3600000);
  const minutes = Math.floor((diff % 3600000) / 60000);
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
}
