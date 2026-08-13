const vndNumberFormatter = new Intl.NumberFormat('vi-VN', {
  maximumFractionDigits: 0,
});

export const formatVnd = (amount: number) => `${vndNumberFormatter.format(amount)} ₫`;

export const normalizeVndInput = (value: string) => value.replace(/\D/g, '');

export const formatVndInput = (value: string) => {
  const digits = normalizeVndInput(value);
  return digits ? vndNumberFormatter.format(Number(digits)) : '';
};
