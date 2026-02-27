// ============================================================
// SEED DATA — Frontend mock data for UI testing
// Không chỉnh sửa backend, chỉ dùng cho frontend development
// ============================================================

export type UserRole = 'User' | 'Admin' | 'Shipper';
export type BookingStatus = 'Pending' | 'Active' | 'Completed' | 'Canceled' | 'Expired';
export type SlotStatus = 'Available' | 'Pending' | 'Active' | 'Complete' | 'Canceled' | 'Expired';
export type PaymentStatus = 'Pending' | 'Completed' | 'Failed' | 'Refunded';
export type PackageSize = 'S' | 'M' | 'L' | 'XL';

// ─────────────────────────────────────────────
// USERS
// ─────────────────────────────────────────────
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
  /** Mock password — chỉ dùng cho frontend test, không gửi lên backend */
  _mockPassword: string;
}

export const SEED_USERS: SeedUser[] = [
  // --- Regular Users (10) ---
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
  // --- Admins (5) ---
  { id: 'a-001', username: 'admin_hoai', email: 'admin.hoai@luxelock.vn', fullName: 'Hoài Admin', phoneNumber: '0901111111', role: 'Admin', isActive: true, isEmailVerified: true, createdAt: '2025-09-01T07:00:00Z', _mockPassword: 'Admin@123' },
  { id: 'a-002', username: 'admin_minh', email: 'admin.minh@luxelock.vn', fullName: 'Minh Admin', phoneNumber: '0902222222', role: 'Admin', isActive: true, isEmailVerified: true, createdAt: '2025-09-01T07:30:00Z', _mockPassword: 'Admin@123' },
  { id: 'a-003', username: 'admin_linh', email: 'admin.linh@luxelock.vn', fullName: 'Linh Admin', phoneNumber: '0903333333', role: 'Admin', isActive: true, isEmailVerified: true, createdAt: '2025-09-02T08:00:00Z', _mockPassword: 'Admin@123' },
  { id: 'a-004', username: 'admin_tuan', email: 'admin.tuan@luxelock.vn', fullName: 'Tuấn Admin', phoneNumber: '0904444444', role: 'Admin', isActive: false, isEmailVerified: true, createdAt: '2025-09-05T09:00:00Z', _mockPassword: 'Admin@123' },
  { id: 'a-005', username: 'admin_phuong', email: 'admin.phuong@luxelock.vn', fullName: 'Phương Admin', phoneNumber: '0905555555', role: 'Admin', isActive: true, isEmailVerified: true, createdAt: '2025-09-10T10:00:00Z', _mockPassword: 'Admin@123' },
  // --- Shippers (5) ---
  { id: 's-001', username: 'shipper_nam', email: 'shipper.nam@luxelock.vn', fullName: 'Nguyễn Nam', phoneNumber: '0911111111', role: 'Shipper', isActive: true, isEmailVerified: true, createdAt: '2025-09-15T08:00:00Z', _mockPassword: 'Shipper@123' },
  { id: 's-002', username: 'shipper_hung', email: 'shipper.hung@luxelock.vn', fullName: 'Trần Hùng', phoneNumber: '0912222222', role: 'Shipper', isActive: true, isEmailVerified: true, createdAt: '2025-09-16T08:30:00Z', _mockPassword: 'Shipper@123' },
  { id: 's-003', username: 'shipper_lan', email: 'shipper.lan@luxelock.vn', fullName: 'Lê Lan', phoneNumber: '0913333333', role: 'Shipper', isActive: true, isEmailVerified: true, createdAt: '2025-09-17T09:00:00Z', _mockPassword: 'Shipper@123' },
  { id: 's-004', username: 'shipper_phuc', email: 'shipper.phuc@luxelock.vn', fullName: 'Phạm Phúc', phoneNumber: '0914444444', role: 'Shipper', isActive: false, isEmailVerified: true, createdAt: '2025-09-18T09:30:00Z', _mockPassword: 'Shipper@123' },
  { id: 's-005', username: 'shipper_mai', email: 'shipper.mai@luxelock.vn', fullName: 'Hoàng Mai', phoneNumber: '0915555555', role: 'Shipper', isActive: true, isEmailVerified: true, createdAt: '2025-09-20T10:00:00Z', _mockPassword: 'Shipper@123' },
];

// ─────────────────────────────────────────────
// PACKAGES
// ─────────────────────────────────────────────
export interface SeedPackage {
  id: string;
  name: string;
  size: PackageSize;
  description: string;
  pricePerHour: number;
  isActive: boolean;
}

export const SEED_PACKAGES: SeedPackage[] = [
  {
    id: 'pkg-001',
    name: 'Gói Nhỏ S',
    size: 'S',
    description: 'Phù hợp cho túi xách, laptop, đồ vật nhỏ. Kích thước 30×30×40 cm.',
    pricePerHour: 5000,
    isActive: true,
  },
  {
    id: 'pkg-002',
    name: 'Gói Vừa M',
    size: 'M',
    description: 'Lý tưởng cho ba lô, vali du lịch nhỏ. Kích thước 40×40×60 cm.',
    pricePerHour: 8000,
    isActive: true,
  },
  {
    id: 'pkg-003',
    name: 'Gói Lớn L',
    size: 'L',
    description: 'Dành cho vali cỡ trung, thiết bị thể thao. Kích thước 50×50×80 cm.',
    pricePerHour: 12000,
    isActive: true,
  },
  {
    id: 'pkg-004',
    name: 'Gói XL',
    size: 'XL',
    description: 'Dành cho hàng cồng kềnh, vali lớn, xe đẩy. Kích thước 60×60×100 cm.',
    pricePerHour: 18000,
    isActive: true,
  },
  {
    id: 'pkg-005',
    name: 'Gói Nhỏ S (Cũ)',
    size: 'S',
    description: 'Phiên bản cũ đã ngừng kinh doanh.',
    pricePerHour: 4000,
    isActive: false,
  },
  {
    id: 'pkg-006',
    name: 'Gói Vừa M (Cao cấp)',
    size: 'M',
    description: 'Gói M với ổ cắm sạc điện thoại bên trong. Kích thước 40×40×60 cm.',
    pricePerHour: 10000,
    isActive: true,
  },
];

// ─────────────────────────────────────────────
// LOCKERS
// ─────────────────────────────────────────────
export interface LockerSlot {
  index: number;
  status: SlotStatus;
  bookingId?: string;
}

export interface SeedLocker {
  id: string;
  name: string;
  location: string;
  slots: LockerSlot[];
}

function makeSlots(count: number, overrides: Partial<Record<number, SlotStatus>> = {}): LockerSlot[] {
  return Array.from({ length: count }, (_, i) => ({
    index: i,
    status: overrides[i] ?? 'Available',
    bookingId: overrides[i] && overrides[i] !== 'Available' ? `bk-00${i + 1}` : undefined,
  }));
}

export const SEED_LOCKERS: SeedLocker[] = [
  {
    id: 'lk-001',
    name: 'Tủ Khóa Vincom Đồng Khởi',
    location: '72 Lê Thánh Tôn, Quận 1, TP.HCM',
    slots: makeSlots(12, { 2: 'Active', 5: 'Pending', 9: 'Active' }),
  },
  {
    id: 'lk-002',
    name: 'Tủ Khóa Landmark 81',
    location: '772A Điện Biên Phủ, Bình Thạnh, TP.HCM',
    slots: makeSlots(16, { 0: 'Active', 3: 'Active', 7: 'Pending', 11: 'Complete', 14: 'Active' }),
  },
  {
    id: 'lk-003',
    name: 'Tủ Khóa Aeon Mall Tân Phú',
    location: '30 Bờ Bao Tân Thắng, Tân Phú, TP.HCM',
    slots: makeSlots(8, { 1: 'Pending', 4: 'Active' }),
  },
  {
    id: 'lk-004',
    name: 'Tủ Khóa Ga Sài Gòn',
    location: '1 Nguyễn Thông, Quận 3, TP.HCM',
    slots: makeSlots(10, { 0: 'Active', 2: 'Active', 6: 'Active', 8: 'Pending' }),
  },
  {
    id: 'lk-005',
    name: 'Tủ Khóa Sân Bay Tân Sơn Nhất T1',
    location: 'Nhà ga T1, Trường Chinh, Tân Bình, TP.HCM',
    slots: makeSlots(20, { 1: 'Active', 3: 'Active', 5: 'Active', 9: 'Pending', 12: 'Active', 17: 'Complete' }),
  },
  {
    id: 'lk-006',
    name: 'Tủ Khóa Sân Bay Tân Sơn Nhất T2',
    location: 'Nhà ga T2, Trường Chinh, Tân Bình, TP.HCM',
    slots: makeSlots(20, { 0: 'Active', 4: 'Active', 10: 'Pending', 16: 'Active' }),
  },
  {
    id: 'lk-007',
    name: 'Tủ Khóa Bến xe Miền Đông',
    location: '292 Đinh Bộ Lĩnh, Bình Thạnh, TP.HCM',
    slots: makeSlots(8, { 2: 'Active', 6: 'Pending' }),
  },
  {
    id: 'lk-008',
    name: 'Tủ Khóa Parkson Hùng Vương',
    location: '126 Hùng Vương, Quận 5, TP.HCM',
    slots: makeSlots(12, { 1: 'Active', 5: 'Active', 10: 'Active' }),
  },
  {
    id: 'lk-009',
    name: 'Tủ Khóa RMIT Sài Gòn',
    location: '702 Nguyễn Văn Linh, Quận 7, TP.HCM',
    slots: makeSlots(6, { 0: 'Active', 3: 'Pending' }),
  },
  {
    id: 'lk-010',
    name: 'Tủ Khóa Vivo City',
    location: '1058A Nguyễn Văn Linh, Quận 7, TP.HCM',
    slots: makeSlots(10, { 4: 'Active', 7: 'Active' }),
  },
  {
    id: 'lk-011',
    name: 'Tủ Khóa Lotte Mart Quận 7',
    location: '469 Nguyễn Hữu Thọ, Quận 7, TP.HCM',
    slots: makeSlots(8, { 2: 'Pending', 5: 'Active', 7: 'Complete' }),
  },
  {
    id: 'lk-012',
    name: 'Tủ Khóa Big C An Lạc',
    location: 'QL1A, Bình Tân, TP.HCM',
    slots: makeSlots(12, { 0: 'Active', 6: 'Pending' }),
  },
  {
    id: 'lk-013',
    name: 'Tủ Khóa Nowzone Fashion Mall',
    location: '235 Nguyễn Văn Cừ, Quận 1, TP.HCM',
    slots: makeSlots(6),
  },
  {
    id: 'lk-014',
    name: 'Tủ Khóa Crescent Mall',
    location: '101 Tôn Dật Tiên, Quận 7, TP.HCM',
    slots: makeSlots(10, { 1: 'Active', 3: 'Active', 8: 'Active' }),
  },
  {
    id: 'lk-015',
    name: 'Tủ Khóa SC VivoCity',
    location: '1058A Nguyễn Văn Linh, Quận 7, TP.HCM',
    slots: makeSlots(8, { 4: 'Pending' }),
  },
  {
    id: 'lk-016',
    name: 'Tủ Khóa Đại học Bách Khoa HCM',
    location: '268 Lý Thường Kiệt, Quận 10, TP.HCM',
    slots: makeSlots(6, { 0: 'Active', 5: 'Active' }),
  },
  {
    id: 'lk-017',
    name: 'Tủ Khóa Đại học Kinh Tế HCM',
    location: '59C Nguyễn Đình Chiểu, Quận 3, TP.HCM',
    slots: makeSlots(6, { 1: 'Pending', 3: 'Active' }),
  },
  {
    id: 'lk-018',
    name: 'Tủ Khóa Siêu thị Co.opmart Nguyễn Đình Chiểu',
    location: '168 Nguyễn Đình Chiểu, Quận 3, TP.HCM',
    slots: makeSlots(8, { 2: 'Active', 6: 'Active' }),
  },
  {
    id: 'lk-019',
    name: 'Tủ Khóa Bưu điện Trung tâm Sài Gòn',
    location: '2 Công xã Paris, Quận 1, TP.HCM',
    slots: makeSlots(10, { 0: 'Active', 4: 'Active', 7: 'Pending', 9: 'Active' }),
  },
  {
    id: 'lk-020',
    name: 'Tủ Khóa Times City Hà Nội',
    location: '458 Minh Khai, Hai Bà Trưng, Hà Nội',
    slots: makeSlots(12, { 1: 'Active', 5: 'Pending', 8: 'Active' }),
  },
];

// ─────────────────────────────────────────────
// BOOKINGS
// ─────────────────────────────────────────────
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
  {
    id: 'bk-001',
    userId: 'u-001',
    userName: 'Nguyễn Văn A',
    lockerId: 'lk-001',
    lockerName: 'Tủ Khóa Vincom Đồng Khởi',
    lockerLocation: '72 Lê Thánh Tôn, Quận 1, TP.HCM',
    slotIndex: 2,
    packageId: 'pkg-002',
    packageName: 'Gói Vừa M',
    packageSize: 'M',
    mobileNumber: '0901234567',
    status: 'Active',
    totalAmount: 24000,
    paymentId: 'pay-001',
    createdAt: '2026-02-20T08:00:00Z',
    startedAt: '2026-02-20T08:15:00Z',
  },
  {
    id: 'bk-002',
    userId: 'u-002',
    userName: 'Trần Thị B',
    lockerId: 'lk-005',
    lockerName: 'Tủ Khóa Sân Bay Tân Sơn Nhất T1',
    lockerLocation: 'Nhà ga T1, Trường Chinh, Tân Bình, TP.HCM',
    slotIndex: 1,
    packageId: 'pkg-003',
    packageName: 'Gói Lớn L',
    packageSize: 'L',
    mobileNumber: '0912345678',
    status: 'Completed',
    totalAmount: 84000,
    paymentId: 'pay-002',
    createdAt: '2026-02-15T06:00:00Z',
    startedAt: '2026-02-15T06:30:00Z',
    completedAt: '2026-02-15T13:30:00Z',
  },
  {
    id: 'bk-003',
    userId: 'u-003',
    userName: 'Lê Văn C',
    lockerId: 'lk-002',
    lockerName: 'Tủ Khóa Landmark 81',
    lockerLocation: '772A Điện Biên Phủ, Bình Thạnh, TP.HCM',
    slotIndex: 7,
    packageId: 'pkg-001',
    packageName: 'Gói Nhỏ S',
    packageSize: 'S',
    mobileNumber: '0923456789',
    status: 'Pending',
    totalAmount: 0,
    createdAt: '2026-02-27T07:00:00Z',
  },
  {
    id: 'bk-004',
    userId: 'u-001',
    userName: 'Nguyễn Văn A',
    lockerId: 'lk-004',
    lockerName: 'Tủ Khóa Ga Sài Gòn',
    lockerLocation: '1 Nguyễn Thông, Quận 3, TP.HCM',
    slotIndex: 0,
    packageId: 'pkg-002',
    packageName: 'Gói Vừa M',
    packageSize: 'M',
    mobileNumber: '0901234567',
    status: 'Canceled',
    totalAmount: 0,
    createdAt: '2026-02-10T11:00:00Z',
  },
  {
    id: 'bk-005',
    userId: 'u-004',
    userName: 'Phạm Thị D',
    lockerId: 'lk-006',
    lockerName: 'Tủ Khóa Sân Bay Tân Sơn Nhất T2',
    lockerLocation: 'Nhà ga T2, Trường Chinh, Tân Bình, TP.HCM',
    slotIndex: 4,
    packageId: 'pkg-004',
    packageName: 'Gói XL',
    packageSize: 'XL',
    mobileNumber: '0934567890',
    status: 'Active',
    totalAmount: 180000,
    paymentId: 'pay-005',
    createdAt: '2026-02-26T04:00:00Z',
    startedAt: '2026-02-26T04:30:00Z',
  },
  {
    id: 'bk-006',
    userId: 'u-005',
    userName: 'Hoàng Văn E',
    lockerId: 'lk-003',
    lockerName: 'Tủ Khóa Aeon Mall Tân Phú',
    lockerLocation: '30 Bờ Bao Tân Thắng, Tân Phú, TP.HCM',
    slotIndex: 1,
    packageId: 'pkg-001',
    packageName: 'Gói Nhỏ S',
    packageSize: 'S',
    mobileNumber: '0945678901',
    status: 'Expired',
    totalAmount: 15000,
    paymentId: 'pay-006',
    createdAt: '2026-01-10T09:00:00Z',
    startedAt: '2026-01-10T09:15:00Z',
  },
  {
    id: 'bk-007',
    userId: 'u-006',
    userName: 'Võ Thị F',
    lockerId: 'lk-010',
    lockerName: 'Tủ Khóa Vivo City',
    lockerLocation: '1058A Nguyễn Văn Linh, Quận 7, TP.HCM',
    slotIndex: 4,
    packageId: 'pkg-002',
    packageName: 'Gói Vừa M',
    packageSize: 'M',
    mobileNumber: '0956789012',
    status: 'Completed',
    totalAmount: 48000,
    paymentId: 'pay-007',
    createdAt: '2026-02-18T10:00:00Z',
    startedAt: '2026-02-18T10:30:00Z',
    completedAt: '2026-02-18T16:30:00Z',
  },
  {
    id: 'bk-008',
    userId: 'u-007',
    userName: 'Đặng Văn G',
    lockerId: 'lk-009',
    lockerName: 'Tủ Khóa RMIT Sài Gòn',
    lockerLocation: '702 Nguyễn Văn Linh, Quận 7, TP.HCM',
    slotIndex: 0,
    packageId: 'pkg-001',
    packageName: 'Gói Nhỏ S',
    packageSize: 'S',
    mobileNumber: '0967890123',
    status: 'Active',
    totalAmount: 10000,
    paymentId: 'pay-008',
    createdAt: '2026-02-27T06:00:00Z',
    startedAt: '2026-02-27T06:30:00Z',
  },
  {
    id: 'bk-009',
    userId: 'u-008',
    userName: 'Bùi Thị H',
    lockerId: 'lk-014',
    lockerName: 'Tủ Khóa Crescent Mall',
    lockerLocation: '101 Tôn Dật Tiên, Quận 7, TP.HCM',
    slotIndex: 1,
    packageId: 'pkg-003',
    packageName: 'Gói Lớn L',
    packageSize: 'L',
    mobileNumber: '0978901234',
    status: 'Pending',
    totalAmount: 0,
    createdAt: '2026-02-27T05:00:00Z',
  },
  {
    id: 'bk-010',
    userId: 'u-009',
    userName: 'Đỗ Văn I',
    lockerId: 'lk-020',
    lockerName: 'Tủ Khóa Times City Hà Nội',
    lockerLocation: '458 Minh Khai, Hai Bà Trưng, Hà Nội',
    slotIndex: 1,
    packageId: 'pkg-002',
    packageName: 'Gói Vừa M',
    packageSize: 'M',
    mobileNumber: '0989012345',
    status: 'Completed',
    totalAmount: 32000,
    paymentId: 'pay-010',
    createdAt: '2026-02-22T08:00:00Z',
    startedAt: '2026-02-22T08:30:00Z',
    completedAt: '2026-02-22T12:30:00Z',
  },
  {
    id: 'bk-011',
    userId: 'u-010',
    userName: 'Ngô Thị K',
    lockerId: 'lk-008',
    lockerName: 'Tủ Khóa Parkson Hùng Vương',
    lockerLocation: '126 Hùng Vương, Quận 5, TP.HCM',
    slotIndex: 5,
    packageId: 'pkg-001',
    packageName: 'Gói Nhỏ S',
    packageSize: 'S',
    mobileNumber: '0990123456',
    status: 'Active',
    totalAmount: 20000,
    paymentId: 'pay-011',
    createdAt: '2026-02-27T07:30:00Z',
    startedAt: '2026-02-27T07:45:00Z',
  },
  {
    id: 'bk-012',
    userId: 'u-002',
    userName: 'Trần Thị B',
    lockerId: 'lk-001',
    lockerName: 'Tủ Khóa Vincom Đồng Khởi',
    lockerLocation: '72 Lê Thánh Tôn, Quận 1, TP.HCM',
    slotIndex: 9,
    packageId: 'pkg-006',
    packageName: 'Gói Vừa M (Cao cấp)',
    packageSize: 'M',
    mobileNumber: '0912345678',
    status: 'Active',
    totalAmount: 40000,
    paymentId: 'pay-012',
    createdAt: '2026-02-27T09:00:00Z',
    startedAt: '2026-02-27T09:10:00Z',
  },
  {
    id: 'bk-013',
    userId: 'u-003',
    userName: 'Lê Văn C',
    lockerId: 'lk-011',
    lockerName: 'Tủ Khóa Lotte Mart Quận 7',
    lockerLocation: '469 Nguyễn Hữu Thọ, Quận 7, TP.HCM',
    slotIndex: 2,
    packageId: 'pkg-003',
    packageName: 'Gói Lớn L',
    packageSize: 'L',
    mobileNumber: '0923456789',
    status: 'Canceled',
    totalAmount: 0,
    createdAt: '2026-02-21T11:00:00Z',
  },
  {
    id: 'bk-014',
    userId: 'u-004',
    userName: 'Phạm Thị D',
    lockerId: 'lk-007',
    lockerName: 'Tủ Khóa Bến xe Miền Đông',
    lockerLocation: '292 Đinh Bộ Lĩnh, Bình Thạnh, TP.HCM',
    slotIndex: 2,
    packageId: 'pkg-002',
    packageName: 'Gói Vừa M',
    packageSize: 'M',
    mobileNumber: '0934567890',
    status: 'Completed',
    totalAmount: 56000,
    paymentId: 'pay-014',
    createdAt: '2026-02-14T05:30:00Z',
    startedAt: '2026-02-14T06:00:00Z',
    completedAt: '2026-02-14T13:00:00Z',
  },
  {
    id: 'bk-015',
    userId: 'u-006',
    userName: 'Võ Thị F',
    lockerId: 'lk-016',
    lockerName: 'Tủ Khóa Đại học Bách Khoa HCM',
    lockerLocation: '268 Lý Thường Kiệt, Quận 10, TP.HCM',
    slotIndex: 0,
    packageId: 'pkg-001',
    packageName: 'Gói Nhỏ S',
    packageSize: 'S',
    mobileNumber: '0956789012',
    status: 'Active',
    totalAmount: 5000,
    paymentId: 'pay-015',
    createdAt: '2026-02-27T08:00:00Z',
    startedAt: '2026-02-27T08:05:00Z',
  },
  {
    id: 'bk-016',
    userId: 'u-007',
    userName: 'Đặng Văn G',
    lockerId: 'lk-019',
    lockerName: 'Tủ Khóa Bưu điện Trung tâm Sài Gòn',
    lockerLocation: '2 Công xã Paris, Quận 1, TP.HCM',
    slotIndex: 7,
    packageId: 'pkg-004',
    packageName: 'Gói XL',
    packageSize: 'XL',
    mobileNumber: '0967890123',
    status: 'Expired',
    totalAmount: 36000,
    paymentId: 'pay-016',
    createdAt: '2026-01-20T10:00:00Z',
    startedAt: '2026-01-20T10:30:00Z',
  },
  {
    id: 'bk-017',
    userId: 'u-008',
    userName: 'Bùi Thị H',
    lockerId: 'lk-018',
    lockerName: 'Tủ Khóa Siêu thị Co.opmart Nguyễn Đình Chiểu',
    lockerLocation: '168 Nguyễn Đình Chiểu, Quận 3, TP.HCM',
    slotIndex: 2,
    packageId: 'pkg-002',
    packageName: 'Gói Vừa M',
    packageSize: 'M',
    mobileNumber: '0978901234',
    status: 'Completed',
    totalAmount: 16000,
    paymentId: 'pay-017',
    createdAt: '2026-02-25T14:00:00Z',
    startedAt: '2026-02-25T14:15:00Z',
    completedAt: '2026-02-25T16:15:00Z',
  },
  {
    id: 'bk-018',
    userId: 'u-009',
    userName: 'Đỗ Văn I',
    lockerId: 'lk-013',
    lockerName: 'Tủ Khóa Nowzone Fashion Mall',
    lockerLocation: '235 Nguyễn Văn Cừ, Quận 1, TP.HCM',
    slotIndex: 3,
    packageId: 'pkg-001',
    packageName: 'Gói Nhỏ S',
    packageSize: 'S',
    mobileNumber: '0989012345',
    status: 'Pending',
    totalAmount: 0,
    createdAt: '2026-02-27T10:00:00Z',
  },
  {
    id: 'bk-019',
    userId: 'u-010',
    userName: 'Ngô Thị K',
    lockerId: 'lk-015',
    lockerName: 'Tủ Khóa SC VivoCity',
    lockerLocation: '1058A Nguyễn Văn Linh, Quận 7, TP.HCM',
    slotIndex: 4,
    packageId: 'pkg-003',
    packageName: 'Gói Lớn L',
    packageSize: 'L',
    mobileNumber: '0990123456',
    status: 'Canceled',
    totalAmount: 0,
    createdAt: '2026-02-23T09:00:00Z',
  },
  {
    id: 'bk-020',
    userId: 'u-001',
    userName: 'Nguyễn Văn A',
    lockerId: 'lk-012',
    lockerName: 'Tủ Khóa Big C An Lạc',
    lockerLocation: 'QL1A, Bình Tân, TP.HCM',
    slotIndex: 6,
    packageId: 'pkg-004',
    packageName: 'Gói XL',
    packageSize: 'XL',
    mobileNumber: '0901234567',
    status: 'Completed',
    totalAmount: 72000,
    paymentId: 'pay-020',
    createdAt: '2026-02-19T07:00:00Z',
    startedAt: '2026-02-19T07:30:00Z',
    completedAt: '2026-02-19T11:30:00Z',
  },
];

// ─────────────────────────────────────────────
// PAYMENTS
// ─────────────────────────────────────────────
export interface SeedPayment {
  id: string;
  bookingId: string;
  userId: string;
  amount: number;
  status: PaymentStatus;
  method: string;
  transactionId?: string;
  createdAt: string;
  paidAt?: string;
}

export const SEED_PAYMENTS: SeedPayment[] = [
  {
    id: 'pay-001',
    bookingId: 'bk-001',
    userId: 'u-001',
    amount: 24000,
    status: 'Completed',
    method: 'VNPay',
    transactionId: 'VNP20260220081500001',
    createdAt: '2026-02-20T08:00:00Z',
    paidAt: '2026-02-20T08:15:00Z',
  },
  {
    id: 'pay-002',
    bookingId: 'bk-002',
    userId: 'u-002',
    amount: 84000,
    status: 'Completed',
    method: 'MoMo',
    transactionId: 'MOMO20260215063000002',
    createdAt: '2026-02-15T06:00:00Z',
    paidAt: '2026-02-15T06:30:00Z',
  },
  {
    id: 'pay-003',
    bookingId: 'bk-003',
    userId: 'u-003',
    amount: 0,
    status: 'Pending',
    method: 'VNPay',
    createdAt: '2026-02-27T07:00:00Z',
  },
  {
    id: 'pay-004',
    bookingId: 'bk-004',
    userId: 'u-001',
    amount: 0,
    status: 'Refunded',
    method: 'VNPay',
    transactionId: 'VNP20260210110000004',
    createdAt: '2026-02-10T11:00:00Z',
    paidAt: '2026-02-10T11:05:00Z',
  },
  {
    id: 'pay-005',
    bookingId: 'bk-005',
    userId: 'u-004',
    amount: 180000,
    status: 'Completed',
    method: 'ZaloPay',
    transactionId: 'ZLP20260226043000005',
    createdAt: '2026-02-26T04:00:00Z',
    paidAt: '2026-02-26T04:30:00Z',
  },
  {
    id: 'pay-006',
    bookingId: 'bk-006',
    userId: 'u-005',
    amount: 15000,
    status: 'Completed',
    method: 'MoMo',
    transactionId: 'MOMO20260110091500006',
    createdAt: '2026-01-10T09:00:00Z',
    paidAt: '2026-01-10T09:15:00Z',
  },
  {
    id: 'pay-007',
    bookingId: 'bk-007',
    userId: 'u-006',
    amount: 48000,
    status: 'Completed',
    method: 'VNPay',
    transactionId: 'VNP20260218103000007',
    createdAt: '2026-02-18T10:00:00Z',
    paidAt: '2026-02-18T10:30:00Z',
  },
  {
    id: 'pay-008',
    bookingId: 'bk-008',
    userId: 'u-007',
    amount: 10000,
    status: 'Completed',
    method: 'Cash',
    transactionId: 'CASH20260227063000008',
    createdAt: '2026-02-27T06:00:00Z',
    paidAt: '2026-02-27T06:30:00Z',
  },
  {
    id: 'pay-009',
    bookingId: 'bk-009',
    userId: 'u-008',
    amount: 0,
    status: 'Pending',
    method: 'ZaloPay',
    createdAt: '2026-02-27T05:00:00Z',
  },
  {
    id: 'pay-010',
    bookingId: 'bk-010',
    userId: 'u-009',
    amount: 32000,
    status: 'Completed',
    method: 'VNPay',
    transactionId: 'VNP20260222083000010',
    createdAt: '2026-02-22T08:00:00Z',
    paidAt: '2026-02-22T08:30:00Z',
  },
  {
    id: 'pay-011',
    bookingId: 'bk-011',
    userId: 'u-010',
    amount: 20000,
    status: 'Completed',
    method: 'MoMo',
    transactionId: 'MOMO20260227074500011',
    createdAt: '2026-02-27T07:30:00Z',
    paidAt: '2026-02-27T07:45:00Z',
  },
  {
    id: 'pay-012',
    bookingId: 'bk-012',
    userId: 'u-002',
    amount: 40000,
    status: 'Completed',
    method: 'VNPay',
    transactionId: 'VNP20260227091000012',
    createdAt: '2026-02-27T09:00:00Z',
    paidAt: '2026-02-27T09:10:00Z',
  },
  {
    id: 'pay-013',
    bookingId: 'bk-013',
    userId: 'u-003',
    amount: 0,
    status: 'Refunded',
    method: 'ZaloPay',
    transactionId: 'ZLP20260221110000013',
    createdAt: '2026-02-21T11:00:00Z',
    paidAt: '2026-02-21T11:10:00Z',
  },
  {
    id: 'pay-014',
    bookingId: 'bk-014',
    userId: 'u-004',
    amount: 56000,
    status: 'Completed',
    method: 'MoMo',
    transactionId: 'MOMO20260214060000014',
    createdAt: '2026-02-14T05:30:00Z',
    paidAt: '2026-02-14T06:00:00Z',
  },
  {
    id: 'pay-015',
    bookingId: 'bk-015',
    userId: 'u-006',
    amount: 5000,
    status: 'Completed',
    method: 'VNPay',
    transactionId: 'VNP20260227080500015',
    createdAt: '2026-02-27T08:00:00Z',
    paidAt: '2026-02-27T08:05:00Z',
  },
  {
    id: 'pay-016',
    bookingId: 'bk-016',
    userId: 'u-007',
    amount: 36000,
    status: 'Failed',
    method: 'ZaloPay',
    transactionId: 'ZLP20260120103000016',
    createdAt: '2026-01-20T10:00:00Z',
  },
  {
    id: 'pay-017',
    bookingId: 'bk-017',
    userId: 'u-008',
    amount: 16000,
    status: 'Completed',
    method: 'Cash',
    transactionId: 'CASH20260225141500017',
    createdAt: '2026-02-25T14:00:00Z',
    paidAt: '2026-02-25T14:15:00Z',
  },
  {
    id: 'pay-018',
    bookingId: 'bk-018',
    userId: 'u-009',
    amount: 0,
    status: 'Pending',
    method: 'MoMo',
    createdAt: '2026-02-27T10:00:00Z',
  },
  {
    id: 'pay-019',
    bookingId: 'bk-019',
    userId: 'u-010',
    amount: 0,
    status: 'Refunded',
    method: 'VNPay',
    transactionId: 'VNP20260223090000019',
    createdAt: '2026-02-23T09:00:00Z',
    paidAt: '2026-02-23T09:05:00Z',
  },
  {
    id: 'pay-020',
    bookingId: 'bk-020',
    userId: 'u-001',
    amount: 72000,
    status: 'Completed',
    method: 'ZaloPay',
    transactionId: 'ZLP20260219073000020',
    createdAt: '2026-02-19T07:00:00Z',
    paidAt: '2026-02-19T07:30:00Z',
  },
];

// ─────────────────────────────────────────────
// HELPERS — Lookup by ID
// ─────────────────────────────────────────────
export const getUserById = (id: string) => SEED_USERS.find(u => u.id === id);

/**
 * Mock login — trả về user nếu đúng username/email + password, null nếu sai.
 * Các lỗi có thể trả về:
 *   'NOT_FOUND'        — không tìm thấy tên đăng nhập / email
 *   'WRONG_PASSWORD'   — sai mật khẩu
 *   'INACTIVE'         — tài khoản bị khoá
 *   'EMAIL_NOT_VERIFIED' — chưa xác minh email
 */
export type MockLoginError = 'NOT_FOUND' | 'WRONG_PASSWORD' | 'INACTIVE' | 'EMAIL_NOT_VERIFIED';
export function mockLogin(
  identifier: string,
  password: string
): { user: SeedUser } | { error: MockLoginError } {
  const user = SEED_USERS.find(
    (u) => u.username === identifier || u.email === identifier
  );
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

export const getBookingsByUser = (userId: string) => SEED_BOOKINGS.filter(b => b.userId === userId);
export const getBookingsByStatus = (status: BookingStatus) => SEED_BOOKINGS.filter(b => b.status === status);
export const getUsersByRole = (role: UserRole) => SEED_USERS.filter(u => u.role === role);
export const getAvailableLockers = () =>
  SEED_LOCKERS.filter(l => l.slots.some(s => s.status === 'Available'));
