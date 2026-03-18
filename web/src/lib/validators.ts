/**
 * Validation utilities for customer form
 */

export const validatePhoneNumber = (phone: string): { valid: boolean; error?: string } => {
  // Vietnamese phone number format
  const pattern = /^0\d{9}$/;
  
  if (!phone) return { valid: false, error: 'Số điện thoại không được để trống' };
  if (!pattern.test(phone.replace(/\s/g, ''))) {
    return { valid: false, error: 'Số điện thoại không hợp lệ (ví dụ: 0912345678)' };
  }
  
  return { valid: true };
};

export const validateEmail = (email: string): { valid: boolean; error?: string } => {
  const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  if (!email) return { valid: false, error: 'Email không được để trống' };
  if (!pattern.test(email)) {
    return { valid: false, error: 'Email không hợp lệ' };
  }
  
  return { valid: true };
};

export const validateProductNote = (note: string): { valid: boolean; error?: string } => {
  if (note.length > 500) {
    return { valid: false, error: 'Ghi chú không được vượt quá 500 ký tự' };
  }
  
  return { valid: true };
};

/**
 * Package duration grouping utilities
 */
export interface PackageDuration {
  category: 'Hourly' | 'Daily' | 'Weekly' | 'Monthly';
  label: string;
  durationHours: number;
}

export const PACKAGE_DURATION_MAP: Record<string, PackageDuration> = {
  'Hourly': { category: 'Hourly', label: 'Hàng giờ', durationHours: 1 },
  'Daily': { category: 'Daily', label: 'Hàng ngày', durationHours: 24 },
  'Weekly': { category: 'Weekly', label: 'Hàng tuần', durationHours: 168 },
  'Monthly': { category: 'Monthly', label: 'Hàng tháng', durationHours: 720 },
};

// Automatically categorize packages based on their price
export const categorizePackageByDuration = (pricePerHour: number): PackageDuration['category'] => {
  // Simple heuristic: group by price tiers
  // You can adjust this logic as needed
  if (pricePerHour <= 6000) return 'Hourly';
  if (pricePerHour <= 10000) return 'Daily';
  if (pricePerHour <= 15000) return 'Weekly';
  return 'Monthly';
};

export const getDurationLabel = (category: string): string => {
  return PACKAGE_DURATION_MAP[category]?.label || 'Gói dịch vụ';
};
