// ─────────────────────────────────────────────
// Shared TypeScript types / interfaces
// These mirror the backend DTOs and domain entities.
// ─────────────────────────────────────────────

export type UserRole = 'User' | 'Admin' | 'Shipper';

export type BookingStatus = 'Pending' | 'Active' | 'Completed' | 'Canceled' | 'Expired';

export type LockerSlotStatus = 'Available' | 'Pending' | 'Active' | 'Complete' | 'Canceled' | 'Expired';

export type PaymentStatus = 'Pending' | 'Completed' | 'Failed' | 'Refunded';

export type PackageSize = 'S' | 'M' | 'L' | 'XL';

// ─── Auth ──────────────────────────────────────
export interface LoginRequest {
  identifier: string; // username or email
  password: string;
}

export interface RegisterRequest {
  username: string;
  email: string;
  fullName: string;
  phoneNumber: string;
  password: string;
}

// ─── User ──────────────────────────────────────
export interface UserDto {
  id: string;
  username: string;
  email: string;
  fullName?: string;
  phoneNumber?: string;
  role: UserRole;
  isActive: boolean;
  isEmailVerified: boolean;
  createdAt: string;
}

// ─── Locker ────────────────────────────────────
export interface LockerSlotDto {
  index: number;
  status: LockerSlotStatus;
  bookingId?: string;
}

export interface LockerDto {
  id: string;
  name: string;
  location: string;
  slots: LockerSlotDto[];
}

// ─── Package ───────────────────────────────────
export interface PackageDto {
  id: string;
  name: string;
  size: PackageSize;
  description: string;
  pricePerHour: number;
  isActive: boolean;
}

// ─── Booking ───────────────────────────────────
export interface BookingDto {
  id: string;
  userId: string;
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

export interface CreateBookingRequest {
  lockerId: string;
  slotIndex: number;
  packageId: string;
  mobileNumber: string;
}

// ─── Payment ───────────────────────────────────
export interface PaymentDto {
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
